#!/bin/bash

APP_IP="192.168.56.10"
VERSION="$1"

if [ -z "$VERSION" ]; then
    VERSION=$(date +%Y%m%d%H%M%S)
fi

echo "=== Blue-Green деплой версии ${VERSION} ==="

ssh vagrant@${APP_IP} "
    cd ~/app
    
    # Определяем текущую версию (blue или green)
    if docker ps | grep -q 'app_blue'; then
        CURRENT='blue'
        NEW='green'
    else
        CURRENT='green'
        NEW='blue'
    fi
    
    echo \"Текущая: \${CURRENT}, Новая: \${NEW}\"
    
    # Запускаем новую версию
    docker compose up -d --no-deps web_\${NEW}
    
    # Проверяем новую версию
    sleep 10
    if curl -f http://localhost/health > /dev/null 2>&1; then
        echo '✅ Новая версия работает'
        # Переключаем трафик
        docker compose stop web_\${CURRENT}
        echo '✅ Трафик переключён'
    else
        echo '❌ Новая версия не работает'
        docker compose stop web_\${NEW}
        exit 1
    fi
"
