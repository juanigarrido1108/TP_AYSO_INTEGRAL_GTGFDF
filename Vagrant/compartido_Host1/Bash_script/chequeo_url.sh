echo " -- Validador de url --"

read -p "Por favor ingrese url a chequear" url

if curl -s --head "$url" | grep "200" > /dev/null; then
   echo "La url '$url' es valida "
else
   echo "La url '$url' no esta diponible "
fi

