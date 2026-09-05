.PHONY: up down bootstrap destroy clean download-images status

# Запуск существующей инфраструктуры
up:
	@echo "=== Запуск инфраструктуры ==="
	./scripts/up.sh

# Остановка инфраструктуры
down:
	@echo "=== Остановка инфраструктуры ==="
	./scripts/down.sh

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
	VBoxManage list runningvms
	@echo ""
	@echo "=== Статус контейнеров ==="
	@echo "app:"
	@ssh vagrant@192.168.56.10 "docker ps --format 'table {{.Names}}\t{{.Status}}'" 2>/dev/null || echo "  недоступен"
	@echo ""
	@echo "db:"
	@ssh vagrant@192.168.56.11 "docker ps --format 'table {{.Names}}\t{{.Status}}'" 2>/dev/null || echo "  недоступен"
	@echo ""
	@echo "monitoring:"
	@ssh vagrant@192.168.56.12 "docker ps --format 'table {{.Names}}\t{{.Status}}'" 2>/dev/null || echo "  недоступен"

# Проверка доступности
check:
	@echo "=== Проверка доступности ==="
	@for IP in 192.168.56.10 192.168.56.11 192.168.56.12; do \
		if ping -c 1 -W 2 $$IP > /dev/null 2>&1; then \
			echo "$$IP - доступен"; \
		else \
			echo "$$IP - недоступен"; \
		fi; \
	done
	@echo ""
	@echo "=== Проверка HTTP ==="
	@curl -I http://192.168.56.10 2>/dev/null | head -1 || echo "App недоступен"
	@curl -I http://192.168.56.12:3000 2>/dev/null | head -1 || echo "Grafana недоступен"
	@curl -I http://192.168.56.12:9090 2>/dev/null | head -1 || echo "Prometheus недоступен"
