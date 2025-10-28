#!/bin/bash
# Script para instalar e configurar o SonarQube como um serviço no Ubuntu

# Cria um novo usuário chamado 'sonarqube' (sem senha ou diretório home)
useradd sonarqube

# Atualiza a lista de pacotes disponíveis
sudo apt update

# Instala o Java 17 (necessário para o SonarQube), além de unzip e wget
sudo apt install -y openjdk-17-jdk unzip wget

# ---------------- Instalação do SonarQube ----------------
# Faz o download da versão 25.10.0.114319 do SonarQube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-25.10.0.114319.zip
unzip sonarqube-25.10.0.114319.zip -d /opt/
sudo mv /opt/sonarqube-25.10.0.114319 /opt/sonarqube

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
# Faz o download e instala o SonarScanner versão 7.3
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-7.3.0.5189-linux-x64.zip
unzip sonar-scanner-cli-7.3.0.5189-linux-x64.zip -d /opt/
mv /opt/sonar-scanner-7.3.0.5189-linux-x64 /opt/sonar-scanner
chown -R sonarqube:sonarqube /opt/sonar-scanner
echo 'export PATH=$PATH:/opt/sonar-scanner/bin' | sudo tee -a /etc/profile

# ---------------- Instalar Node.js (via NVM) ----------------
# Instala o NVM (Node Version Manager) e depois instala a versão 10 do Node.js
curl -sL https://rpm.nodesource.com/setup_lts.x | bash -
sudo apt install -y nodejs