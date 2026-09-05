pipeline {
    agent any
    
    environment {
        APP_IMAGE = 'graduation-app'
        REGISTRY = 'localhost:5000'
        TELEGRAM_BOT_TOKEN = credentials('telegram-bot-token')
        TELEGRAM_CHAT_ID = credentials('telegram-chat-id')
    }
    
    triggers {
        githubPush()
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/arksjm/graduation_paper_A.git',
                    credentialsId: 'github-credentials'
            }
        }
        
        stage('Code Quality') {
            parallel {
                stage('Lint') {
                    steps {
                        sh 'gofmt -l .'
                        sh 'go vet ./...'
                    }
                }
                stage('Tests') {
                    steps {
                        sh 'go test ./... -v -cover'
                    }
                }
            }
        }
        
        stage('Build') {
            steps {
                sh "docker build -t ${APP_IMAGE}:${BUILD_NUMBER} ."
                sh "docker tag ${APP_IMAGE}:${BUILD_NUMBER} ${APP_IMAGE}:latest"
            }
        }
        
        stage('Push to Registry') {
            steps {
                sh "docker tag ${APP_IMAGE}:latest ${REGISTRY}/${APP_IMAGE}:latest"
                sh "docker push ${REGISTRY}/${APP_IMAGE}:latest"
            }
        }
        
        stage('Deploy to VMs') {
            when {
                branch 'main'
            }
            steps {
                script {
                    withCredentials([sshUserPrivateKey(
                        credentialsId: 'ssh-key',
                        keyFileVariable: 'SSH_KEY'
                    )]) {
                        // Деплой на app
                        sh """
                            ssh -i ${SSH_KEY} vagrant@192.168.56.10 '
                                cd /opt/app/repo
                                git pull
                                docker pull ${REGISTRY}/${APP_IMAGE}:latest
                                docker compose up -d --build
                            '
                        """
                        
                        // Деплой на db
                        sh """
                            ssh -i ${SSH_KEY} vagrant@192.168.56.11 '
                                cd /opt/postgres
                                docker compose up -d
                            '
                        """
                        
                        // Деплой мониторинга
                        sh """
                            ssh -i ${SSH_KEY} vagrant@192.168.56.12 '
                                cd /opt/monitoring
                                docker compose up -d
                            '
                        """
                    }
                }
            }
        }
        
        stage('Health Check') {
            when {
                branch 'main'
            }
            steps {
                sh 'sleep 10'
                sh 'curl -f http://192.168.56.10/health || exit 1'
                sh 'curl -f http://192.168.56.12:9090 || exit 1'
                sh 'curl -f http://192.168.56.12:3000 || exit 1'
            }
        }
    }
    
    post {
        success {
            echo "Pipeline успешен!"
            sh """
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage \
                    -d chat_id=${TELEGRAM_CHAT_ID} \
                    -d text="✅ Pipeline #${BUILD_NUMBER} успешен! App: http://192.168.56.10"
            """
        }
        failure {
            echo "Pipeline провалился!"
            sh """
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage \
                    -d chat_id=${TELEGRAM_CHAT_ID} \
                    -d text="❌ Pipeline #${BUILD_NUMBER} провалился!"
            """
        }
    }
}
