pipeline {
    agent any

    environment {
        APP_IMAGE = 'graduation-app'
        APP_VM = '192.168.56.10'
    }

    options {
        skipDefaultCheckout(true)
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/arksjm/graduation_paper_B.git',
                    credentialsId: 'jenkins'
                echo "Код получен"
            }
        }

        stage('Build') {
            steps {
                echo "Сборка Docker образа..."
                sh 'docker build -t graduation-app:latest .'
            }
        }

        stage('Deploy') {
            steps {
                echo "Деплой на сервер..."
                sh '''
                    ssh vagrant@192.168.56.10 "mkdir -p /opt/app"
                    scp docker-compose.yml vagrant@192.168.56.10:/opt/app/
                    ssh vagrant@192.168.56.10 "cd /opt/app && docker compose up -d --build"
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
