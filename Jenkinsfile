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
        
        stage('Build Docker Image') {
            steps {
                sh 'cd app && docker build -t graduation-app:${BUILD_NUMBER} .'
            }
        }
        
        stage('Deploy') {
            when { branch 'main' }
            steps {
                sh 'ssh vagrant@192.168.56.10 "cd ~/app && docker compose up -d --build"'
            }
        }
    }
    
    post {
        success {
            sh '''
                python3 -c "
import smtplib
from email.mime.text import MIMEText
import os

password = os.environ.get('GMAIL_PASSWORD', '')

msg = MIMEText('Build successful!')
msg['From'] = 'ark.sjm@gmail.com'
msg['To'] = 'ark.sjm@gmail.com'
msg['Subject'] = '✅ Build successful'

server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
server.login('ark.sjm@gmail.com', password)
server.sendmail('ark.sjm@gmail.com', 'ark.sjm@gmail.com', msg.as_string())
server.quit()
"
            '''
        }
        failure {
            sh '''
                python3 -c "
import smtplib
from email.mime.text import MIMEText
import os

password = os.environ.get('GMAIL_PASSWORD', '')

msg = MIMEText('Build failed!')
msg['From'] = 'ark.sjm@gmail.com'
msg['To'] = 'ark.sjm@gmail.com'
msg['Subject'] = '❌ Build failed'

server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
server.login('ark.sjm@gmail.com', password)
server.sendmail('ark.sjm@gmail.com', 'ark.sjm@gmail.com', msg.as_string())
server.quit()
"
            '''
        }
    }
}
