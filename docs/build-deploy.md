# Сборка и развёртывание

## Требования

- Ubuntu 24.04
- VirtualBox 7.1+
- Terraform 1.9+
- Ansible 2.15+
- Jenkins 2.568+
- Docker

## Сборка

### Локальная сборка

```bash
cd app
docker build -t graduation-app:latest .
Сборка в Jenkins
Jenkinsfile выполняет:

Lint: gofmt -l . + go vet ./...

Test: go test ./... -v

Build: docker build -t graduation-app:${BUILD_NUMBER}

Publish: сохранение артефакта

Развёртывание
Быстрый старт
bash
make bootstrap
Этапы развёртывания
Terraform: создание 3 ВМ

bash
cd infra/terraform
terraform init
terraform apply
Ansible: настройка ВМ

bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/site.yml
Проверка:

bash
curl http://192.168.56.10
curl http://192.168.56.12:9090
curl http://192.168.56.12:3000
CI/CD
Jenkins автоматически:

Запускается при пуше (Poll SCM)

Собирает Docker образ

Публикует артефакт

Деплоит через Ansible

Проверяет health

Отправляет Email

Teardown
bash
make destroy
