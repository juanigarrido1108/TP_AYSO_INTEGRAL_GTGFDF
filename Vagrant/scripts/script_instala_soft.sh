#!/usr/bin/env bash
set -e

# 4. Instalar software necesario
echo
echo "4. Instalando software necesario"
echo "Instalando software en Ubuntu..."
ssh vagrant@"$UBUNTU" << 'EOF'
sudo apt update
sudo apt install -y git vim curl wget docker.io python3 nodejs nginx mysql-server htop tree net-tools
sudo systemctl enable docker
sudo usermod -aG docker vagrant
EOF

echo "Instalando software en Fedora..."
ssh vagrant@"$FEDORA" << 'EOF'
sudo dnf update -y
sudo dnf install -y git vim curl wget docker python3 nodejs nginx mysql-server htop tree net-tools
sudo systemctl enable docker
sudo usermod -aG docker vagrant
EOF

echo "Software instalado en ambas VMs"
