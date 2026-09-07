# Runbook — инструкции по эксплуатации

## Запуск системы

### Полный запуск с нуля
```bash
make bootstrap
Запуск существующей инфраструктуры
bash
make start
Проверка статуса
bash
make status
Остановка
bash
make stop
# или
make down
Проверка работоспособности
bash
# Полная проверка
make check

# Проверка мониторинга
./scripts/check_monitoring.sh

# Проверка health
./scripts/check_health.sh
Просмотр логов
bash
# Приложение
ssh vagrant@192.168.56.10 "docker logs web-go-prg-web-1 --tail 50"

# PostgreSQL
ssh vagrant@192.168.56.11 "docker logs web-go-prg-db-1 --tail 50"

# Prometheus
ssh vagrant@192.168.56.12 "docker logs prometheus --tail 50"

# Grafana
ssh vagrant@192.168.56.12 "docker logs grafana --tail 50"

# Jenkins
sudo journalctl -u jenkins --tail 50
Доступы
Сервис	URL	Логин	Пароль
Приложение	http://192.168.56.10	-	-
Prometheus	http://192.168.56.12:9090	-	-
Grafana	http://192.168.56.12:3000	admin	admin123
Jenkins	http://192.168.0.43:8081	admiq	qwer
Обновление
Через Jenkins: push в GitHub → автоматическая сборка.

Вручную:

bash
cd ~/graduation_paper_B
make bootstrap
Откат
bash
./scripts/rollback.sh
Teardown
bash
make destroy
make clean
Troubleshooting
Приложение не отвечает
bash
ssh vagrant@192.168.56.10 "docker ps -a"
ssh vagrant@192.168.56.10 "docker logs web-go-prg-web-1 --tail 100"
PostgreSQL не работает
bash
ssh vagrant@192.168.56.11 "docker ps -a"
ssh vagrant@192.168.56.11 "docker logs web-go-prg-db-1 --tail 100"
Prometheus targets down
bash
curl http://192.168.56.12:9090/api/v1/targets
ВМ недоступна
bash
VBoxManage list runningvms
VBoxManage startvm "app" --type headless
./scripts/setup_network.sh
Перезагрузка
После перезагрузки хоста:

bash
cd ~/graduation_paper_B
make start
Docker volumes
bash
# Просмотр
ssh vagrant@192.168.56.11 "docker volume ls"
ssh vagrant@192.168.56.12 "docker volume ls"
