# Содержимое репозитория

## Обзор
Репозиторий: https://github.com/arksjm/graduation_paper_A

## Структура
graduation_paper_B/
├── ansible/ # Ansible конфигурация
│ ├── ansible.cfg # Настройки Ansible
│ ├── inventory/ # Inventory файлы
│ │ └── hosts.yml # Хосты для Ansible
│ ├── playbooks/ # Playbooks
│ │ ├── check-health.yml # Проверка health
│ │ └── site.yml # Основной playbook
│ └── roles/ # Роли
│ ├── app/ # Роль приложения
│ │ ├── defaults/ # Переменные по умолчанию
│ │ ├── handlers/ # Обработчики
│ │ ├── tasks/ # Задачи
│ │ └── templates/ # Шаблоны
│ ├── common/ # Общая роль
│ │ └── tasks/ # Установка Docker, Node Exporter
│ ├── db/ # Роль БД
│ │ └── tasks/ # PostgreSQL
│ └── monitoring/ # Роль мониторинга
│ ├── files/ # Конфиги Prometheus
│ └── tasks/ # Prometheus + Grafana
├── app/ # Исходный код приложения
│ ├── docker-compose.yml # Docker Compose
│ ├── Dockerfile # Сборка образа
│ ├── go.mod # Go зависимости
│ ├── main.go # Точка входа
│ ├── internal/ # Внутренние пакеты
│ │ ├── calculator/ # Калькулятор
│ │ └── history/ # История операций
│ ├── migrations/ # SQL миграции
│ ├── nginx/ # Конфигурация nginx
│ └── templates/ # HTML шаблоны
├── docs/ # Документация
│ ├── architecture.md # Архитектура
│ ├── runbook.md # Инструкции
│ ├── repository.md # Этот файл
│ └── build-deploy.md # Сборка и развёртывание
├── infra/ # Инфраструктура
│ └── terraform/ # Terraform
│ ├── main.tf # Создание ВМ
│ ├── outputs.tf # Outputs
│ └── variables.tf # Переменные
├── scripts/ # Скрипты
│ ├── check_all.sh # Проверка системы
│ ├── check_health.sh # Проверка health
│ ├── check_monitoring.sh # Проверка мониторинга
│ ├── down.sh # Остановка
│ ├── generate_inventory.sh # Генерация inventory
│ ├── setup_network.sh # Настройка сети
│ └── up.sh # Запуск
├── Jenkinsfile # CI/CD pipeline
├── Makefile # Управление
└── README.md # Главная документация

text

## Описание компонентов

### ansible/
Содержит роли для настройки ВМ:
- **common**: установка Docker, Node Exporter
- **app**: развёртывание Go-приложения
- **db**: настройка PostgreSQL
- **monitoring**: Prometheus + Grafana + Blackbox

### app/
Go-приложение с:
- Калькулятором
- Историей операций
- PostgreSQL для хранения
- Nginx как reverse proxy

### infra/terraform/
Terraform конфигурация для создания 3 ВМ в VirtualBox.

### scripts/
Вспомогательные скрипты для управления системой.

### Jenkinsfile
CI/CD pipeline: lint → test → build → publish → deploy → smoke → notify.
