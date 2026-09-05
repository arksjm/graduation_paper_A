#!/bin/bash

echo "=== Остановка инфраструктуры ==="

# 1. Остановка Docker-контейнеров
echo ""
echo "=== Остановка Docker-контейнеров ==="

ssh vagrant@192.168.56.10 "docker stop \$(docker ps -q)" 2>/dev/null || echo "app: контейнеры уже остановлены"
ssh vagrant@192.168.56.11 "docker stop \$(docker ps -q)" 2>/dev/null || echo "db: контейнеры уже остановлены"
ssh vagrant@192.168.56.12 "docker stop \$(docker ps -q)" 2>/dev/null || echo "monitoring: контейнеры уже остановлены"

# 2. Остановка ВМ
echo ""
echo "=== Остановка ВМ ==="

for VM in "app" "db" "monitoring"; do
    if VBoxManage list runningvms | grep -q "$VM"; then
        echo "Остановка $VM..."
        VBoxManage controlvm "$VM" acpipower
        sleep 5
    else
        echo "$VM уже остановлена"
    fi
done

echo ""
echo "=== Готово! ==="
