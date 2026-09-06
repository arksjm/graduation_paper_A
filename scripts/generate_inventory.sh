#!/bin/bash

# Создаем inventory файл
mkdir -p ../ansible/inventory

cat > ../ansible/inventory/hosts.yml << 'INVENTORY'
all:
  hosts:
    app:
      ansible_host: 192.168.56.10
      ansible_user: vagrant
      ansible_ssh_private_key_file: ~/.ssh/id_ed25519
      ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
    db:
      ansible_host: 192.168.56.11
      ansible_user: vagrant
      ansible_ssh_private_key_file: ~/.ssh/id_ed25519
      ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
    monitoring:
      ansible_host: 192.168.56.12
      ansible_user: vagrant
      ansible_ssh_private_key_file: ~/.ssh/id_ed25519
      ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
  children:
    app_group:
      hosts:
        app:
    db_group:
      hosts:
        db:
    monitoring_group:
      hosts:
        monitoring:
INVENTORY

echo "Inventory создан в ansible/inventory/hosts.yml"
