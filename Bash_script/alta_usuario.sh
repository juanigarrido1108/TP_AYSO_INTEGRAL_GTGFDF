#!/bin/bash

LOG_FILE="alta_usuario.log"
echo "-- Alta de Ususarios --" | tee -a "$LOG_FILE"

read -p "Ingrese Usuario a crear " usuario

# estos if verican si el usuario existe y SI NO existe  crea uno
if id "$usuario" &>/dev/null;then
  echo"$(date): '$usuario' usuario ya existente " | tee x-a "LOG_FILE"
else
  sudo useradd -m "$usuario"
  echo "$(date): '$usuario' su usario a si creado correctamente " | tee -a "$LOG_FILE"

  read -s -p "Ingrese Contrasena para '$usuario' :" pass
  echo
  echo "$usuario:$pass" | sudo chpasswd
  echo "$(date): contrasena guardada para '$usuario'" | tee -a "LOG_FILE"
fi


