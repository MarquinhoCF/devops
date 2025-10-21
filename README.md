# DevOps Studies

## Instalar o Oracle VM VirtualBox Manager

Seguir passo a passo do site: https://www.virtualbox.org/wiki/Downloads

## Explorando Vagrant - Criação do Vagrant Lab

### Instalação do Vagrant

Seguir passo a passo do site: https://developer.hashicorp.com/vagrant/install

### Instalação do plugin vbguest

```
vagrant plugin install vagrant-vbguest
```

### Configuração do Vagrant

```
vagrant init
# Definir as configurações no Vagrantfile
```

Iniciando a Máquina Virtual:

```
vagrant up
```

Para acessar a VM:

```
vagrant ssh

exit # Para sair da VM
```

## 🧰 Comandos principais do Vagrant

### 💤 **1️⃣ Suspender (pausar o estado atual)**

```bash
vagrant suspend
```

* Salva o estado atual da VM (RAM, CPU, etc) em disco.
* Retoma rápido depois com:

  ```bash
  vagrant resume
  ```

✅ Ideal se você quer **voltar exatamente de onde parou**.

---

### ⚙️ **2️⃣ Desligar (shutdown limpo do SO)**

```bash
vagrant halt
```

* Envia um **`shutdown -h now`** para a VM.
* Mantém os discos e o estado da VM intactos.
* Depois você pode ligá-la novamente com:

  ```bash
  vagrant up
  ```

✅ É o jeito mais comum e seguro de **parar uma VM** sem perder nada.

---

### 💣 **3️⃣ Destruir (apagar completamente a VM)**

```bash
vagrant destroy
```

* Desliga e **remove completamente** a VM do VirtualBox (ou outro provider).
* Você perde tudo dentro da VM (mas seus playbooks, arquivos locais etc. continuam na pasta do host).
  ✅ Use quando quiser **recriar o ambiente do zero**.

---

### 🧱 **4️⃣ Forçar parada imediata (caso trave)**

```bash
vagrant halt -f
```

ou

```bash
vagrant destroy -f
```

* **Força** o desligamento sem esperar resposta do sistema.
  ⚠️ Pode corromper o estado se estiver gravando no disco, então use só se a VM travar.

---

### 🧩 **5️⃣ Ver o status das VMs**

```bash
vagrant status
```

Exemplo de saída:

```
Current machine states:

control-node        running (virtualbox)
db-node             poweroff (virtualbox)
```

## Criação do Ansible Lab

Criação das máquinas Control Node, App01 e Db01:

* Control Node: Ansible e playbooks
* App01:
    * Java – OpenJDK – Notes App (REST)
    * Maven
* Db01: MySQL

```
mkdir 2\ -\ ansible-lab
cd 2\ -\ ansible-lab/
mkdir control-node
mkdir app01
mkdir db01
```

Configuração dos Vagrantfile's de cada máquina e subir cada um com:

```
vagrant up
```

### Control Node

Verificar se o control-node foi iniciado com sucesso:

```
cd control-node
vagrant ssh
```

1. Verificar se o ansible foi instalado

```
ansible --version
```

2. Verificar se o hosts foram configurados corretamente

```
cat etc/hosts
```

### App01

Verificar se a rede privada está funcionando corretamente. 

Executar ping no Control Node:

```
cd app01
vagrant ssh
ping 192.168.56.10
# Verificar se os pacotes estão sendo transmitidos
exit

cd control-node
vagrant ssh
ping 192.168.56.11
# Verificar se os pacotes estão sendo transmitidos
exit
```

### Db01

Verificar se a rede privada está funcionando corretamente. 

Executar ping no Control Node:

```
cd db01
vagrant ssh
ping 192.168.56.10
# Verificar se os pacotes estão sendo transmitidos
exit

cd control-node
vagrant ssh
ping 192.168.56.12
# Verificar se os pacotes estão sendo transmitidos
exit
```

### Configurando arquivo de inventário do Ansible

```
cd control-node
vagrant ssh
sudo nano /etc/ansible/hosts
```

Adicionar as linhas abaixo:

```
[apps]
app01
[dbs]
db01
```

### Configurando acesso do Control Node aos managed nodes

Criar uma chave ssh:

``` 
cd control-node
vagrant ssh
ssh-keygen
# Não é necessário passar um path e nem senha
```

Verificar se a chave ssh foi criada corretamente

```
ls -lha
cd ~/.ssh/
ls
```

Copiar valor da chave ssh pública:

```
cat id_rsa.pub
```

Adicionar a chave pública no proviosionamento do App01 e Db01:

Adicionando o arquivo `provision.sh`:

```
cat <<EOT | sudo tee -a /home/vagrant/.ssh/authorized_keys
ssh-rsa <SUA_CHAVE> = vagrant@control-node
EOT
```

Adicionar a linha no Vagrantfile do App01 e Db01:

```
config.vm.provision "shell", path: "provision.sh"
```

E reiniciar e forçar o provisionamento das VM:

``` 
vagrant provision

```

Teste tentando acessar as VMs App01 e Db01 a partir do Control Node:

```
ssh vagrant@app01
ssh vagrant@db01
```

E depois tente:

```
ansible -m ping all
```

#### Troubleshotting

Caso seja necessário destrua a máquina antiga e inicie outra:

```
vagrant destroy -f
vagrant up
```

Caso você esbarre no problema de ataque *man-in-the-middle*. No é o nosso caso, não é um ataque, é só que o Vagrant recriou a VM, então a chave pública dela mudou.

```
ssh-keygen -f "/home/vagrant/.ssh/known_hosts" -R "db01" # Ou app01
ssh vagrant@db01 # Ou app01
```

### Criando os playbooks

**Estrutura dos Playbooks**

```
2\ -\ ansible-lab/
├── control-node/
│   ├── Vagrantfile
│   ├── provision.sh
│   └── playbooks/
|       ├── handlers/
|       ├── roles/
│       |   └── configuracao-default-so/
│       |       └── main.yml
│       |
|       ├── templates/
│       |   ├── etc/systemd/system
│       |   |   └── notes.service
│       |   └── application.properties
│       |
|       ├── vars/
│       |   └── main.yml
│       |
│       ├── app.yml
│       └── db.yml
│
├── app-node/
│   └── Vagrantfile
│
└── db-node/
    └── Vagrantfile
```

Procurar no **Ansible Galaxy** roles prontas para instalar o banco MySQL. 

Encontrado `geerlingguy.mysql` -> Seguir a documentação: https://galaxy.ansible.com/ui/standalone/roles/geerlingguy/mysql/install/

Instalar:

```shell
ansible-galaxy role install geerlingguy.mysql
```

Testar execução do playbook com:

```shell
ansible-playbook db.yml --check
ansible-playbook app.yml --check
```

Ou executar os playbooks com em `dry-run` com `--check` o sistema reclamará de possíveis erros, realize o Troubleshotting se necessário. Ao resolver os problemas execute os playbooks:

```shell
ansible-playbook db.yml
ansible-playbook app.yml
```

Verificar se a aplicação está no ar:

```shell
cd 2\ -\ ansible-lab/app01
vagrant ssh
service notes status
ps aux | grep java
```

#### Troubleshotting

Caso encontre problemas de incompatibilidade, considere atualizar a versão do **Ansible**:

```shell
pip install --upgrade ansible
```

### Testando a aplicação

Realizar algumas requisições para testar o funcionamento da aplicação:

#### Cadastro de uma nota:

`note.json`
```json
{
    "title": "Aula de Ansible",
    "content": "Estudar Ansible amanhã"
}
```

```shell
curl -H "Content-Type: application/json" --data @note.json http://app01:8080/api/notes
```

#### Listagem de Notas:

```shell
curl http://app01:8080/api/notes
```

#### Deleção de Notas:

```shell
curl -X DELETE -H "Content-Type: application/json" http://app01:8080/api/notes/1
```

## Criação do Docker Lab

Criação da Máquina Virtual com Docker:

```shell
mkdir 2\ -\ ansible-lab
cd 2\ -\ ansible-lab/
vargrant init
```

Configurar o arquivo Vagrant e subir a VM, instalar o Docker. Logo depois verifique com:

```shell
vagrant ssh
docker --version
docker compose version
sudo systemctl status docker
```

### Montagem do Dockerfile

Definir o Dockerfile:

```Dockerfile
FROM openjdk:8-jdk-alpine
RUN addgroup -S notes && adduser -S notes -G notes
USER notes:notes
ARG JAR_FILE=*.jar
COPY ${JAR_FILE} easy-note.jar
COPY application.properties application.properties
ENTRYPOINT ["java","-jar","/easy-note.jar"]
```

Copia-lo para dentro da VM com:

```shell
vagrant ssh
sudo su -
nano Dockerfile
# Copie o conteúdo do Dockerfile do host para a VM
```

Copiar o arquivo `JAR` da VM App01 do laboratório de Ansible:

```shell
cd 2\ -\ ansible-lab/app01/
vagrant up
vagrant ssh-config 
# Descobrir a porta no caso: 2201
scp -i "/home/marcos/devops/2 - ansible-lab/app01/.vagrant/machines/default/virtualbox/private_key" -P 2201 vagrant@127.0.0.1:/opt/notes/target/easy-notes-1.0.0.jar .
# Caso peça a senha a senha é 'vagrant'
cp easy-notes-1.0.0.jar ../../3\ -\ docker-lab/
rm easy-notes-1.0.0.jar
```

Criar o arquivo `application.properties`.

Copiar os arquivos `application.properties` e `easy-notes-1.0.0.jar` para a VM:

```shell
vagrant upload application.properties /tmp/
vagrant upload easy-notes-1.0.0.jar /tmp/easy-note.jar
sudo cp /tmp/application.properties /root/
sudo cp /tmp/easy-note.jar /root/
sudo rm -rf /tmp
```

Executar e buildar a imagem Docker:

```shell
sudo su -
docker build -t devops/notes .
```

Verificar a imagem Docker:

```shell
docker images
```

### Montagem do Dockerfile para compilar o app Java

Criar o novo Dockerfile:

```Dockerfile
FROM openjdk:11-jdk-slim
RUN addgroup --system notes && adduser --system --ingroup notes notes
RUN apt-get update && apt-get install -y wget tar
ENV MAVEN_VERSION=3.5.4
ENV MAVEN_HOME=/usr/lib/mvn
ENV PATH=$MAVEN_HOME/bin:$PATH
RUN wget http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    tar xzvf apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    rm apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    mv apache-maven-$MAVEN_VERSION $MAVEN_HOME
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
RUN mkdir /opt/notes
RUN chown -R notes:notes /opt/notes
USER notes:notes
WORKDIR /opt/notes
RUN git clone https://github.com/callicoder/spring-boot-mysql-rest-api-tutorial.git /opt/notes
RUN mvn package -f /opt/notes/pom.xml -Dmaven.test.skip=true
ARG JAR_FILE=*.jar
RUN cp ./target/easy-notes-1.0.0.jar /opt/notes/easy-note.jar
COPY application.properties application.properties
ENTRYPOINT ["java","-jar","/opt/notes/easy-note.jar"]
```

Executar o Dockerfile na VM:

```shell
vagrant ssh
sudo su -u
mkdir docker-compile
cd docker-compile
cp ../application.properties .
nano Dockerfile
# Copiar o conteúdo para o arquivo
docker build -t devops/notes .
```

Verificar a imagem Docker:

```
docker images
```

### Como utilizar builds Multiestágio

Para reduzir o tamnho das imagens podemos utilizar o conceito de beuild multi estágio.

Essa técnica consiste em usar várias imagens (estágios) dentro da mesma build, para separar o processo de compilação da aplicação (que precisa de ferramentas como git, maven, gcc, etc) do ambiente de execução final (que precisa apenas do binário/jar pronto).

Para realizar isso crie o Dockerfile:

```Dockerfile
FROM maven:3.9.9-eclipse-temurin-11 AS buildstage
RUN mkdir /opt/notes
WORKDIR /opt/notes
RUN git clone https://github.com/callicoder/spring-boot-mysql-rest-api-tutorial.git /opt/notes
RUN mvn package -f /opt/notes/pom.xml -Dmaven.test.skip=true

FROM eclipse-temurin:11-jre-alpine
RUN addgroup -S notes && adduser -S notes -G notes
RUN mkdir /opt/notes
RUN chown -R notes:notes /opt/notes
USER notes:notes
WORKDIR /opt/notes
COPY --from=buildstage /opt/notes/target/easy-notes-1.0.0.jar .
COPY application.properties application.properties
ENTRYPOINT ["java","-jar","/opt/notes/easy-notes-1.0.0.jar"]
```

Executar o Dockerfile na VM:

```shell
vagrant ssh
sudo su -u
mkdir docker-multi-stage
cd docker-multi-stage
cp ../application.properties .
nano Dockerfile
# Copiar o conteúdo para o arquivo
docker build -t devops/notes .
```

Verificar a imagem Docker:

```
docker images
```

### Exemplo de configuração para aplicação em NodeJS

1. Compilar aplicação NodeJS

2. Conectar NodeJS ao Redis - container apartado

Criar aplicação NodeJS + Redis em `3 - docker-lab/node-app/visits-app`.

Fazer upload dos arquivos para a VM

```shell
vagrant upload visits-app/ /tmp
vagrant ssh
sudo su -
cd /tmp
mkdir /root/visits-app
cp Dockerfile index.js package.json /root/visits-app/
rm Dockerfile index.js package.json
cd /root/visits-app/
docker build -t devops/visits-app .
```

E preciso criar uma rede para que o servidor Node se comunique com o Redis:

```shell
docker network create devops
```

Criar os containers com NodeJS e Redis utilizando a rede:

```shell
docker run --net devops --name redis-server -d redis
docker run --net devops -p 8080:8081 -d devops/visits-app
```

Para verificar se os container estão rodando corretamente:

```shell
# Obtenha o id dos containers com:
docker ps
docker logs -f <id_da_imagem>
```

Para usar o servidor utilize:

```
curl http://localhost:8080/
```

#### Utilização do Docker Compose

Docker Compose é uma ferramenta do Docker que permite definir e executar múltiplos containers como um único aplicativo.

Você usa um arquivo chamado docker-compose.yml para descrever:

* quais imagens usar,

* quais portas expor,

* quais volumes montar,

e como os containers se conectam entre si (rede interna automática).

Observe o exemplo abaixo:

```yml
version: '3'
services:
  redis-server:
    image: "redis"
  visits-app:
    build: .
    ports:
      - "8080:8081"
    depends_on:
      - redis-server
```

OBS: Perceba que não foi definido uma rede para que os 2 containers se comunicassem. Nesse exemplo a rede é definida automaticamente pelo próprio docker compose:

```shell
cd 3\ -\ docker-lab/node-app
vagrant upload visits-app/docker-compose.yml /tmp/
vagrant ssh
sudo su -
cp /tmp/docker-compose.yml /root/visits-app
cd /tmp/
rm docker-compose.yml
cd ../root/visits-app
```

Para limpar o ambiente do docker utilize o Docker prune:

```shell
docker system prune
docker volume prune
```

Subir o ambiente:

```shell
docker-compose up
# Use "-d" para executar em background
```

Verifique a rede criada automaticamente:

```shell
docker network ls
```

Para destruir e parar os containers utilize:

```shell
docker-compose down
```

### Utilizando Volumes para persistir dados de um container

Testando a criação de um volume. Crie uma instância do Ubuntu 22.04 em modo iterativo passando um diretório como volume:

```shell
mkdir upload-images
docker run -i -t -v /root/upload-images:/upload-images ubuntu:22.04
cd upload-images/
touch teste.txt
exit
cd upload-images/
ls # Você verá que o arquivo criado foi persistido no diretório
```

### Introdução ao Docker Swarm - Orquestração de Containers

Vamos montar um cluster Docker Swarm completo, simulando um ambiente real de orquestração distribuída

| Máquina | IP            | Função         | Porta Exposta | Papel no Swarm |
| ------- | ------------- | -------------- | ------------- | -------------- |
| manager | 192.168.56.10 | Coordenador    | 80 → 8090     | Manager        |
| worker1 | 192.168.56.11 | Nó de trabalho | —             | Worker         |
| worker2 | 192.168.56.12 | Nó de trabalho | —             | Worker         |

Vamos subir o cluster com:

```shell
cd docker-swarm-lab
vagrant up
```

Vamos checar se o cluster foi corretamente criado:

```shell
vagrant ssh manager
# Verificar se o manger consegue se comunicar com os workers
ping 192.168.56.11
ping 192.168.56.12
```

Comandos de execução:

```shell
# Executar no host manager
docker swarm init --advertise-addr 192.168.56.10
# Executar nos hosts worker1 e worker2:
docker swarm join --token <TOKEN> 192.168.56.10:2377
# Executar no host manager - para listar os nodes do cluster
docker node ls
```

Criando um serviço no cluster:

```shell
# Criar
docker service create --name demo --publish 80:80 nginx

# Listar serviços criados
docker service ls
docker service ps demo

# Escalar o serviço
docker service scale demo=3

# Visualizar o serviço distribuído pelo cluster
docker service ps demo
```

Abrir a página do Nginx (na máquina fisica): http://localhost:8090

Para matar um cluster do Swarm execute em cada nó do cluster (tanto manager quanto workers):

```shell
# Nos workers:
docker swarm leave

# No manager:
docker swarm leave --force # o Force é ncessário para desfazer o cluster se ainda existirem outros nós conectados
```