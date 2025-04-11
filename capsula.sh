#!/bin/bash

#Avisar a l'usuari
echo "Aquest script necessita ser executar amb 'SUDO'."

# Preguntar a l'usuari
read -p "Introdueix la ruta del fitxer o carpeta que vols guardar: " ARXIUS
read -p "Introdueix la data d'obertura (format: YYYY-MM-DD HH:MM): " DATA_OBERTURA
read -p "Introdueix un títol per a la pàgina web: " TITLE

# Preparar variables
BASENAME=$(basename "$ARXIUS")
TIMESTAMP=$(date -d "$DATA_OBERTURA" +%s)
NOW=$(date +%s)
SECONDS_LEFT=$((TIMESTAMP - NOW))
COMPRIMIDO="capsula.tar.gz"
WEB_DIR="/var/www/html"

# Comprimir el contingut
tar -czf "$COMPRIMIDO" "$ARXIUS"

# Moure l’arxiu i bloquejar-lo
sudo mv "$COMPRIMIDO" "$WEB_DIR/"
sudo chmod 000 "$WEB_DIR/$COMPRIMIDO"

#Obertura
COMANDA_OBERTURA=$(chmod 777 $WEB_DIR/$COMPRIMIDO)

# Instal·lació AT si no esta instal·lat
if ! command -v at &> /dev/null; then
    echo "Instal·lant at..."
    sudo apt-get update -qq
    sudo apt-get install -y at > /dev/null 2>&1
    sudo systemctl enable at
    sudo systemctl start at
fi

# Programar obertura amb `at`
sudo echo "$COMANDA_OBERTURA" | sudo at "$DATA_OBERTURA"

# Crear pàgina HTML amb compte enrere
cat <<EOF | sudo tee "$WEB_DIR/index.html" > /dev/null
<!DOCTYPE html>
<html>
<head>
    <title>$TITLE</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>$TITLE</h1>
    <p id="countdown"></p>
    <div id="link" style="display:none;">
        <a href="$COMPRIMIDO" download>Descarrega la Càpsula del Temps</a>
    </div>

    <script>
        const ARXIUSDate = new Date("$DATA_OBERTURA").getTime();

        const interval = setInterval(() => {
            const now = new Date().getTime();
            const distance = ARXIUSDate - now;

            if (distance <= 0) {
                clearInterval(interval);
                document.getElementById("countdown").innerHTML = "La càpsula està disponible!";
                document.getElementById("link").style.display = "block";
            } else {
                const days = Math.floor(distance / (1000 * 60 * 60 * 24));
                const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((distance % (1000 * 60)) / 1000);
                document.getElementById("countdown").innerHTML = 
                    days + "d " + hours + "h " + minutes + "m " + seconds + "s ";
            }
        }, 1000);
    </script>
</body>
</html>
EOF

# Instal·lar Apache si no està instal·lat
if ! command -v apache2 &> /dev/null; then
    echo "Instal·lant Apache..."
    sudo apt-get update -qq
    sudo apt-get install -y apache2 > /dev/null 2>&1
    sudo systemctl enable apache2
    sudo systemctl start apache2
fi

echo "✅ Càpsula creada! Visita http://localhost/ per veure el compte enrere."
