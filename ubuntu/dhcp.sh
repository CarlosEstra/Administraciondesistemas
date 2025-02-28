#!/bin/bash
source validaciones.sh  # Importar funciones de validación

# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como root" 
   exit 1
fi

# Instalar el servidor DHCP
apt update && apt install -y isc-dhcp-server

# Solicitar interfaz de red con validación
while true; do
    read -p "Ingresa el nombre de la interfaz de red (ej. eth0): " INTERFACE
    validar_texto "$INTERFACE" && break
done

echo "INTERFACESv4=\"$INTERFACE\"" > /etc/default/isc-dhcp-server

# Solicitar configuración de red con validaciones
while true; do
    read -p "Ingresa la dirección de la red (ej. 192.168.1.0): " NETWORK
    validar_ip "$NETWORK" && break
done

while true; do
    read -p "Ingresa la máscara de subred (ej. 255.255.255.0): " NETMASK
    validar_ip "$NETMASK" && break
done

while true; do
    read -p "Ingresa el rango de direcciones (ej. 192.168.1.100 192.168.1.200): " RANGE
    [[ "$RANGE" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}[[:space:]]+([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && break
    echo "Error: Formato de rango inválido."
done

while true; do
    read -p "Ingresa la dirección de gateway (ej. 192.168.1.1): " GATEWAY
    validar_ip "$GATEWAY" && break
done

while true; do
    read -p "Ingresa la dirección del servidor DNS (ej. 8.8.8.8): " DNS
    validar_ip "$DNS" && break
done

# Crear configuración DHCP
cat <<EOT > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
option subnet-mask $NETMASK;
option broadcast-address $(echo $NETWORK | awk -F'.' '{print $1"."$2"."$3".255"}');
option routers $GATEWAY;
option domain-name-servers $DNS;
subnet $NETWORK netmask $NETMASK {
  range $RANGE;
}
EOT

# Reiniciar el servicio
systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server
systemctl status isc-dhcp-server --no-pager
