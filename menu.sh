#!/bin/bash

while true; do
    clear
    echo "========= MENÚ DE LA CÀPSULA DEL TEMPS ========="
    echo "1. Crear una nova càpsula"
    echo "2. Llistar càpsules programades"
    echo "3. Cancel·lar una càpsula programada"
    echo "4. Veure càpsules ja obertes"
    echo "5. Eliminar càpsules ja obertes"
    echo "6. Sortir"
    echo "==============================================="
    read -p "Tria una opció (1-6): " OPCIO

    case $OPCIO in
        1)
            echo "Executant script de creació..."
            sleep 1
            bash capsula.sh
            read -p "Prem ENTER per continuar..." ;;
        2)
            echo "📋 Càpsules programades:"
            atq
            read -p "Prem ENTER per continuar..." ;;
        3)
            echo "🔁 Llistat de tasques programades:"
            atq
            read -p "Introdueix l'ID de la tasca a cancel·lar: " ID
            if [[ "$ID" =~ ^[0-9]+$ ]]; then
                atrm "$ID"
                echo "✅ Tasca cancel·lada."
            else
                echo "❌ ID no vàlid."
            fi
            sleep 2 ;;
        4)
            echo "📁 Càpsules ja obertes (a /var/www/html):"
            ls -l /var/www/html | grep "^d"
            read -p "Prem ENTER per continuar..." ;;
        5)
	    echo "🗑️ Eliminar una càpsula oberta"
            echo "Carpetes disponibles:"
            ls /var/www/html
            read -p "Introdueix el nom de la càpsula (carpeta) a eliminar: " DIR
            FULLPATH="/var/www/html/$DIR"

            if [ -d "$FULLPATH" ]; then
                read -p "Segur que vols eliminar '$DIR'? (s/n): " CONFIRM
                if [[ "$CONFIRM" =~ ^[sS]$ ]]; then
                    sudo rm -r "$FULLPATH"
                    echo "✅ Càpsula '$DIR' eliminada."
                else
                    echo "❌ Eliminació cancel·lada."
                fi
            else
                echo "❌ No s'ha trobat la carpeta '$DIR'."
            fi
            read -p "Prem ENTER per continuar..." ;;

	6)
            echo "👋 Sortint..."
            sleep 1
            break ;;
        *)
            echo "❌ Opció no vàlida! Torna-ho a intentar..."
            sleep 2 ;;
    esac
done
