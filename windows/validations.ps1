# Validar si una cadena es una dirección IP válida
function Test-ValidIP {
    param (
        [string]$ip
    )
    return $ip -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$"
}

# Validar si una cadena es una máscara de subred válida
function Test-ValidSubnetMask {
    param (
        [string]$mask
    )
    return $mask -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$"
}

# Validar si una cadena es un número entero
function Test-ValidNumber {
    param (
        [string]$number
    )
    return $number -match "^\d+$"
}

# Solicitar una entrada válida al usuario
function Get-ValidInput {
    param (
        [string]$prompt,
        [scriptblock]$validation
    )
    do {
        $input = Read-Host $prompt
        if (-not (& $validation $input)) {
            Write-Host "Entrada no válida. Intente de nuevo."
        }
    } while (-not (& $validation $input))
    return $input
}