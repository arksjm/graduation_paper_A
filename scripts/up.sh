#!/bin/bash

echo "=== Запуск инфраструктуры ==="

# 1. Проверка и запуск ВМ
echo ""
echo "=== Шаг 1: Запуск ВМ ==="

for VM in "app" "db" "monitoring"; do
    echo "Проверка $VM..."
    
    if VBoxManage list runningvms | grep -q "$VM"; then
        echo "$VM уже запущена"
    else
        echo "Запуск $VM..."
        VBoxManage startvm "$VM" --type headless
        sleep 5
    fi
done

# 2. Ожидание загрузки
echo ""
echo "=== Шаг 2: Ожидание загрузки ВМ (60 секунд) ==="
sleep 60

# 3. Настройка IP
echo ""
echo "=== Шаг 3: Настройка IP-адресов ==="

# app
echo "Настройка app (192.168.56.10)..."
VBoxManage guestcontrol "app" run --exe /bin/bash --username vagrant --password vagrant --wait-stdout -- -c "
sudo ip addr add 192.168.56.10/24 dev eth1 2>/dev/null || echo 'IP уже настроен'
sudo ip link set eth1 up
" 2>/dev/null || echo "app: guestcontrol не готов, пропускаем"

# db
echo "Настройка db (192.168.56.11)..."
VBoxManage guestcontrol "db" run --exe /bin/bash --username vagrant --password vagrant --wait-stdout -- -c "
sudo ip addr add 192.168.56.11/24 dev eth1 2>/dev/null || echo 'IP уже настроен'
sudo ip link set eth1 up
" 2>/dev/null || echo "db: guestcontrol не готов, пропускаем"

# monitoring
echo "Настройка monitoring (192.168.56.12)..."
VBoxManage guestcontrol "monitoring" run --exe /bin/bash --username vagrant --password vagrant --wait-stdout -- -c "
sudo ip addr add 192.168.56.12/24 dev eth1 2>/dev/null || echo 'IP уже настроен'
sudo ip link set eth1 up
" 2>/dev/null || echo "monitoring: guestcontrol не готов, пропускаем"

# 4. Генерация inventory
echo ""
echo "=== Шаг 4: Генерация Ansible inventory ==="
./scripts/generate_inventory.sh

# 5. Проверка SSH
echo ""
echo "=== Шаг 5: Проверка SSH-доступа ==="
for IP in 192.168.56.10 192.168.56.11 192.168.56.12; do
    if ping -c 1 -W 2 $IP > /dev/null 2>&1; then
        echo "$IP - доступен"
    else
        echo "$IP - недоступен"
    fi
done

# 6. Запуск Docker-контейнеров
echo ""
echo "=== Шаг 6: Запуск Docker-контейнеров ==="

# app
echo "Запуск контейнеров на app..."
ssh vagrant@192.168.56.10 "docker start \$(docker ps -aq)" 2>/dev/null || echo "app: не удалось запустить контейнеры"

# db
echo "Запуск контейнеров на db..."
ssh vagrant@192.168.56.11 "docker start \$(docker ps -aq)" 2>/dev/null || echo "db: не удалось запустить контейнеры"

# monitoring
echo "Запуск контейнеров на monitoring..."
ssh vagrant@192.168.56.12 "docker start \$(docker ps -aq)" 2>/dev/null || echo "monitoring: не удалось запустить контейнеры"

# 7. Итог
echo ""
echo "=== Готово! ==="
echo ""
echo "Сервисы:"
echo "  App:        http://192.168.56.10"
echo "  Grafana:    http://192.168.56.12:3000"
echo "  Prometheus: http://192.168.56.12:9090"
echo ""
echo "SSH-доступ:"
echo "  app:        ssh vagrant@192.168.56.10"
echo "  db:         ssh vagrant@192.168.56.11"
echo "  monitoring: ssh vagrant@192.168.56.12"
