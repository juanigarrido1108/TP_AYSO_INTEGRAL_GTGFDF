#!/usr/bin/env bash
set -e

UBUNTU="192.168.56.5"
FEDORA="192.168.56.6"

echo "1. Configurar hosts…" 
sudo tee -a /etc/hosts > /dev/null <<EOF
192.168.56.5 ubuntu-testing
192.168.56.6 fedora-production
EOF

echo "2. Generar claves SSH sin interacción…"

# genera la clave SI NO existe (quiet, sin preguntar)
[ -f ~/.ssh/id_rsa ] || ssh-keygen -q -t rsa -N "" -f ~/.ssh/id_rsa

for HOST in 192.168.56.5 192.168.56.6; do
  sshpass -p vagrant ssh-copy-id \
    -o StrictHostKeyChecking=no \
    -i ~/.ssh/id_rsa.pub \
    vagrant@$HOST
done

echo "3. Configurar sudo sin contraseña…"
for HOST in "$UBUNTU" "$FEDORA"; do
  ssh -o StrictHostKeyChecking=no vagrant@"$HOST" <<'EOH'
    echo 'vagrant ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/vagrant
    sudo chmod 440 /etc/sudoers.d/vagrant
EOH
done

echo "Passwordless SSH y sudoers configurados con éxito."

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