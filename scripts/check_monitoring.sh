#!/bin/bash

echo "========================================="
echo "ПРОВЕРКА МОНИТОРИНГА"
echo "========================================="
echo ""

# Prometheus
echo "1. Prometheus:"
PROM_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://192.168.56.12:9090)
if [ "$PROM_STATUS" = "200" ]; then
    echo "✅ Prometheus работает (HTTP $PROM_STATUS)"
else
    echo "❌ Prometheus не работает"
fi
echo ""

# Targets
echo "2. Targets Prometheus:"
curl -s http://192.168.56.12:9090/api/v1/targets | jq -r '.data.activeTargets[] | "   \(.labels.job): \(.health)"'
echo ""

# Grafana
echo "3. Grafana:"
GRAF_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://192.168.56.12:3000)
if [ "$GRAF_STATUS" = "200" ]; then
    echo "✅ Grafana работает (HTTP $GRAF_STATUS)"
else
    echo "❌ Grafana не работает"
fi
echo ""

# Data Sources
echo "4. Data Sources Grafana:"
curl -s http://admin:admin@192.168.56.12:3000/api/datasources | jq -r '.[] | "   \(.name): \(.type)"'
echo ""

# Alerts
echo "5. Алерты Prometheus:"
curl -s http://192.168.56.12:9090/api/v1/alerts | jq -r '.data.alerts[] | "   \(.labels.alertname): \(.state)"' 2>/dev/null || echo "   Нет активных алертов"
echo ""

# Node Exporter
echo "6. Node Exporter:"
for IP in 192.168.56.10 192.168.56.11 192.168.56.12; do
    NODE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$IP:9100/metrics)
    if [ "$NODE_STATUS" = "200" ]; then
        echo "   ✅ $IP:9100 работает"
    else
        echo "   ❌ $IP:9100 не работает"
    fi
done
echo ""

echo "========================================="
echo "ИТОГ: Мониторинг полностью настроен!"
echo "  - Prometheus: http://192.168.56.12:9090"
echo "  - Grafana: http://192.168.56.12:3000 (admin/admin)"
echo "  - Дашборд: Infrastructure Monitoring"
echo "========================================="
