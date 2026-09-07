.PHONY: help start stop up down restart bootstrap destroy clean download-images status check

help:
	@echo "Доступные команды:"
	@echo "  make start    - Запуск ВМ и всех сервисов"
	@echo "  make stop     - Остановка ВМ и сервисов"
	@echo "  make up       - Запуск существующей инфраструктуры (алиас start)"
	@echo "  make down     - Остановка инфраструктуры (алиас stop)"
	@echo "  make restart  - Перезапуск инфраструктуры"
	@echo "  make status   - Проверка статуса"
	@echo "  make check    - Полная проверка системы"
	@echo "  make bootstrap - Полное развёртывание с нуля"
	@echo "  make destroy  - Удаление инфраструктуры"
	@echo "  make clean    - Очистка временных файлов"

# Запуск ВМ и всех сервисов
start:
	@echo "=== Запуск виртуальных машин ==="
	@VBoxManage startvm "app" --type headless 2>/dev/null || echo "app уже запущена"
	@VBoxManage startvm "db" --type headless 2>/dev/null || echo "db уже запущена"
	@VBoxManage startvm "monitoring" --type headless 2>/dev/null || echo "monitoring уже запущена"
	@echo "Ожидание загрузки ВМ (60 секунд)..."
	@sleep 60
	@echo ""
	@echo "=== Настройка сети ==="
	@./scripts/setup_network.sh 2>/dev/null || echo "Сеть уже настроена"
	@echo ""
	@echo "=== Запуск Docker контейнеров ==="
	@ssh vagrant@192.168.56.10 "cd ~/app && docker compose up -d" 2>/dev/null || echo "app: контейнеры уже запущены"
	@ssh vagrant@192.168.56.11 "cd /opt/postgres && docker compose up -d" 2>/dev/null || echo "db: контейнеры уже запущены"
	@ssh vagrant@192.168.56.12 "cd /opt/monitoring && docker compose up -d" 2>/dev/null || echo "monitoring: контейнеры уже запущены"
	@echo ""
	@echo "=== Проверка ==="
	@./scripts/check_all.sh 2>/dev/null || true
	@echo ""
	@echo "=== Готово! ==="
	@echo "App: http://192.168.56.10"
	@echo "Prometheus: http://192.168.56.12:9090"
	@echo "Grafana: http://192.168.56.12:3000 (admin/admin123)"

# Остановка ВМ и сервисов
stop:
	@echo "=== Остановка Docker контейнеров ==="
	@ssh vagrant@192.168.56.10 "cd ~/app && docker compose down" 2>/dev/null || echo "app: контейнеры остановлены"
	@ssh vagrant@192.168.56.11 "cd /opt/postgres && docker compose down" 2>/dev/null || echo "db: контейнеры остановлены"
	@ssh vagrant@192.168.56.12 "cd /opt/monitoring && docker compose down" 2>/dev/null || echo "monitoring: контейнеры остановлены"
	@echo ""
	@echo "=== Остановка ВМ ==="
	@VBoxManage controlvm "app" acpipower 2>/dev/null || echo "app уже остановлена"
	@VBoxManage controlvm "db" acpipower 2>/dev/null || echo "db уже остановлена"
	@VBoxManage controlvm "monitoring" acpipower 2>/dev/null || echo "monitoring уже остановлена"
	@echo "Все ВМ остановлены"

# Алиасы
up: start

down: stop

# Перезапуск
restart:
	@echo "=== Перезапуск ==="
	@make stop
	@sleep 10
	@make start

# Скачивание образов
download-images:
	@echo "=== Скачивание образов ==="
	./scripts/download_images.sh

# Полное развёртывание с нуля
bootstrap: download-images
	@echo "=== Создание инфраструктуры ==="
	cd infra/terraform && terraform init && terraform apply -auto-approve
	@echo "=== Генерация inventory ==="
	./scripts/generate_inventory.sh
	@echo "=== Настройка ВМ через Ansible ==="
	cd ansible && ansible-playbook -i inventory/hosts.yml playbooks/site.yml
	@echo "=== Готово! ==="
	@echo "App: http://192.168.56.10"
	@echo "Grafana: http://192.168.56.12:3000"
	@echo "Prometheus: http://192.168.56.12:9090"

# Удаление инфраструктуры
destroy:
	@echo "=== Удаление инфраструктуры ==="
	cd infra/terraform && terraform destroy -auto-approve

# Очистка временных файлов
clean:
	rm -f ansible/inventory/hosts.yml
	rm -rf infra/terraform/.terraform
	rm -f infra/terraform/*.tfstate*
	rm -f infra/terraform/.terraform.lock.hcl

# Статус инфраструктуры
status:
	@echo "=== Статус ВМ ==="
	@VBoxManage list runningvms
	@echo ""
	@echo "=== Статус контейнеров ==="
	@echo "--- App (192.168.56.10) ---"
	@ssh vagrant@192.168.56.10 "docker ps --format 'table {{.Names}}\t{{.Status}}'" 2>/dev/null || echo "Недоступна"
	@echo ""
	@echo "--- DB (192.168.56.11) ---"
	@ssh vagrant@192.168.56.11 "docker ps --format 'table {{.Names}}\t{{.Status}}'" 2>/dev/null || echo "Недоступна"
	@echo ""
	@echo "--- Monitoring (192.168.56.12) ---"
	@ssh vagrant@192.168.56.12 "docker ps --format 'table {{.Names}}\t{{.Status}}'" 2>/dev/null || echo "Недоступна"

# Полная проверка
check:
	@echo "=== Полная проверка системы ==="
	@./scripts/check_all.sh 2>/dev/null || true

# Пересоздание ВМ с полной настройкой
recreate:
	@echo "=== Пересоздание ВМ ==="
	@make destroy
	@sleep 10
	@make bootstrap
