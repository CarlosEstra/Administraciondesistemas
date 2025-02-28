# Función para configurar el servidor DNS
function Configure-DNS {
    # Verificar si el servicio DNS ya está instalado
    $dnsInstalled = Get-WindowsFeature -Name DNS

    if ($dnsInstalled.Installed -eq $false) {
        Write-Host "El rol de DNS no está instalado. Instalando ahora..."
        Install-WindowsFeature -Name DNS -IncludeManagementTools
        Write-Host "Instalación completa del rol DNS."
    } else {
        Write-Host "El rol de DNS ya está instalado."
    }

    # Solicitar la IP del servidor DNS
    $ip = Get-ValidInput "Ingrese la dirección IP del servidor DNS (Ejemplo: 192.168.0.31)" { Test-ValidIP $_ }

    # Verificar si la zona "reprobados.com" ya existe
    $existingZone = Get-DnsServerZone -Name "reprobados.com" -ErrorAction SilentlyContinue

    if ($existingZone) {
        Write-Host "La zona 'reprobados.com' ya existe. Eliminándola..."
        Remove-DnsServerZone -Name "reprobados.com" -Force
        Write-Host "Zona eliminada correctamente."
    }

    # Crear la zona para reprobados.com
    Write-Host "Creando la zona DNS para reprobados.com..."
    Add-DnsServerPrimaryZone -Name "reprobados.com" -ZoneFile "reprobados.com.dns" -DynamicUpdate "None"

    # Crear el registro A para www.reprobados.com
    Write-Host "Creando el registro A para www.reprobados.com..."
    Add-DnsServerResourceRecordA -Name "www" -ZoneName "reprobados.com" -IPv4Address $ip

    # Crear el registro A para reprobados.com (sin www)
    Write-Host "Creando el registro A para reprobados.com..."
    Add-DnsServerResourceRecordA -Name "reprobados.com" -ZoneName "reprobados.com" -IPv4Address $ip

    # Verificar que el servidor DNS responde correctamente
    Write-Host "Verificando la resolución DNS en el servidor..."
    Resolve-DnsName -Name "www.reprobados.com" -Server 127.0.0.1
    Resolve-DnsName -Name "reprobados.com" -Server 127.0.0.1

    # Configurar las interfaces de red para usar el DNS
    Write-Host "Configurando las interfaces de red para usar el DNS $ip"
    $interfaces = Get-NetIPConfiguration | Where-Object { $_.IPv4Address -ne $null }

    foreach ($interface in $interfaces) {
        $interfaceAlias = $interface.InterfaceAlias
        Write-Host "Configurando $interfaceAlias para usar $ip como DNS..."
        Set-DnsClientServerAddress -InterfaceAlias $interfaceAlias -ServerAddresses $ip
    }

    # Limpiar caché DNS en la máquina
    Write-Host "Limpiando la caché DNS..."
    ipconfig /flushdns

    # Probar resolución de DNS
    Write-Host "Verificando resolución de DNS desde el cliente..."
    nslookup www.reprobados.com
    nslookup reprobados.com
}