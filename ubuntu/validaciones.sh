#!/bin/bash

# Verificar que la entrada sea solo números
validar_numeros() {
    if [[ ! "$1" =~ ^[0-9]+$ ]]; then
        echo "Error: Solo se permiten números."
        return 1
    fi
    return 0
}

# Verificar que la entrada sea una dirección IP válida
validar_ip() {
    if [[ ! "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo "Error: Dirección IP no válida."
        return 1
    fi
    return 0
}

# Verificar que no haya caracteres especiales si no se permiten
validar_texto() {
    if [[ "$1" =~ [^a-zA-Z0-9._-] ]]; then
        echo "Error: No se permiten caracteres especiales."
        return 1
    fi
    return 0
}
