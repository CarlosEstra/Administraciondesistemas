#!/bin/bash
source validaciones.sh  # Importar funciones de validación

# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como root"
   exit 1
fi

# Instalar Bind9
echo "[+] Instalando Bind9..."
apt update && apt install -y bind9 bind9utils bind9-doc

# Solicitar nombre de la zona DNS con validación
while true; do
    read -p "Ingresa el nombre de la zona DNS (ej. ejemplo.com): " ZONE_NAME
    validar_texto "$ZONE_NAME" && break
done

ZONE_FILE="/etc/bind/db.$ZONE_NAME"
BIND_CONF="/etc/bind/named.conf.local"

# Configurar zona DNS
echo "[+] Configurando zona DNS..."
cat <<EOL > $BIND_CONF
zone "$ZONE_NAME" {
    type master;
    file "/etc/bind/db.$ZONE_NAME";
};
EOL

# Solicitar dirección IP del servidor DNS
while true; do
    read -p "Ingresa la dirección IP del servidor DNS (ej. 192.168.1.1): " DNS_IP
    validar_ip "$DNS_IP" && break
done

# Crear archivo de zona DNS
echo "[+] Creando archivo de zona..."
cat <<EOL > $ZONE_FILE
\$TTL    86400
@       IN      SOA     ns1.$ZONE_NAME. root.$ZONE_NAME. (
                        2025021001  ; Serial
                        3600        ; Refresh
                        1800        ; Retry
                        604800      ; Expire
                        86400       ; Minimum TTL
)

@       IN      NS      ns1.$ZONE_NAME.
ns1     IN      A       $DNS_IP
@       IN      A       $DNS_IP
www     IN      A       $DNS_IP
EOL

# Configurar permisos adecuados
chown bind:bind $ZONE_FILE
chmod 644 $ZONE_FILE

# Reiniciar y habilitar servicio DNS
echo "[+] Reiniciando y habilitando el servicio DNS..."
systemctl enable bind9
systemctl restart bind9
systemctl status bind9 --no-pager
