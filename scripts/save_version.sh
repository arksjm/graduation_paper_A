#!/bin/bash

APP_IP="192.168.56.10"
VERSION="$1"

if [ -z "$VERSION" ]; then
    echo "Использование: $0 <version>"
    exit 1
fi

ssh vagrant@${APP_IP} "
    cd ~/app
    cp current_version.txt previous_version.txt 2>/dev/null || true
    echo '${VERSION}' > current_version.txt
"

echo "✅ Версия ${VERSION} сохранена"
