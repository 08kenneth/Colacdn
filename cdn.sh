#!/bin/bash

# --- Auto-instalación como comando global 'cdn' ---
if [ ! -f /data/data/com.termux/files/usr/bin/cdn ]; then
    echo "📌 Instalando comando global 'cdn'..."
    cp "$0" /data/data/com.termux/files/usr/bin/cdn
    chmod +x /data/data/com.termux/files/usr/bin/cdn
    echo "✅ Comando 'cdn' instalado. Ahora puedes ejecutarlo desde cualquier lugar con: cdn"
fi
# --- Fin de auto-instalación ---

clear
echo "=========================================="
echo "          🔹 MENU CDN 🔹"
echo "=========================================="
echo "1) Extraer sub - o dominios de colaboradores"
echo "2) Extraer sub - o dominios asociados a una IP"
echo "0) Salir"
echo "=========================================="
read -p "Selecciona una opción: " OPCION

case $OPCION in
    1)
        read -p "🌐 Ingresa el sub - o dominio (ej: www.jenken.com): " INPUT
        if [[ $INPUT != http* ]]; then
            DOMINIO="https://$INPUT"
        else
            DOMINIO="$INPUT"
        fi
        SALIDA="cdn.txt"

        echo "📡 Escaneando sub - o dominios de $DOMINIO ..."

        DATA=$(curl -s -D - "$DOMINIO" -o /dev/null)
        HTML=$(curl -s "$DOMINIO")
        DATA="$DATA $HTML"

        URLS=$(echo "$DATA" | grep -Eo 'https?://[^\" ]+')
        DOMINIOS=$(echo "$URLS" | sed -E 's#https?://##' | sed -E 's#/.*##' | sort -u)

        echo "$DOMINIOS" > "$SALIDA"

        echo "✅ Sub - o dominios detectados y guardados en $SALIDA"
        echo "----------------------------------------"
        cat "$SALIDA"
        echo "----------------------------------------"
        echo "Total detectados: $(wc -l < "$SALIDA")"
        ;;
    2)
        read -p "🌐 Ingresa la IP (ej: 127.0.0.1): " IP

        echo "🔎 Buscando sub - o dominios asociados a $IP ..."

        RESPONSE=$(curl -s -X POST \
            -d "remoteAddress=$IP" \
            -d "key=" \
            https://domains.yougetsignal.com/domains.php)

        DOMINIOS=$(echo "$RESPONSE" | grep -oP '"domain":"\K[^"]+')
        SALIDA="cdn_ip.txt"
        echo "$DOMINIOS" > "$SALIDA"

        echo "✅ Sub - o dominio asociados guardados en $SALIDA"
        echo "----------------------------------------"
        cat "$SALIDA"
        echo "----------------------------------------"
        echo "Total detectados: $(wc -l < "$SALIDA")"
        ;;
    0)
        echo "Saliendo..."
        exit 0
        ;;
    *)
        echo "Opción inválida"
        exit 1
        ;;
esac
