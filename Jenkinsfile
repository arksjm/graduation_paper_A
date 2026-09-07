pipeline {
    agent any
    
    environment {
        APP_IP = '192.168.56.10'
        DOCKER_IMAGE = 'graduation-app'
        RECIPIENT_EMAIL = 'ark.sjm@gmail.com'
    }
    
    triggers {
        githubPush()
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
                script {
                    sh '''
                        cd app || exit 1
                        echo "=== gofmt ==="
                        gofmt -l .
                        echo "=== go vet ==="
                        go vet ./...
                    '''
                }
            }
        }
        
        stage('Test') {
            steps {
                echo "Запуск тестов..."
                script {
                    sh '''
                        cd app || exit 1
                        go test ./... -v -cover || true
                    '''
                }
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
            emailext (
                subject: "✅ Сборка #${BUILD_NUMBER} успешна - graduation_paper_B",
                body: """
                    <h2 style="color: green;">Сборка успешно завершена!</h2>
                    <table border="1" cellpadding="10">
                        <tr><td><b>Проект:</b></td><td>${env.JOB_NAME}</td></tr>
                        <tr><td><b>Сборка:</b></td><td>#${BUILD_NUMBER}</td></tr>
                        <tr><td><b>Ветка:</b></td><td>${env.GIT_BRANCH}</td></tr>
                    </table>
                    <p>Приложение: <a href="http://${APP_IP}">http://${APP_IP}</a></p>
                    <p>Логи: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                """,
                to: "${RECIPIENT_EMAIL}",
                mimeType: 'text/html'
            )
        }
        
        failure {
            emailext (
                subject: "❌ Сборка #${BUILD_NUMBER} провалилась - graduation_paper_B",
                body: """
                    <h2 style="color: red;">Сборка провалилась!</h2>
                    <table border="1" cellpadding="10">
                        <tr><td><b>Проект:</b></td><td>${env.JOB_NAME}</td></tr>
                        <tr><td><b>Сборка:</b></td><td>#${BUILD_NUMBER}</td></tr>
                    </table>
                    <p>Логи: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                """,
                to: "${RECIPIENT_EMAIL}",
                mimeType: 'text/html'
            )
        }
        
        always {
            cleanWs()
        }
    }
}
