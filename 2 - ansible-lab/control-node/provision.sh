#!/bin/sh

sudo apt update
echo "Início da instalação do Ansible"
sudo apt install -y ansible

cat <<EOT | sudo tee -a /etc/hosts
192.168.56.10 control-node
192.168.56.11 app01
192.168.56.12 db01
EOT
