#!/bin/bash

# *****************************************************
# Script creado por el Grupo 03
# 30-07-2024
# github.com/fotosycaptura
# https://fotosycaptura.cl
# *****************************************************

# Función para escanear cada ip
procesar_ip(){
    ip=$1
    echo "Procesando IP: $ip"
    # Aquí puedes agregar el código para procesar la IP
    os_info=$(nmap -O $ip 2>/dev/null | grep "Running:" | sed 's/Running: //')

    if [ -z "$os_info" ]; then
        os_info="No se pudo identificar el sistema operativo"
    fi

    echo "IP: $ip - OS: $os_info"
}

# Función para obtener rangos de ip
obtener_ips(){
    echo "Buscando... $1"
    ip_actual=$1
    listado=$(nmap -sn $ip_actual/24 2>/dev/null | grep "Nmap scan report for" | sed 's/Nmap scan report for //')
    if [ -z "$listado" ]; then
        echo "Hubo un problema, no se pudo obtener ips del entorno"
    fi

     # Convertir la salida en un array separando por líneas
    IFS=$'\n' read -rd '' -a ips <<<"$listado"

    for ip in "${ips[@]}"; do
        procesar_ip $ip
    done
}

# Función para obtener la IP de la interfaz activa
obtener_ip_activa() {
    # Se filtra del resultado la ip 127.0.0.1
    ip_activa=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v "127.0.0.1" | head -n 1)
    
    if [ -z "$ip_activa" ]; then
        echo "No se pudo obtener la IP de la interfaz activa"
        exit 1
    fi

    echo "La IP de la interfaz activa es: $ip_activa"

    # Se ejecuta la función obtener_ips con el parámetro de la ip activa para hacer el barrido por /24
    obtener_ips $ip_activa
}

# Función para verificar si un comando existe
verificar_nmap() {
    cmdx="nmap"
    # command es usado para verificar la existencia de un comando
    if ! command -v $cmdx &> /dev/null; then
        echo "Error: La herramienta '$cmdx' no está disponible. Por favor, instálelo y vuelva a intentarlo."
        exit 1
    fi
}

# Verificar si se tienen permisos de root
if [[ $EUID -ne 0 ]]; then
    echo "x_scan.sh. Permite realizar un escaneo de red utilizando nmap y obtiene el sistema operativo de los equipos encontrados."
    echo "Este script debe ejecutarse con permisos de root" 
    exit 1
fi

echo "Permisos de root verificados, continuando con el script..."

# Verifica la existencia de nmap
verificar_nmap

# se ejecuta la función para obtener la ip activa de la interfaz de red
obtener_ip_activa
