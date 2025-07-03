#!/bin/bash
# config_vm.sh - Configuración completa de VMs Vagrant

# Variables de configuración
UBUNTU=”192.168.56.5”

FEDORA="192.168.56.6”

echo "Configurando VMs Vagrant"

# Configurar /etc/hosts
echo ""
echo "1. Configurando /etc/hosts"

sudo cp /etc/hosts 
echo "”192.168.56.5”   ubuntu-testing" | sudo tee -a /etc/hosts
echo "192.168.56.6”   fedora-production" | sudo tee -a /etc/hosts

echo "VMs agregadas a /etc/hosts"

# Configurar SSH sin contraseña
echo ""
echo "2. Configurando SSH sin contraseña"

echo "Generando claves SSH..."
ssh vagrant@$UBUNTU "ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''"
ssh vagrant@$FEDORA "ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''"

echo "Intercambiando claves SSH..."
ssh vagrant@$UBUNTU "cat ~/.ssh/id_rsa.pub" | ssh vagrant@$FEDORA "cat >> ~/.ssh/authorized_keys"
ssh vagrant@$FEDORA "cat ~/.ssh/id_rsa.pub" | ssh vagrant@$UBUNTU "cat >> ~/.ssh/authorized_keys"

echo "SSH sin contraseña configurado"

echec
# Configurar sudo sin contraseña
echo ""
echo "3. Configurando sudo sin contraseña"

echo "Configurando sudo en Ubuntu..."
ssh vagrant@$UBUNTU "echo 'vagrant ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/vagrant"

echo "Configurando sudo en Fedora..."
ssh vagrant@$FEDORA "echo 'vagrant ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/vagrant"

echo "Sudo sin contraseña configurado"

# Instalar software necesario
echo ""
echo "4. Instalando software necesario"

echo "Instalando software en Ubuntu..."
ssh vagrant@$UBUNTU << 'EOF'
sudo apt update
sudo apt install -y git vim curl wget docker.io python3 nodejs nginx mysql-server htop tree net-tools
sudo systemctl enable docker
sudo usermod -aG docker vagrant
EOF

echo "Instalando software en Fedora..."
ssh vagrant@$FEDORA << 'EOF'
sudo dnf update -y
sudo dnf install -y git vim curl wget docker python3 nodejs nginx mysql-server htop tree net-tools
sudo systemctl enable docker
sudo usermod -aG docker vagrant
EOF

echo "Software instalado en ambas VMs"


