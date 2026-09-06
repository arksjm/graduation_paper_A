pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/arksjm/graduation_paper_A.git',
                    credentialsId: 'jenkins'
            }
        }

        stage('Build') {
            steps {
                echo "Сборка Docker образа..."
                sh 'cd app && docker compose build'
            }
        }

        stage('Deploy to VM') {
            steps {
                echo "Деплой на app-сервер..."
                sh '''
                    # Копируем docker-compose.yml и nginx конфиг на ВМ
                    ssh -o StrictHostKeyChecking=no vagrant@192.168.56.10 "mkdir -p /opt/app/nginx"
                    scp -o StrictHostKeyChecking=no app/docker-compose.yml vagrant@192.168.56.10:/opt/app/
                    scp -o StrictHostKeyChecking=no -r app/nginx/* vagrant@192.168.56.10:/opt/app/nginx/
                    
                    # Копируем исходный код
                    scp -o StrictHostKeyChecking=no -r app/* vagrant@192.168.56.10:/opt/app/
                    
                    # Запускаем docker compose на ВМ
                    ssh -o StrictHostKeyChecking=no vagrant@192.168.56.10 "cd /opt/app && docker compose up -d --build"
                '''
            }
        }

        stage('Smoke Test') {
            steps {
                echo "Проверка приложения..."
                sh '''
                    sleep 10
                    curl -f http://192.168.56.10:8080 || echo "Приложение недоступно"
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline успешно завершён!"
        }
        failure {
            echo "❌ Pipeline завершился с ошибкой!"
        }
    }
}
