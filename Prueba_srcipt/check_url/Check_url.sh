#!/bin/bash

ARCHIVO_URLS="urls.txt"

# Crear estructura de directorios
mkdir -p /tmp/head-check/{OK,Error/{cliente,servidor}}

# Verificar archivo de entrada
if [ ! -f "$ARCHIVO_URLS" ]; then
    echo "ERROR: El archivo '$ARCHIVO_URLS' no existe."
    exit 1
fi

echo "Verificando URLs..."
echo

while read -r DOMINIO URL; do
    [[ -z "$DOMINIO" || "$DOMINIO" =~ ^# ]] && continue

    # Agregar protocolo si no está
    [[ ! "$URL" =~ ^https?:// ]] && URL="http://$URL"

    # Obtener código HTTP y timestamp
    STATUS_CODE=$(curl -LI -o /dev/null -w "%{http_code}\n" -s "$URL")
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    LOG_LINE="$TIMESTAMP - Code:$STATUS_CODE - URL: ${URL#http://}"

    # Elegir ruta de log por código
    if [[ "$STATUS_CODE" == "200" ]]; then
        LOG_PATH="/tmp/head-check/OK/$DOMINIO.log"
        echo "$DOMINIO → $URL → $STATUS_CODE"

    elif [[ "$STATUS_CODE" =~ ^4 ]]; then
        LOG_PATH="/tmp/head-check/Error/cliente/$DOMINIO.log"
        echo "$DOMINIO → $URL → Cliente $STATUS_CODE"

    elif [[ "$STATUS_CODE" =~ ^5 ]]; then
        LOG_PATH="/tmp/head-check/Error/servidor/$DOMINIO.log"
        echo "$DOMINIO → $URL → Servidor $STATUS_CODE"

    else
        LOG_PATH="/tmp/head-check/Error/cliente/$DOMINIO.log"
        echo "$DOMINIO → $URL → Código desconocido: $STATUS_CODE"
    fi

    # Guardar log
    echo "$LOG_LINE" >> "$LOG_PATH"

done < "$ARCHIVO_URLS"
