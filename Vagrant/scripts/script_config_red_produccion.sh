#!/usr/bin/env bash
set -e

# --- Parámetros de interfaz y red ---
CONN_NAME="Wired connection 1"    # Nombre tal cual aparece en `nmcli connection show`
IP_CIDR="192.168.56.6/24"         # IP que definimos en vagrantfile + máscara
AUTOCONNECT="yes"                 # Que se levante al reiniciar

echo "Configurando red estática en '$CONN_NAME' …"

# 1) Cambiar método a manual y fijar IP
#No definimos gateway ni dns porque al hacerlo nos limita la salida a internet.
#Solo definimos ip, dejamos vacios los campos para que tome lo predeterminado por vagrant.
sudo nmcli connection modify "$CONN_NAME" \
  ipv4.method manual \
  ipv4.addresses "$IP_CIDR" \
  ipv4.gateway "" \
  ipv4.dns     "" \
  connection.autoconnect "$AUTOCONNECT"

# 2) Reiniciar la conexión para aplicar los cambios
sudo nmcli connection down "$CONN_NAME"
sudo nmcli connection up   "$CONN_NAME"

echo "Interfaz '$CONN_NAME' ahora con IP $(nmcli -g IP4.ADDRESS connection show "$CONN_NAME")"