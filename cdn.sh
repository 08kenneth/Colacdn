#!/bin/bash

main_menu() {
    clear
    echo "=========================================="
    echo "          🔹 MENU CDN 4.0 🔹"
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
    [[ $INPUT != http* ]] && DOMINIO="https://$INPUT" || DOMINIO="$INPUT"
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

# Función para reverse IP
ip_reverse() {
    read -p "🌐 Ingresa la IP (ej: 127.0.0.1): " IP
    echo "🔎 Buscando sub - o dominios asociados a $IP ..."

    RESPONSE=$(curl -s "https://api.hackertarget.com/reverseiplookup/?q=$IP")

    if [[ "$RESPONSE" == *"error"* ]] || [[ -z "$RESPONSE" ]]; then
        echo "❌ No se encontraron dominios asociados o la API falló."
    else
        SALIDA="cdn_ip.txt"
        echo "$RESPONSE" | sort -u > "$SALIDA"
        echo "✅ Sub - o dominios asociados guardados en $SALIDA"
        echo "----------------------------------------"
        cat "$SALIDA"
        echo "----------------------------------------"
        echo "Total detectados: $(wc -l < "$SALIDA")"
    fi
    read -n1 -rsp $'Presiona cualquier tecla para volver al menú...\n'
    main_menu
}

# --- Auto-instalación como comando global 'jenken' ---
if [ ! -f /data/data/com.termux/files/usr/bin/jenken ]; then
    cp "$0" /data/data/com.termux/files/usr/bin/jenken
    chmod +x /data/data/com.termux/files/usr/bin/jenken
fi

# Ejecutar menú
main_menu
