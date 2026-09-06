#!/bin/bash

echo "========================================="
echo "ПРОВЕРКА HEALTH-ENDPOINT"
echo "========================================="
echo ""

# Проверка HTTP статуса
echo "1. HTTP статус:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://192.168.56.10/health)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Health-endpoint отвечает (HTTP $HTTP_CODE)"
else
    echo "❌ Health-endpoint не отвечает (HTTP $HTTP_CODE)"
fi
echo ""

# Проверка JSON
echo "2. JSON ответ:"
curl -s http://192.168.56.10/health | python3 -m json.tool 2>/dev/null || curl -s http://192.168.56.10/health
echo ""

# Проверка структуры JSON
echo "3. Проверка структуры:"
RESPONSE=$(curl -s http://192.168.56.10/health)
echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print('✅ JSON корректен, status=' + data['status'])" 2>/dev/null || echo "❌ JSON некорректен"
echo ""

echo "========================================="
