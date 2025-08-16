#!/bin/bash

# --- Auto-instalación como comando global 'cdn' ---
if [ ! -f /data/data/com.termux/files/usr/bin/cdn ]; then
    echo "📌 Instalando comando global 'cdn'..."
    cp "$0" /data/data/com.termux/files/usr/bin/cdn
    chmod +x /data/data/com.termux/files/usr/bin/cdn
    echo "✅ Comando 'cdn' instalado. Ahora puedes ejecutarlo desde cualquier lugar con: cdn"
fi
# --- Fin de auto-instalación ---

# Pedir al usuario que ingrese dominio o IP
read -p "🌐 Ingresa el dominio o IP (ej: www.jenken-vpn.com o 127.0.0.1): " INPUT

# Comprobar si es IP
if [[ $INPUT =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # Intentar HTTP y HTTPS
    URLS_HTTP=$(curl -s -D - "http://$INPUT" -o /dev/null)
    URLS_HTTPS=$(curl -s -D - "https://$INPUT" -o /dev/null)
    HTML_HTTP=$(curl -s "http://$INPUT")
    HTML_HTTPS=$(curl -s "https://$INPUT")
    DATA="$URLS_HTTP $URLS_HTTPS $HTML_HTTP $HTML_HTTPS"
else
    # Para dominio, asegurar https://
    if [[ $INPUT != http* ]]; then
        DOMINIO="https://$INPUT"
    else
        DOMINIO="$INPUT"
    fi
    DATA=$(curl -s -D - "$DOMINIO" -o /dev/null)
    HTML=$(curl -s "$DOMINIO")
    DATA="$DATA $HTML"
fi

# Extraer URLs que empiecen con http o https
URLS=$(echo "$DATA" | grep -Eo 'https?://[^" ]+')

# Limpiar y extraer solo dominios/subdominios
DOMINIOS=$(echo "$URLS" | sed -E 's#https?://##' | sed -E 's#/.*##' | sort -u)

# Guardar en archivo
SALIDA="cdn.txt"
echo "$DOMINIOS" > "$SALIDA"

# Mostrar resultados
echo "✅ Empresas colaboradoras detectadas y guardadas en $SALIDA"
echo "----------------------------------------"
cat "$SALIDA"
echo "----------------------------------------"
echo "Total detectadas: $(wc -l < "$SALIDA")"
