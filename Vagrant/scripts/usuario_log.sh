#
clear

lista_usuarios=$1
LOG=LOG_FILE

ANT_IFS=$IFS
IFS=$'\n'
for LINEA in `cat $lista_usuarios |  grep -v ^#`
do
	usuario=$(echo  $LINEA |awk -F ',' '{print $1}')
	grupos=$(echo  $LINEA |awk -F ',' '{print $2}')

    if id "$usuario" &>/dev/null;then
        echo "$(date): '$usuario' usuario ya existente " | tee -a "$LOG_FILE"
    else
        sudo useradd -m -s /bin/bash -g $grupos $usuario

        echo "$(date): El usuario '$usuario' ha sido creado correctamente." | tee -a "$LOG_FILE"
    fi
done
IFS=$ANT_IFS