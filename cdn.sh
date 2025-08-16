#!/bin/bash

# Pedir al usuario que ingrese el dominio
read -p "🌐 Ingresa el dominio o subdominio (ej: www.viva.com.bo): " INPUT

# Asegurarse que tenga https:// al inicio
if [[ $INPUT != http* ]]; then
    DOMINIO="https://$INPUT"
else
    DOMINIO="$INPUT"
fi

# Nombre del archivo de salida
SALIDA="cdn.txt"

echo "📡 Extrayendo colaboradores de $DOMINIO ..."

# Descargar la página y cabeceras
DATA=$(curl -s -D - "$DOMINIO" -o /dev/null)

# Agregar contenido HTML también
HTML=$(curl -s "$DOMINIO")
DATA="$DATA $HTML"

# Extraer URLs que empiecen con http o https
URLS=$(echo "$DATA" | grep -Eo 'https?://[^" ]+')

# Limpiar y extraer solo dominios
DOMINIOS=$(echo "$URLS" | sed -E 's#https?://##' | sed -E 's#/.*##' | sort -u)

# Guardar en archivo
echo "$DOMINIOS" > "$SALIDA"

# Mostrar resultados
echo "✅ Empresas colaboradoras detectadas y guardadas en $SALIDA"
echo "----------------------------------------"
cat "$SALIDA"
echo "----------------------------------------"
echo "Total detectadas: $(wc -l < "$SALIDA")"
