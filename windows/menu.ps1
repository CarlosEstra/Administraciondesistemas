# Importar módulos necesarios
. .\validations.ps1
. .\dns.ps1
. .\dhcp.ps1

# Menú principal
function Show-Menu {
    Clear-Host
    Write-Host "===================================="
    Write-Host "  Configuración de Servidores        "
    Write-Host "===================================="
    Write-Host "1. Configurar Servidor DNS"
    Write-Host "2. Configurar Servidor DHCP"
    Write-Host "3. Salir"
    Write-Host "===================================="
}

# Lógica del menú
do {
    Show-Menu
    $choice = Read-Host "Seleccione una opción (1-3)"

    switch ($choice) {
        1 {
            Write-Host "Configurando Servidor DNS..."
            Configure-DNS
        }
        2 {
            Write-Host "Configurando Servidor DHCP..."
            Configure-DHCP
        }
        3 {
            Write-Host "Saliendo..."
            exit
        }
        default {
            Write-Host "Opción no válida. Intente de nuevo."
        }
    }
    pause
} while ($choice -ne 3)