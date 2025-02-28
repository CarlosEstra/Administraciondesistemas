#!/bin/bash

# Verificar si el script se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como root"
   exit 1
fi

while true; do
    clear
    echo "================================="
    echo "  Configuración de Servidores  "
    echo "================================="
    echo "1) Configurar Servidor DHCP"
    echo "2) Configurar Servidor DNS"
    echo "3) Salir"
    read -p "Seleccione una opción: " OPCION

    case $OPCION in
        1) bash dhcp.sh ;;
        2) bash dns.sh ;;
        3) echo "Saliendo..."; exit 0 ;;
        *) echo "Opción no válida, intente de nuevo." ;;
    esac
    read -p "Presione Enter para continuar..."
done
