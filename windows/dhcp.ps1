# Función para configurar el servidor DHCP
function Configure-DHCP {
    # Solicitar configuración al usuario
    $ScopeName = Get-ValidInput "Ingrese el nombre del Scope (Ejemplo: RedInterna)" { $_ -ne "" }
    $ScopeStartIP = Get-ValidInput "Ingrese la IP de inicio del Scope (Ejemplo: 192.168.70.100)" { Test-ValidIP $_ }
    $ScopeEndIP = Get-ValidInput "Ingrese la IP final del Scope (Ejemplo: 192.168.70.200)" { Test-ValidIP $_ }
    $SubnetMask = Get-ValidInput "Ingrese la máscara de subred (Ejemplo: 255.255.255.0)" { Test-ValidSubnetMask $_ }
    $Gateway = Get-ValidInput "Ingrese la puerta de enlace (Ejemplo: 192.168.70.2)" { Test-ValidIP $_ }
    $DNS = Get-ValidInput "Ingrese la dirección del servidor DNS (Ejemplo: 192.168.70.128)" { Test-ValidIP $_ }
    $LeaseDuration = Get-ValidInput "Ingrese la duración del arrendamiento en días (Ejemplo: 8)" { Test-ValidNumber $_ }

    # Instalar el rol de servidor DHCP
    Install-WindowsFeature -Name DHCP -IncludeManagementTools

    # Obtener la primera dirección IPv4 que no sea de loopback
    $ServerIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -match "Ethernet" -and $_.IPAddress -notmatch "169.254.*" }).IPAddress

    # Autorizar el servidor DHCP
    $ServerName = (Get-WmiObject Win32_ComputerSystem).Name

    # Crear el Scope DHCP
    Add-DhcpServerv4Scope -Name $ScopeName -StartRange $ScopeStartIP -EndRange $ScopeEndIP -SubnetMask $SubnetMask -State Active

    # Configurar opciones del Scope
    Set-DhcpServerv4OptionValue -ScopeId $ScopeStartIP -OptionId 3 -Value $Gateway
    Set-DhcpServerv4OptionValue -ScopeId $ScopeStartIP -OptionId 6 -Value $DNS
    Set-DhcpServerv4Scope -ScopeId $ScopeStartIP -LeaseDuration ([TimeSpan]::FromDays($LeaseDuration))

    Write-Host "Configuración completada. Servidor DHCP en funcionamiento."
}