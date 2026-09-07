pipeline {
    agent any
    
    environment {
        APP_IP = '192.168.56.10'
        DOCKER_IMAGE = 'graduation-app'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Код загружен"
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo "Сборка Docker образа..."
                script {
                    sh '''
                        cd app
                        docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                        docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }
        
        stage('Deploy to App Server') {
            when {
                branch 'main'
            }
            steps {
                echo "Деплой на app-сервер..."
                script {
                    sh '''
                        ssh -o StrictHostKeyChecking=no vagrant@${APP_IP} 'mkdir -p ~/app'
                        scp -o StrictHostKeyChecking=no -r app/* vagrant@${APP_IP}:~/app/
                        ssh -o StrictHostKeyChecking=no vagrant@${APP_IP} 'cd ~/app && docker compose up -d --build'
                    '''
                }
            }
        }
        
        stage('Smoke Test') {
            when {
                branch 'main'
            }
            steps {
                echo "Проверка приложения..."
                script {
                    sh '''
                        sleep 15
                        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://${APP_IP}/)
                        if [ "$HTTP_CODE" = "200" ]; then
                            echo "✅ Приложение работает"
                        else
                            echo "❌ Приложение не отвечает: $HTTP_CODE"
                            exit 1
                        fi
                    '''
                }
            }
        }
    }
    
    post {
        success {
            mail to: 'ark.sjm@gmail.com',
                 subject: "✅ Build ${BUILD_NUMBER} successful - graduation_paper_B",
                 body: """
                    Build successful!
                    Project: graduation_paper_B
                    Build: #${BUILD_NUMBER}
                    App: http://${APP_IP}
                    Health: http://${APP_IP}/health
                    Logs: ${BUILD_URL}
                 """
        }
        failure {
            mail to: 'ark.sjm@gmail.com',
                 subject: "❌ Build ${BUILD_NUMBER} failed - graduation_paper_B",
                 body: """
                    Build failed!
                    Project: graduation_paper_B
                    Build: #${BUILD_NUMBER}
                    Logs: ${BUILD_URL}
                 """
        }
    }
}
