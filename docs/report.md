# Отчёт о выполнении выпускной работы A

## Checklist

### Приложение
- [x] Fork публичного репозитория: https://github.com/arksjm/graduation_paper_A
- [x] Docker compose (app/docker-compose.yml)
- [x] Health-endpoint (http://192.168.56.10/health)

### IaC + Ansible
- [x] 3 ВМ создаются Terraform (app, db, monitoring)
- [x] Ansible идемпотентен
- [x] Роли разделены: common, app, db, monitoring
- [x] Bootstrap одной командой: `make bootstrap`
- [x] Секреты не в git (Gmail пароль в Jenkins credentials)

### CI/CD
- [x] Lint: gofmt + go vet
- [x] Build: docker build
- [x] Test: go test (6 тестов PASS)
- [x] Publish: archiveArtifacts (tar.gz)
- [x] Auto-deploy: Ansible playbook
- [x] Уведомление: Email (ark.sjm@gmail.com)

### Observability + docs
- [x] Monitoring: Prometheus + Grafana
- [x] Node Exporter (CPU/RAM/disk)
- [x] Blackbox Exporter (health check)
- [x] 4 алерта (HostDown, HighCPU, LowMemory, AppDown)
- [x] README.md
- [x] docs/architecture.md
- [x] docs/runbook.md
- [x] Teardown: `make destroy`

---

## Postmortem: Конфликт порта 8080

### Описание
При деплое через Jenkins возникала ошибка:
`Bind for 0.0.0.0:8080 failed: port is already allocated`

### Причина
Старый контейнер `graduation_app` занимал порт 8080.

### Решение
Добавлена очистка перед деплоем:
```bash
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
Уроки
Всегда очищать старые контейнеры

Использовать уникальные порты

CI/CD должен включать cleanup

Доступы
Сервис	URL	Логин/Пароль
Приложение	http://192.168.56.10	-
Prometheus	http://192.168.56.12:9090	-
Grafana	http://192.168.56.12:3000	admin/admin123
Jenkins	http://192.168.0.43:8081	admiq/qwer
