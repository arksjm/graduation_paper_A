terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

# Убедимся, что host-only сеть существует
resource "null_resource" "ensure_network" {
  provisioner "local-exec" {
    command = <<-EOT
      # Проверяем и создаем host-only сеть, если её нет
      if ! VBoxManage list hostonlyifs | grep -q "vboxnet0"; then
        VBoxManage hostonlyif create
        sleep 2
      fi
      # Настраиваем IP сети
      VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
      # Отключаем DHCP
      VBoxManage dhcpserver remove --ifname vboxnet0 2>/dev/null || true
      echo "Host-only сеть vboxnet0 настроена"
    EOT
  }
}

# Создание ВМ app
resource "null_resource" "create_app_vm" {
  depends_on = [null_resource.ensure_network]
  
  provisioner "local-exec" {
    command = <<-EOT
      # Удаляем старую ВМ, если есть
      VBoxManage unregistervm "app" --delete 2>/dev/null || true
      
      # Создаем ВМ
      VBoxManage createvm --name "app" --register
      VBoxManage modifyvm "app" --memory 2048 --cpus 2 --ostype Ubuntu_64
      
      # Настраиваем сеть
      VBoxManage modifyvm "app" --nic1 nat
      VBoxManage modifyvm "app" --nic2 hostonly --hostonlyadapter2 vboxnet0
      
      # Подключаем диск
      VBoxManage storagectl "app" --name "SATA" --add sata --controller IntelAhci
      VBoxManage storageattach "app" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "${var.image_path}"
      
      # Запускаем ВМ
      VBoxManage startvm "app" --type headless
      
      echo "ВМ app создана и запущена"
    EOT
  }
}

# Создание ВМ db
resource "null_resource" "create_db_vm" {
  depends_on = [null_resource.ensure_network]
  
  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage unregistervm "db" --delete 2>/dev/null || true
      VBoxManage createvm --name "db" --register
      VBoxManage modifyvm "db" --memory 2048 --cpus 2 --ostype Ubuntu_64
      VBoxManage modifyvm "db" --nic1 nat
      VBoxManage modifyvm "db" --nic2 hostonly --hostonlyadapter2 vboxnet0
      VBoxManage storagectl "db" --name "SATA" --add sata --controller IntelAhci
      VBoxManage storageattach "db" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "${var.image_path}"
      VBoxManage startvm "db" --type headless
      echo "ВМ db создана и запущена"
    EOT
  }
}

# Создание ВМ monitoring
resource "null_resource" "create_monitoring_vm" {
  depends_on = [null_resource.ensure_network]
  
  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage unregistervm "monitoring" --delete 2>/dev/null || true
      VBoxManage createvm --name "monitoring" --register
      VBoxManage modifyvm "monitoring" --memory 1024 --cpus 1 --ostype Ubuntu_64
      VBoxManage modifyvm "monitoring" --nic1 nat
      VBoxManage modifyvm "monitoring" --nic2 hostonly --hostonlyadapter2 vboxnet0
      VBoxManage storagectl "monitoring" --name "SATA" --add sata --controller IntelAhci
      VBoxManage storageattach "monitoring" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "${var.image_path}"
      VBoxManage startvm "monitoring" --type headless
      echo "ВМ monitoring создана и запущена"
    EOT
  }
}

# Настройка статических IP внутри ВМ (через VBoxManage guestcontrol)
resource "null_resource" "configure_static_ips" {
  depends_on = [null_resource.create_app_vm, null_resource.create_db_vm, null_resource.create_monitoring_vm]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Ожидание загрузки ВМ..."
      sleep 60
      
      echo "Настройка статических IP..."
      
      # Для app (192.168.56.10)
      VBoxManage guestcontrol "app" run --exe /bin/bash --username vagrant --password vagrant -- -c "sudo ip addr add 192.168.56.10/24 dev enp0s8 2>/dev/null || true" 2>/dev/null || true
      
      # Для db (192.168.56.11)
      VBoxManage guestcontrol "db" run --exe /bin/bash --username vagrant --password vagrant -- -c "sudo ip addr add 192.168.56.11/24 dev enp0s8 2>/dev/null || true" 2>/dev/null || true
      
      # Для monitoring (192.168.56.12)
      VBoxManage guestcontrol "monitoring" run --exe /bin/bash --username vagrant --password vagrant -- -c "sudo ip addr add 192.168.56.12/24 dev enp0s8 2>/dev/null || true" 2>/dev/null || true
      
      echo "Статические IP настроены"
    EOT
  }
}
