#!/bin/bash

APP_IP="192.168.56.10"

echo "=== Откат к предыдущей версии ==="

# Проверьте наличие предыдущей версии
PREVIOUS_VERSION=$(ssh vagrant@${APP_IP} 'cat ~/app/previous_version.txt 2>/dev/null')
CURRENT_VERSION=$(ssh vagrant@${APP_IP} 'cat ~/app/current_version.txt 2>/dev/null')

echo "Текущая версия: ${CURRENT_VERSION}"
echo "Предыдущая версия: ${PREVIOUS_VERSION}"

if [ -z "$PREVIOUS_VERSION" ]; then
    echo "❌ Нет предыдущей версии для отката"
    exit 1
fi

# Откат к предыдущей версии
ssh vagrant@${APP_IP} "
    cd ~/app
    sed -i 's|image:.*|image: graduation-app:${PREVIOUS_VERSION}|' docker-compose.yml
    docker compose up -d --no-deps web
    echo '${PREVIOUS_VERSION}' > current_version.txt
"

echo "✅ Откат выполнен к версии: ${PREVIOUS_VERSION}"
