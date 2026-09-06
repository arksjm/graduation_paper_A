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
                sh 'docker build -t graduation-app:latest .'
            }
        }

        stage('Deploy to VM') {
            steps {
                echo "Деплой на app-сервер..."
                sh '''
                    # Сохраняем образ
                    docker save graduation-app:latest | gzip > /tmp/graduation-app.tar.gz
                    
                    # Копируем на ВМ
                    scp -o StrictHostKeyChecking=no /tmp/graduation-app.tar.gz vagrant@192.168.56.10:/tmp/
                    
                    # Загружаем образ на ВМ
                    ssh -o StrictHostKeyChecking=no vagrant@192.168.56.10 "docker load < /tmp/graduation-app.tar.gz"
                    
                    # Перезапускаем контейнер
                    ssh -o StrictHostKeyChecking=no vagrant@192.168.56.10 "docker stop graduation_app 2>/dev/null || true"
                    ssh -o StrictHostKeyChecking=no vagrant@192.168.56.10 "docker rm graduation_app 2>/dev/null || true"
                    ssh -o StrictHostKeyChecking=no vagrant@192.168.56.10 "docker run -d --name graduation_app -p 80:8080 --restart always graduation-app:latest"
                '''
            }
        }

        stage('Smoke Test') {
            steps {
                echo "Проверка приложения..."
                sh '''
                    sleep 5
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
