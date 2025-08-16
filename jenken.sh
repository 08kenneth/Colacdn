#!/bin/bash

# --- Auto-instalación como comando global 'jenken' ---
if [ ! -f /data/data/com.termux/files/usr/bin/jenken ]; then
    echo "📌 Instalando comando global 'jenken'..."
    cp "$0" /data/data/com.termux/files/usr/bin/jenken
    chmod +x /data/data/com.termux/files/usr/bin/jenken
    echo "✅ Comando 'jenken' instalado. Ahora puedes ejecutarlo desde cualquier lugar con: jenken"
fi
# --- Fin de auto-instalación ---

main_menu() {
    clear
    echo "=========================================="
    echo "          🔹 MENU CDN 3.0 🔹"
    echo "=========================================="
    echo "1) Extraer sub - o dominios de colaboradores"
    echo "2) Extraer sub - o dominios asociados a una IP"
    echo "0) Salir"
    echo "=========================================="
    read -p "Selecciona una opción: " OPCION

    case $OPCION in
        1)
            escanear_dominios
            ;;
        2)
            ip_reverse
            ;;
        0)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción inválida"
            sleep 2
            main_menu
            ;;
    esac
}

# Función para escanear subdominios de dominio
escanear_dominios() {
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
    read -n1 -rsp $'Presiona cualquier tecla para volver al menú...\n'
    main_menu
}

# Función para reverse IP con servidor
ip_reverse() {
    read -p "🌐 Ingresa la IP (ej: 127.0.0.1): " IP
    echo "🔎 Buscando sub - o dominios asociados a $IP ..."

    RESPONSE=$(curl -s -X POST \
        -d "remoteAddress=$IP" \
        -d "key=" \
        https://domains.yougetsignal.com/domains.php)

    DOMINIOS=$(echo "$RESPONSE" | grep -oP '"domain":"\K[^"]+')

    if [[ -z "$DOMINIOS" ]]; then
        echo "❌ No se encontraron dominios asociados o la API falló."
    else
        SALIDA="cdn_ip.txt"
        echo "$DOMINIOS" | sort -u > "$SALIDA"

        echo "✅ Sub - o dominios asociados con su servidor:"
        echo "----------------------------------------"
        while read -r dominio; do
            SERVER=$(curl -sI "http://$dominio" | grep -i '^Server:' | cut -d' ' -f2-)
            echo -e "$dominio - \e[32m${SERVER:-Desconocido}\e[0m"
        done < "$SALIDA" | tee "$SALIDA"

        echo "----------------------------------------"
        echo "Total detectados: $(wc -l < "$SALIDA")"
    fi
    read -n1 -rsp $'Presiona cualquier tecla para volver al menú...\n'
    main_menu
}

# Ejecutar menú
main_menu
