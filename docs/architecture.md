# Архитектура системы

## Обзор

Система развёрнута на 3 виртуальных машинах VirtualBox, управляемых через Terraform (IaC) и Ansible (конфигурация). CI/CD через Jenkins. Мониторинг через Prometheus + Grafana.

## Виртуальные машины

| ВМ | IP | Роль | CPU | RAM |
|----|----|------|-----|-----|
| app | 192.168.56.10 | Go-приложение + nginx | 2 | 2GB |
| db | 192.168.56.11 | PostgreSQL | 2 | 2GB |
| monitoring | 192.168.56.12 | Prometheus + Grafana | 1 | 1GB |

## Стек технологий

| Слой | Технология |
|------|------------|
| IaC | Terraform |
| Config | Ansible |
| Runtime | Docker |
| CI/CD | Jenkins |
| Monitoring | Prometheus + Grafana |
| Metrics | Node Exporter |
| Availability | Blackbox Exporter |

## Схема
┌─────────────────────────────────────────────┐
│ Jenkins (CI/CD) │
│ lint → test → build → publish → deploy │
└─────────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────────┐
│ VirtualBox (Hypervisor) │
│ │
│ ┌──────────────┐ ┌──────────────┐ │
│ │ app VM │ │ db VM │ │
│ │ .56.10 │ │ .56.11 │ │
│ │ Go:8080 │ │ PG:5432 │ │
│ │ nginx:80 │ │ │ │
│ └──────────────┘ └──────────────┘ │
│ │
│ ┌──────────────────────────────┐ │
│ │ monitoring VM │ │
│ │ .56.12 │ │
│ │ Prometheus:9090 │ │
│ │ Grafana:3000 │ │
│ │ Blackbox:9115 │ │
│ └──────────────────────────────┘ │
└─────────────────────────────────────────────┘

text

## Сетевые порты

| Порт | Сервис | ВМ |
|------|--------|-----|
| 80 | nginx | app |
| 8080 | Go приложение | app |
| 5432 | PostgreSQL | db |
| 9090 | Prometheus | monitoring |
| 3000 | Grafana | monitoring |
| 9100 | Node Exporter | все |
| 9115 | Blackbox | monitoring |

## Мониторинг

| Метрика | Источник |
|---------|----------|
| CPU, RAM, disk | Node Exporter |
| Доступность | Blackbox Exporter |
| Health | Blackbox → /health |

## Алерты

| Алерт | Условие | Severity |
|-------|---------|----------|
| HostDown | up == 0 | critical |
| HighCPU | CPU > 80% | warning |
| LowMemory | RAM < 10% | warning |
| AppDown | probe_success == 0 | critical |

## CI/CD Pipeline
Push → Lint → Test → Build → Publish → Deploy (Ansible) → Smoke → Notify (Email)

text

## Безопасность

- Пароль Gmail → Jenkins credentials
- SSH по ключам
- Firewall на ВМ
