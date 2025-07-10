#!/usr/bin/env bash
set -euo pipefail

ANSIBLE_DIR="/home/vagrant/compartido/Ansible"

echo "��� 1) Verificando que $ANSIBLE_DIR exista…"
if [[ ! -d "$ANSIBLE_DIR" ]]; then
  echo "❌ Directorio $ANSIBLE_DIR no encontrado"
  exit 1
fi

echo "��� 2) Instalando dos2unix si falta…"
if ! command -v dos2unix &>/dev/null; then
  sudo apt-get update -qq
  sudo apt-get install -y dos2unix
else
  echo "   ✓ dos2unix ya instalado"
fi

echo "��� 3) Normalizando playbooks y roles (CRLF → LF)…"
find "$ANSIBLE_DIR" -type f \
     \( -iname '*.yml' -o -iname '*.yaml' -o -iname '*.py' \) \
  -exec dos2unix -q {} +

echo "��� 4) Normalizando los módulos internos de Ansible…"
# Descubre dónde está ansible.module_utils en el control node
MODULE_UTILS_DIR=$(
  python3 - <<'PYCODE'
import ansible.module_utils, os
print(os.path.dirname(ansible.module_utils.__file__))
PYCODE
)
echo "   → Encontrado en $MODULE_UTILS_DIR"
sudo find "$MODULE_UTILS_DIR" -type f -name '*.py' -exec sudo dos2unix -q {} +

echo "��� 5) Ejecutando Ansible Playbook…"
ansible-playbook -i "$ANSIBLE_DIR/inventory" "$ANSIBLE_DIR/playbook.yml"

