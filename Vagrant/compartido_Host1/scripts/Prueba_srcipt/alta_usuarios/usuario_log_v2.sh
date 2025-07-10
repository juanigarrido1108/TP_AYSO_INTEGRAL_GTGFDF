#!/bin/bash

clear

lista_usuarios="$1"
LOG_FILE="alta_usuario.log"

ANT_IFS=$IFS
IFS=$'\n'


# For recorre la lista y filtra la informacion necesaria.
for LINEA in $(cat "$lista_usuarios" | grep -v '^#'); do
    usuario=$(echo "$LINEA" | awk -F ',' '{print $1}')
    grupos=$(echo "$LINEA" | awk -F ',' '{print $2}')

    # Ignorar usuarios vacíos o con solo espacios
    if [[ -z "${usuario// /}" ]]; then
        continue
    fi

    # Validamos si exite usuario
    if id "$usuario" &>/dev/null; then
        echo "$(date): '$usuario' usuario ya existente" | tee -a "$LOG_FILE"
    else
        sudo useradd -m -s /bin/bash  "$usuario"
        echo "$(date): El usuario '$usuario' ha sido creado correctamente." | tee -a "$LOG_FILE"
    fi

    # Validamos si existe el grupo
    if getent group "$grupos" > /dev/null 2>&1; then
        echo "El grupo '$grupos' ya existe."
    else
        echo "El grupo '$grupos' no existe. Creándolo..." | tee -a "$LOG_FILE"
        sudo groupadd "$grupos"
    fi

    # Agregamos El Usuario al Grupo 
    sudo usermod -aG "$grupos" "$usuario"
    echo "$(date): Usuario:'$usuario' agregado a Gurpo:'$grupos' " | tee -a "$LOG_FILE"

    # # Eliminamos grupo primario predefinido con el mismo nombre de usuario
    # sudo groupdel "$usuario"
    # echo "$(date): Grupo:'$usario' ha sido eliminado y el grupo primario definido ahora es '$grupos' " | tee -a "$LOG_FILE"
done

IFS=$ANT_IFS

