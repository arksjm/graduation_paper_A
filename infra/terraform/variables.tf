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
  description = "IP для app-сервера"
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
