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
                sh 'cd app && docker build -t graduation-app:latest .'
            }
        }

        stage('Deploy to VM') {
            steps {
                echo "Деплой на app-сервер..."
                sh '''
                    # Исправляем права
                    ssh -o StrictHostKeyChecking=no vagrant@192.168.56.10 "sudo mkdir -p /opt/app && sudo chown -R vagrant:vagrant /opt/app"
                    
                    # Копируем файлы
                    scp -o StrictHostKeyChecking=no -r app/* vagrant@192.168.56.10:/opt/app/
                    
                    # Запускаем docker compose
                    ssh -o StrictHostKeyChecking=no vagrant@192.168.56.10 "cd /opt/app && docker compose up -d --build"
                '''
            }
        }

        stage('Smoke Test') {
            steps {
                echo "Проверка приложения..."
                sh '''
                    sleep 15
                    curl -f http://192.168.56.10:8080 && echo "✅ Приложение работает" || echo "❌ Приложение недоступно"
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
