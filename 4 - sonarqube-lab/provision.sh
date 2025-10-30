#!/bin/bash
# Script para instalar e configurar o SonarQube como um serviço no Ubuntu

# Cria um novo usuário chamado 'sonarqube' (sem senha ou diretório home)
useradd sonarqube

# Atualiza a lista de pacotes disponíveis
sudo apt update

# Instala o Java 17 (necessário para o SonarQube), além de unzip e wget
sudo apt install -y openjdk-17-jdk unzip wget

# ---------------- Instalação do SonarQube ----------------
# Faz o download da versão 9.9.8.100196 do SonarQube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.8.100196.zip
unzip sonarqube-9.9.8.100196.zip -d /opt/
sudo mv /opt/sonarqube-9.9.8.100196 /opt/sonarqube

# Altera o dono da pasta /opt/sonarqube para o usuário e grupo 'sonarqube'
chown -R sonarqube:sonarqube /opt/sonarqube

# Cria (ou limpa) o arquivo de configuração do serviço systemd do SonarQube
touch /etc/systemd/system/sonarqube.service
echo > /etc/systemd/system/sonarqube.service

# Escreve o conteúdo da unidade de serviço systemd
cat <<EOT >> /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
User=sonarqube
Group=sonarqube
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
Restart=always

[Install]
WantedBy=multi-user.target
EOT

# Iniciar o serviço SonarQube e habilitá-lo para iniciar automaticamente na inicialização do sistema
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube

# ---------------- Instalar o SonarScanner ----------------
# Faz o download e instala o SonarScanner versão 6.2
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-6.2.0.4584-linux-x64.zip
unzip sonar-scanner-cli-6.2.0.4584-linux-x64.zip -d /opt/
mv /opt/sonar-scanner-6.2.0.4584-linux-x64 /opt/sonar-scanner
chown -R jenkins:jenkins /opt/sonar-scanner
echo 'export PATH=$PATH:/opt/sonar-scanner/bin' | sudo tee -a /etc/profile

# ---------------- Instalar Node.js ----------------
# Instala a versão 18 do Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs