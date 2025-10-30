#!/bin/bash

# sudo apt-get update -y

# ## Instalação do Jenkins
# sudo apt install fontconfig openjdk-21-jre -y
# sudo apt install wget git -y
# sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
#   https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
# echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
#   https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
#   /etc/apt/sources.list.d/jenkins.list > /dev/null
# sudo apt update
# sudo apt install jenkins -y
# sudo systemctl daemon-reload
# sudo systemctl enable jenkins
# sudo systemctl start jenkins

# ## Instalação do Docker e do Docker Compose
# echo "Add Docker's official GPG key:"
# sudo apt-get install -y ca-certificates curl
# sudo install -m 0755 -d /etc/apt/keyrings
# sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
# sudo chmod a+r /etc/apt/keyrings/docker.asc

# echo "Add the repository to Apt sources:"
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#   $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
#   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update -y

# echo "Install Docker Engine, containerd, and Docker Compose:"
# sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# echo "Start and enable Docker service"
# sudo systemctl start docker
# sudo systemctl enable docker

# echo "Install Docker Compose"
# sudo apt-get install docker-compose-plugin -y

# # O Jenkins por padrão não pode executar comandos docker, é necessário que se dê permissão para o usuário do Jenkins ter acesso ao socket do Docker:
# sudo usermod -aG docker jenkins
# sudo systemctl restart jenkins

# # ---------------- Instalar o SonarScanner ----------------
# # Faz o download e instala o SonarScanner versão 6.2
# sudo apt install -y unzip wget
# wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-6.2.0.4584-linux-x64.zip
# unzip sonar-scanner-cli-6.2.0.4584-linux-x64.zip -d /opt/
# mv /opt/sonar-scanner-6.2.0.4584-linux-x64 /opt/sonar-scanner
# chown -R jenkins:jenkins /opt/sonar-scanner
# echo 'export PATH=$PATH:/opt/sonar-scanner/bin' | sudo tee -a /etc/profile

# # ---------------- Instalar Node.js (via NVM) ----------------
# # Instala a versão 10 do Node.js
# curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
# sudo apt install -y nodejs

# ---------------- Instalar Nexus via Docker ----------------
docker volume create --name nexus-data
docker run -d -p 8091:8081 -p 8123:8123 --name nexus -v nexus-data:/nexus-data sonatype/nexus3
