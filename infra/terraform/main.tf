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
      if ! VBoxManage list hostonlyifs | grep -q "vboxnet0"; then
        VBoxManage hostonlyif create
        sleep 2
      fi
      VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
      VBoxManage dhcpserver remove --ifname vboxnet0 2>/dev/null || true
      echo "Host-only сеть настроена"
    EOT
  }
}

# Создание ВМ app
resource "null_resource" "create_app_vm" {
  depends_on = [null_resource.ensure_network]
  
  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage unregistervm "app" --delete 2>/dev/null || true
      VBoxManage createvm --name "app" --register
      VBoxManage modifyvm "app" --memory 2048 --cpus 2 --ostype Ubuntu_64
      VBoxManage modifyvm "app" --nic1 nat
      VBoxManage modifyvm "app" --nic2 hostonly --hostonlyadapter2 vboxnet0
      VBoxManage storagectl "app" --name "SATA" --add sata --controller IntelAhci
      VBoxManage storageattach "app" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "${var.image_path}"
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

# Ожидание загрузки и настройка сети
resource "null_resource" "setup_network" {
  depends_on = [null_resource.create_app_vm, null_resource.create_db_vm, null_resource.create_monitoring_vm]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Ожидание загрузки ВМ (90 секунд)..."
      sleep 90
      
      # Настройка IP для каждой ВМ
      for VM_IP in "app:192.168.56.10" "db:192.168.56.11" "monitoring:192.168.56.12"; do
        NAME="${VM_IP%%:*}"
        IP="${VM_IP##*:}"
        
        echo "Настройка $NAME ($IP)..."
        VBoxManage guestcontrol "$NAME" run --exe /bin/bash --username vagrant --password vagrant --wait-stdout -- -c "
          sudo ip addr add $IP/24 dev eth1 2>/dev/null || echo 'IP уже настроен'
          sudo ip link set eth1 up
        " 2>&1
      done
      
      echo "Сеть настроена"
    EOT
  }
}

# Запуск Ansible после создания ВМ
resource "null_resource" "run_ansible" {
  depends_on = [null_resource.setup_network]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Генерация inventory..."
      cd ~/graduation_paper_B/scripts
      ./generate_inventory.sh
      
      echo "Запуск Ansible..."
      cd ~/graduation_paper_B/ansible
      ansible-playbook -i inventory/hosts.yml playbooks/site.yml
      
      echo "Настройка завершена!"
    EOT
  }
}
