output "app_ip" {
  value       = "192.168.56.10"
  description = "IP-адрес app-сервера"
}

output "db_ip" {
  value       = "192.168.56.11"
  description = "IP-адрес db-сервера"
}

output "monitoring_ip" {
  value       = "192.168.56.12"
  description = "IP-адрес monitoring-сервера"
}

output "app_url" {
  value       = "http://192.168.56.10"
  description = "URL приложения"
}

output "grafana_url" {
  value       = "http://192.168.56.12:3000"
  description = "URL Grafana"
}

output "prometheus_url" {
  value       = "http://192.168.56.12:9090"
  description = "URL Prometheus"
}

output "ssh_commands" {
  value = {
    app        = "ssh vagrant@192.168.56.10"
    db         = "ssh vagrant@192.168.56.11"
    monitoring = "ssh vagrant@192.168.56.12"
  }
  description = "Команды для SSH-подключения"
}
