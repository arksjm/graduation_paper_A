terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }
}

# Создание ВМ через VBoxManage
resource "null_resource" "create_vms" {
  provisioner "local-exec" {
    command = <<-EOT
      # Копирование дисков для каждой ВМ (если ещё не сделано)
      if [ ! -f "${path.module}/images/app-disk.vmdk" ]; then
        cp "${path.module}/images/ubuntu-24.04.vmdk" "${path.module}/images/app-disk.vmdk"
      fi
      if [ ! -f "${path.module}/images/db-disk.vmdk" ]; then
        cp "${path.module}/images/ubuntu-24.04.vmdk" "${path.module}/images/db-disk.vmdk"
      fi
      if [ ! -f "${path.module}/images/monitoring-disk.vmdk" ]; then
        cp "${path.module}/images/ubuntu-24.04.vmdk" "${path.module}/images/monitoring-disk.vmdk"
      fi
      
      # Создание ВМ app
      VBoxManage unregistervm "app" --delete 2>/dev/null || true
      VBoxManage createvm --name "app" --ostype Ubuntu_64 --register
      VBoxManage modifyvm "app" --memory 2048 --cpus 2 --nic1 nat --nic2 hostonly --hostonlyadapter2 vboxnet0
      VBoxManage storagectl "app" --name "SATA" --add sata --controller IntelAhci
      VBoxManage storageattach "app" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "${path.module}/images/app-disk.vmdk"
      VBoxManage modifyvm "app" --natpf1 "ssh,tcp,,2222,,22"
      VBoxManage modifyvm "app" --natpf1 "http,tcp,,8080,,80"
      VBoxManage startvm "app" --type headless
      echo "ВМ app создана и запущена"
      
      # Создание ВМ db
      VBoxManage unregistervm "db" --delete 2>/dev/null || true
      VBoxManage createvm --name "db" --ostype Ubuntu_64 --register
      VBoxManage modifyvm "db" --memory 2048 --cpus 2 --nic1 nat --nic2 hostonly --hostonlyadapter2 vboxnet0
      VBoxManage storagectl "db" --name "SATA" --add sata --controller IntelAhci
      VBoxManage storageattach "db" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "${path.module}/images/db-disk.vmdk"
      VBoxManage modifyvm "db" --natpf1 "ssh,tcp,,2223,,22"
      VBoxManage startvm "db" --type headless
      echo "ВМ db создана и запущена"
      
      # Создание ВМ monitoring
      VBoxManage unregistervm "monitoring" --delete 2>/dev/null || true
      VBoxManage createvm --name "monitoring" --ostype Ubuntu_64 --register
      VBoxManage modifyvm "monitoring" --memory 1024 --cpus 1 --nic1 nat --nic2 hostonly --hostonlyadapter2 vboxnet0
      VBoxManage storagectl "monitoring" --name "SATA" --add sata --controller IntelAhci
      VBoxManage storageattach "monitoring" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "${path.module}/images/monitoring-disk.vmdk"
      VBoxManage modifyvm "monitoring" --natpf1 "ssh,tcp,,2224,,22"
      VBoxManage modifyvm "monitoring" --natpf1 "grafana,tcp,,3000,,3000"
      VBoxManage modifyvm "monitoring" --natpf1 "prometheus,tcp,,9090,,9090"
      VBoxManage startvm "monitoring" --type headless
      echo "ВМ monitoring создана и запущена"
      
      echo "Все ВМ успешно созданы!"
    EOT
  }
}

# Удаление ВМ при destroy
resource "null_resource" "destroy_vms" {
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      VBoxManage controlvm "app" poweroff 2>/dev/null || true
      VBoxManage unregistervm "app" --delete 2>/dev/null || true
      VBoxManage controlvm "db" poweroff 2>/dev/null || true
      VBoxManage unregistervm "db" --delete 2>/dev/null || true
      VBoxManage controlvm "monitoring" poweroff 2>/dev/null || true
      VBoxManage unregistervm "monitoring" --delete 2>/dev/null || true
      
      # Удаление копий дисков
      rm -f "${path.module}/images/app-disk.vmdk"
      rm -f "${path.module}/images/db-disk.vmdk"
      rm -f "${path.module}/images/monitoring-disk.vmdk"
      
      echo "Все ВМ удалены"
    EOT
  }
}
