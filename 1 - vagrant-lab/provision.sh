#!/usr/bin/env bash

echo "=== Atualizando sistema e instalando Apache ==="
sudo apt update
sudo apt install -y apache2

# Copia arquivos
cp -r /vagrant/html/* /var/www/html/

# Inicia Apache
sudo systemctl enable apache2
sudo systemctl start apache2

echo "=== Apache instalado e rodando ==="
systemctl status apache2 --no-pager | grep Active
