pipeline {
    agent any

    triggers {
        githubPush()
    }

    environment {
        APP_IP = '192.168.56.10'
        DOCKER_IMAGE = 'graduation-app'
        GMAIL_PASSWORD = credentials('gmail-app-password')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Lint') {
            steps {
                sh 'cd app && gofmt -l . || true'
                sh 'cd app && go vet ./... || true'
            }
        }

        stage('Test') {
            steps {
                sh 'cd app && go test ./... -v || true'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'cd app && docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .'
            }
        }

        stage('Publish Artifact') {
            steps {
                sh '''
                    cd app
                    mkdir -p artifacts
                    docker save ${DOCKER_IMAGE}:${BUILD_NUMBER} | gzip > artifacts/${DOCKER_IMAGE}-${BUILD_NUMBER}.tar.gz
                '''
                archiveArtifacts artifacts: 'app/artifacts/*.tar.gz'
            }
        }

        stage('Deploy via Ansible') {
            steps {
                echo "Автоматический деплой через Ansible..."
                script {
                    sh '''
                        # Генерация inventory
                        ./scripts/generate_inventory.sh
                        
                        # Запуск Ansible playbook для app
                        ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/site.yml --limit app
                    '''
                }
            }
        }

        stage('Smoke Test') {
            steps {
                sh 'sleep 10 && curl -f http://192.168.56.10/ || exit 1'
            }
        }
    }

    post {
        success {
            script {
                sh '''
                    python3 -c "
import smtplib, os
from email.mime.text import MIMEText
msg = MIMEText('Build and Ansible deploy successful!')
msg['From'] = 'ark.sjm@gmail.com'
msg['To'] = 'ark.sjm@gmail.com'
msg['Subject'] = '✅ Build + Ansible Deploy ${BUILD_NUMBER} successful'
server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
server.login('ark.sjm@gmail.com', os.environ['GMAIL_PASSWORD'])
server.sendmail('ark.sjm@gmail.com', 'ark.sjm@gmail.com', msg.as_string())
server.quit()
"
                '''
            }
        }
        failure {
            script {
                sh '''
                    python3 -c "
import smtplib, os
from email.mime.text import MIMEText
msg = MIMEText('Build or Ansible deploy failed!')
msg['From'] = 'ark.sjm@gmail.com'
msg['To'] = 'ark.sjm@gmail.com'
msg['Subject'] = '❌ Build #${BUILD_NUMBER} failed'
server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
server.login('ark.sjm@gmail.com', os.environ['GMAIL_PASSWORD'])
server.sendmail('ark.sjm@gmail.com', 'ark.sjm@gmail.com', msg.as_string())
server.quit()
"
                '''
            }
        }
    }
}
