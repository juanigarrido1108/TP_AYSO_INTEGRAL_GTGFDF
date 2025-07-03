#!/usr/bin/env bash
set -e

# --- Parámetros de interfaz y red ---
CONN_NAME="Wired connection 1"    # Nombre tal cual aparece en `nmcli connection show`
IP_CIDR="192.168.56.6/24"         # IP estática + máscara
GATEWAY="192.168.56.1"            # Puerta de enlace de la red host-only
DNS="192.168.56.1"                # DNS (puede ser el gateway)
AUTOCONNECT="yes"                 # Que se levante al reiniciar

echo "Configurando red estática en '$CONN_NAME' …"

# 1) Cambiar método a manual y fijar IP/Gateway/DNS
sudo nmcli connection modify "$CONN_NAME" \
  ipv4.method manual \
  ipv4.addresses $IP_CIDR \
  ipv4.gateway  $GATEWAY \
  ipv4.dns      $DNS \
  connection.autoconnect $AUTOCONNECT

# 2) Reiniciar la conexión para aplicar los cambios
sudo nmcli connection down "$CONN_NAME"
sudo nmcli connection up   "$CONN_NAME"

echo "✔ Interfaz '$CONN_NAME' ahora con IP $(nmcli -g IP4.ADDRESS connection show "$CONN_NAME")"
