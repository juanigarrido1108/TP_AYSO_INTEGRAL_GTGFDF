#!/usr/bin/env bash
set -e

TEST="192.168.56.5"
PROD="192.168.56.6"
USER="vagrant"
PASS="vagrant"

echo "0. Instalando sshpass en testing si falta…"
if ! command -v sshpass &> /dev/null; then
  sudo apt-get update -qq
  sudo apt-get install -y sshpass
fi

echo "1. Configurar hosts…" 
sudo tee -a /etc/hosts > /dev/null <<EOF
$TEST ubuntu-testing
$PROD fedora-production
EOF

echo "2. Generar par de llaves en testing si falta…"
[ -f ~/.ssh/id_rsa ] || ssh-keygen -q -t rsa -N "" -f ~/.ssh/id_rsa

echo "3. Copiar testing → producción…"
sshpass -p "$PASS" ssh-copy-id \
  -o StrictHostKeyChecking=no \
  -i ~/.ssh/id_rsa.pub \
  $USER@$PROD

# --- 4) Instalar sshpass y generar llaves en producción si falta ---
echo "4. Preparar producción (sshpass y llaves)…"
ssh -o StrictHostKeyChecking=no $USER@$PROD <<'EOH'
  # Instala sshpass si no existe
  if ! command -v sshpass &>/dev/null; then
    sudo dnf install -y sshpass
  fi

  # Genera llaves en producción si no existen
  mkdir -p ~/.ssh
  test -f ~/.ssh/id_rsa || ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa
EOH

echo "5. Copiar producción → testing…"

# 5.1) Copiar la pubkey de producción a un fichero temporal en testing
sshpass -p "$PASS" scp -o StrictHostKeyChecking=no \
  $USER@$PROD:~/.ssh/id_rsa.pub /tmp/prod.pub

# 5.2) Inyectar esa pubkey en testing
cat /tmp/prod.pub >> ~/.ssh/authorized_keys

# 5.3) Limpiar
rm -f /tmp/prod.pub

echo "✔ La clave pública de producción ya está registrada en testing."

# --- 6) Configurar sudo sin contraseña en testing y producción ---

echo "6a. Configurar sudo sin contraseña en testing…"
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/vagrant
sudo chmod 440 /etc/sudoers.d/vagrant

echo "6b. Configurar sudo sin contraseña en producción…"
ssh -o StrictHostKeyChecking=no vagrant@$PROD <<'EOH'
  echo 'vagrant ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/vagrant
  sudo chmod 440 /etc/sudoers.d/vagrant
EOH

echo "Llaves SSH cruzadas y sudo sin contraseña configurados."
