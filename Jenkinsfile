pipeline {
    agent any
    
    environment {
        APP_IP = '192.168.56.10'
        DOCKER_REGISTRY = 'localhost:5000'  // Или Docker Hub
        IMAGE_NAME = 'graduation-app'
    }
    
    parameters {
        choice(
            name: 'DEPLOY_VERSION',
            choices: ['latest', 'rollback'],
            description: 'Выберите версию для деплоя'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            when {
                expression { params.DEPLOY_VERSION == 'latest' }
            }
            steps {
                echo "Сборка Docker образа..."
                script {
                    sh """
                        cd app
                        docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                        docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
                        docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}
                        docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}
                        docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
                    """
                }
            }
        }
        
        stage('Deploy') {
            steps {
                echo "Деплой версии ${BUILD_NUMBER}..."
                script {
                    def deployVersion = params.DEPLOY_VERSION == 'rollback' ? 'previous' : BUILD_NUMBER
                    
                    sh """
                        ssh -o StrictHostKeyChecking=no vagrant@${APP_IP} 'mkdir -p ~/app'
                        scp -o StrictHostKeyChecking=no -r app/* vagrant@${APP_IP}:~/app/
                        
                        # Создание docker-compose с версионированным образом
                        ssh -o StrictHostKeyChecking=no vagrant@${APP_IP} "
                            cd ~/app
                            
                            # Сохраняем текущую версию перед обновлением
                            if [ -f current_version.txt ]; then
                                cp current_version.txt previous_version.txt
                            fi
                            
                            # Обновляем docker-compose.yml с новой версией
                            sed -i 's|image:.*|image: ${DOCKER_REGISTRY}/${IMAGE_NAME}:${deployVersion}|' docker-compose.yml
                            
                            # Запускаем новую версию
                            docker compose up -d --no-deps web
                            
                            # Сохраняем текущую версию
                            echo '${deployVersion}' > current_version.txt
                        "
                    """
                }
            }
        }
        
        stage('Health Check') {
            steps {
                echo "Проверка новой версии..."
                sh """
                    sleep 15
                    HTTP_CODE=\$(curl -s -o /dev/null -w "%{http_code}" http://${APP_IP}/)
                    if [ "\$HTTP_CODE" != "200" ]; then
                        echo "❌ Health check failed. Rolling back..."
                        ssh vagrant@${APP_IP} 'cd ~/app && docker compose up -d --no-deps web'
                        exit 1
                    fi
                    echo "✅ Приложение работает"
                """
            }
        }
    }
    
    post {
        success {
            echo "✅ Деплой успешен! Версия: ${BUILD_NUMBER}"
        }
        failure {
            echo "❌ Деплой провалился! Автоматический откат..."
            script {
                sh """
                    ssh vagrant@${APP_IP} 'cd ~/app && docker compose up -d --no-deps web'
                """
            }
        }
    }
}
