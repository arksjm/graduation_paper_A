#!/bin/bash

echo "Настройка сети ВМ..."

for VM_IP in "app:192.168.56.10" "db:192.168.56.11" "monitoring:192.168.56.12"; do
    NAME="${VM_IP%%:*}"
    IP="${VM_IP##*:}"
    
    echo "Настройка $NAME ($IP)..."
    VBoxManage guestcontrol "$NAME" run --exe /bin/bash --username vagrant --password vagrant --wait-stdout -- -c "
        sudo ip addr add $IP/24 dev eth1 2>/dev/null || echo 'IP уже настроен'
        sudo ip link set eth1 up
    " 2>&1
    
    if [ $? -eq 0 ]; then
        echo "✅ $NAME настроен"
    else
        echo "⚠️ $NAME: guestcontrol не работает"
    fi
    echo ""
done
