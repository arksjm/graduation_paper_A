.PHONY: bootstrap destroy clean

bootstrap:
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

destroy:
	@echo "=== Удаление инфраструктуры ==="
	cd infra/terraform && terraform destroy -auto-approve

clean:
	rm -f ansible/inventory/hosts.yml
	rm -rf infra/terraform/.terraform
	rm -f infra/terraform/*.tfstate*
	rm -f infra/terraform/.terraform.lock.hcl
