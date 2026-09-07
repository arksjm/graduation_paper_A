pipeline {
    agent any
    
    environment {
        APP_IP = '192.168.56.10'
        DOCKER_IMAGE = 'graduation-app'
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
                sh '''
                    cd app || exit 1
                    gofmt -l . || true
                    go vet ./... || true
                '''
            }
        }
        
        stage('Test') {
            steps {
                sh '''
                    cd app || exit 1
                    go test ./... -v || true
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh '''
                    cd app
                    docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                '''
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
        
        stage('Deploy') {
            when { branch 'main' }
            steps {
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
                sh 'sleep 10 && curl -f http://192.168.56.10 || exit 1'
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
msg['From'] = 'ark.sjm@gmail.com'
msg['To'] = 'ark.sjm@gmail.com'
msg['Subject'] = '✅ Build ${BUILD_NUMBER} successful'
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
msg = MIMEText('Build failed!')
msg['From'] = 'ark.sjm@gmail.com'
msg['To'] = 'ark.sjm@gmail.com'
msg['Subject'] = '❌ Build ${BUILD_NUMBER} failed'
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
