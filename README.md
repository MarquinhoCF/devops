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
mkdir ansible-lab
cd ansible-lab/
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
ansible-lab/
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

```
ansible-galaxy role install geerlingguy.mysql
```

Testar execução do playbook com:

```
ansible-playbook db.yml --check
ansible-playbook app.yml --check
```

Ou executar os playbooks com em `dry-run` com `--check` o sistema reclamará de possíveis erros, realize o Troubleshotting se necessário. Ao resolver os problemas execute os playbooks:

```
ansible-playbook db.yml
ansible-playbook app.yml
```

Verificar se a aplicação está no ar:

```
cd ansible-lab/app01
vagrant ssh
service notes status
ps aux | grep java
```

#### Troubleshotting

Caso encontre problemas de incompatibilidade, considere atualizar a versão do **Ansible**:

```
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

```
curl -H "Content-Type: application/json" --data @note.json http://app01:8080/api/notes
```

#### Listagem de Notas:

```
curl http://app01:8080/api/notes
```

#### Deleção de Notas:

```
curl -X DELETE -H "Content-Type: application/json" http://app01:8080/api/notes/1
```