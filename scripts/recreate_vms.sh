#!/bin/bash

set -e

echo "=== Полное пересоздание ВМ ==="

# Остановка ВМ
for VM in app db monitoring; do
    echo "Остановка $VM..."
    VBoxManage controlvm "$VM" poweroff 2>/dev/null || true
done
sleep 5

# Удаление ВМ
for VM in app db monitoring; do
    echo "Удаление $VM..."
    VBoxManage unregistervm "$VM" --delete 2>/dev/null || true
done

# Закрытие и удаление старых дисков
cd ~/graduation_paper_B/infra/terraform/images
echo "Очистка старых дисков..."
VBoxManage closemedium disk "app-disk.vmdk" 2>/dev/null || true
VBoxManage closemedium disk "db-disk.vmdk" 2>/dev/null || true
VBoxManage closemedium disk "monitoring-disk.vmdk" 2>/dev/null || true
rm -f app-disk.vmdk db-disk.vmdk monitoring-disk.vmdk

# Создание новых копий через qemu-img
echo "Создание новых дисков..."
qemu-img convert -f vmdk -O vmdk ubuntu-24.04.vmdk app-disk.vmdk
qemu-img convert -f vmdk -O vmdk ubuntu-24.04.vmdk db-disk.vmdk
qemu-img convert -f vmdk -O vmdk ubuntu-24.04.vmdk monitoring-disk.vmdk

# Создание ВМ app
echo "Создание ВМ app..."
VBoxManage createvm --name "app" --ostype Ubuntu_64 --register
VBoxManage modifyvm "app" --memory 2048 --cpus 2 --nic1 nat --nic2 hostonly --hostonlyadapter2 vboxnet0
VBoxManage storagectl "app" --name "SATA" --add sata --controller IntelAhci
VBoxManage storageattach "app" --storagectl "SATA" --port 0 --device 0 --type hdd --medium ~/graduation_paper_B/infra/terraform/images/app-disk.vmdk
VBoxManage modifyvm "app" --natpf1 "ssh,tcp,,2222,,22"
VBoxManage modifyvm "app" --natpf1 "http,tcp,,8080,,80"

# Создание ВМ db
echo "Создание ВМ db..."
VBoxManage createvm --name "db" --ostype Ubuntu_64 --register
VBoxManage modifyvm "db" --memory 2048 --cpus 2 --nic1 nat --nic2 hostonly --hostonlyadapter2 vboxnet0
VBoxManage storagectl "db" --name "SATA" --add sata --controller IntelAhci
VBoxManage storageattach "db" --storagectl "SATA" --port 0 --device 0 --type hdd --medium ~/graduation_paper_B/infra/terraform/images/db-disk.vmdk
VBoxManage modifyvm "db" --natpf1 "ssh,tcp,,2223,,22"

# Создание ВМ monitoring
echo "Создание ВМ monitoring..."
VBoxManage createvm --name "monitoring" --ostype Ubuntu_64 --register
VBoxManage modifyvm "monitoring" --memory 1024 --cpus 1 --nic1 nat --nic2 hostonly --hostonlyadapter2 vboxnet0
VBoxManage storagectl "monitoring" --name "SATA" --add sata --controller IntelAhci
VBoxManage storageattach "monitoring" --storagectl "SATA" --port 0 --device 0 --type hdd --medium ~/graduation_paper_B/infra/terraform/images/monitoring-disk.vmdk
VBoxManage modifyvm "monitoring" --natpf1 "ssh,tcp,,2224,,22"
VBoxManage modifyvm "monitoring" --natpf1 "grafana,tcp,,3000,,3000"
VBoxManage modifyvm "monitoring" --natpf1 "prometheus,tcp,,9090,,9090"

# Запуск ВМ
echo "Запуск всех ВМ..."
VBoxManage startvm "app" --type headless
VBoxManage startvm "db" --type headless
VBoxManage startvm "monitoring" --type headless

echo "=== Готово! ==="
VBoxManage list runningvms
