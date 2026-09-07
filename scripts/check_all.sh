#!/bin/bash

echo "========================================="
echo "ПРОВЕРКА СИСТЕМЫ"
echo "========================================="
echo ""

echo "1. Виртуальные машины:"
VBoxManage list runningvms
echo ""

echo "2. Сетевая доступность:"
for IP in 192.168.56.10 192.168.56.11 192.168.56.12; do
    if ping -c 1 -W 2 $IP > /dev/null 2>&1; then
        echo "   ✅ $IP доступен"
    else
        echo "   ❌ $IP недоступен"
    fi
done
echo ""

echo "3. Приложение:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://192.168.56.10)
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Приложение работает (HTTP $HTTP_CODE)"
else
    echo "   ❌ Приложение не отвечает (HTTP $HTTP_CODE)"
fi
echo ""

echo "4. Мониторинг:"
PROM_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://192.168.56.12:9090)
GRAF_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://192.168.56.12:3000)
if [ "$PROM_CODE" = "200" ]; then
    echo "   ✅ Prometheus работает"
else
    echo "   ❌ Prometheus не работает"
fi
if [ "$GRAF_CODE" = "200" ]; then
    echo "   ✅ Grafana работает"
else
    echo "   ❌ Grafana не работает"
fi
echo ""

echo "========================================="
