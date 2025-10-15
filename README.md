# DevOps Studies

## Instalar o Oracle VM VirtualBox Manager

Seguir passo a passo do site: https://www.virtualbox.org/wiki/Downloads

## Instalar Vagrant

### Instalação

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