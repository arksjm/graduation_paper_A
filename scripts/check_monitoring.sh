#!/bin/bash

echo "========================================="
echo "ПРОВЕРКА МОНИТОРИНГА"
echo "========================================="
echo ""

# Проверка Prometheus (следуем за редиректом)
echo "1. Prometheus:"
PROMETHEUS_STATUS=$(curl -sL -o /dev/null -w "%{http_code}" http://192.168.56.12:9090)
if [ "$PROMETHEUS_STATUS" = "200" ]; then
    echo "✅ Prometheus работает (HTTP $PROMETHEUS_STATUS)"
    echo "   URL: http://192.168.56.12:9090"
else
    echo "❌ Prometheus не работает (HTTP $PROMETHEUS_STATUS)"
fi
echo ""

# Проверка targets
echo "2. Targets Prometheus:"
curl -s http://192.168.56.12:9090/api/v1/targets | jq -r '.data.activeTargets[] | "   \(.labels.job): \(.health) - \(.scrapeUrl)"' 2>/dev/null || echo "   Нет данных"
echo ""

# Проверка Grafana (следуем за редиректом)
echo "3. Grafana:"
GRAFANA_STATUS=$(curl -sL -o /dev/null -w "%{http_code}" http://192.168.56.12:3000)
if [ "$GRAFANA_STATUS" = "200" ]; then
    echo "✅ Grafana работает (HTTP $GRAFANA_STATUS)"
    echo "   URL: http://192.168.56.12:3000"
    echo "   Логин: admin / admin"
else
    echo "❌ Grafana не работает (HTTP $GRAFANA_STATUS)"
fi
echo ""

# Проверка Node Exporter
echo "4. Node Exporter:"
for IP in 192.168.56.10 192.168.56.11 192.168.56.12; do
    NODE_EXPORTER=$(curl -s -o /dev/null -w "%{http_code}" http://$IP:9100/metrics)
    if [ "$NODE_EXPORTER" = "200" ]; then
        echo "✅ $IP:9100 - работает"
    else
        echo "❌ $IP:9100 - не работает"
    fi
done
echo ""

# Проверка Blackbox Exporter
echo "5. Blackbox Exporter:"
BLACKBOX=$(curl -s -o /dev/null -w "%{http_code}" http://192.168.56.12:9115)
if [ "$BLACKBOX" = "200" ]; then
    echo "✅ Blackbox Exporter работает"
else
    echo "❌ Blackbox Exporter не работает"
fi

# Проверка blackbox probe
echo "   Probe app:"
PROBE_APP=$(curl -s "http://192.168.56.12:9115/probe?target=http://192.168.56.10&module=http_2xx" | grep -E "^probe_success" | awk '{print $2}')
if [ "$PROBE_APP" = "1" ]; then
    echo "   ✅ App доступен через blackbox"
else
    echo "   ❌ App недоступен через blackbox"
fi
echo ""

# Проверка алертов
echo "6. Алерты:"
ALERTS=$(curl -s http://192.168.56.12:9090/api/v1/alerts | jq -r '.data.alerts[] | "   \(.labels.alertname): \(.state) - \(.annotations.summary)"' 2>/dev/null)
if [ -n "$ALERTS" ]; then
    echo "$ALERTS"
else
    echo "   Нет активных алертов"
fi
echo ""

echo "========================================="
