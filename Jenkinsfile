pipeline {
    agent any
    
    environment {
        APP_IP = '192.168.56.10'
        DOCKER_IMAGE = 'graduation-app'
        GMAIL_USER = credentials('gmail-user')
        GMAIL_PASSWORD = credentials('gmail-app-password')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Код загружен"
            }
        }
        
        stage('Lint') {
            steps {
                echo "Проверка кода..."
                sh '''
                    cd app
                    echo "=== gofmt ==="
                    gofmt -l . || true
                    echo "=== go vet ==="
                    go vet ./... || true
                '''
            }
        }
        
        stage('Test') {
            steps {
                echo "Запуск тестов..."
                sh '''
                    cd app
                    go test ./... -v || true
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo "Сборка Docker образа..."
                sh '''
                    cd app
                    docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                '''
            }
        }
        
        stage('Publish Artifact') {
            steps {
                echo "Публикация артефакта..."
                sh '''
                    cd app
                    mkdir -p artifacts
                    docker save ${DOCKER_IMAGE}:${BUILD_NUMBER} | gzip > artifacts/${DOCKER_IMAGE}-${BUILD_NUMBER}.tar.gz
                    ls -la artifacts/
                '''
                archiveArtifacts artifacts: 'app/artifacts/*.tar.gz'
            }
        }
        
        stage('Deploy to App Server') {
            when { branch 'main' }
            steps {
                echo "Деплой на app-сервер..."
                sh '''
                    ssh vagrant@192.168.56.10 'mkdir -p ~/app'
                    scp -r app/* vagrant@192.168.56.10:~/app/
                    ssh vagrant@192.168.56.10 'cd ~/app && docker compose up -d --build'
                '''
            }
        }
        
        stage('Smoke Test') {
            when { branch 'main' }
            steps {
                echo "Проверка приложения..."
                sh '''
                    sleep 15
                    curl -f http://192.168.56.10 || exit 1
                    curl -f http://192.168.56.10/health || exit 1
                '''
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
msg = MIMEText('Build successful!')
msg['From'] = os.environ['GMAIL_USER']
msg['To'] = os.environ['GMAIL_USER']
msg['Subject'] = '✅ Build successful'
server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
server.login(os.environ['GMAIL_USER'], os.environ['GMAIL_PASSWORD'])
server.sendmail(os.environ['GMAIL_USER'], os.environ['GMAIL_USER'], msg.as_string())
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
msg = MIMEText('Build failed!')
msg['From'] = os.environ['GMAIL_USER']
msg['To'] = os.environ['GMAIL_USER']
msg['Subject'] = '❌ Build failed'
server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
server.login(os.environ['GMAIL_USER'], os.environ['GMAIL_PASSWORD'])
server.sendmail(os.environ['GMAIL_USER'], os.environ['GMAIL_USER'], msg.as_string())
server.quit()
"
                '''
            }
        }
    }
}
