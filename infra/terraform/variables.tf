variable "vm_user" {
  description = "Имя пользователя для SSH"
  type        = string
  default     = "vagrant"
}

variable "vm_password" {
  description = "Пароль для первого входа"
  type        = string
  default     = "vagrant"
}

variable "image_path" {
  description = "Путь к VMDK-образу Ubuntu 24.04"
  type        = string
  default     = "images/ubuntu-24.04.vmdk"
}

variable "hostonly_network" {
  description = "Имя host-only сети VirtualBox"
  type        = string
  default     = "vboxnet0"
}

variable "app_ip" {
  description = "IP для app-сервера (frontend+backend)"
  type        = string
  default     = "192.168.56.10"
}

variable "db_ip" {
  description = "IP для db-сервера"
  type        = string
  default     = "192.168.56.11"
}

variable "monitoring_ip" {
  description = "IP для monitoring-сервера"
  type        = string
  default     = "192.168.56.12"
}

variable "vm_memory_app" {
  description = "RAM для app-сервера"
  type        = string
  default     = "2048 mib"
}

variable "vm_memory_db" {
  description = "RAM для db-сервера"
  type        = string
  default     = "2048 mib"
}

variable "vm_memory_monitoring" {
  description = "RAM для monitoring-сервера"
  type        = string
  default     = "1024 mib"
}

variable "vm_cpu_app" {
  description = "CPU для app-сервера"
  type        = number
  default     = 2
}

variable "vm_cpu_db" {
  description = "CPU для db-сервера"
  type        = number
  default     = 2
}

variable "vm_cpu_monitoring" {
  description = "CPU для monitoring-сервера"
  type        = number
  default     = 1
}
