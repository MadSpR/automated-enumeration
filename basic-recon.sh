#!/bin/bash

# Reconocimiento del alcance de la red y los puertos abiertos con sus servicios y versiones
# Se crearán 3 archivos: scope, tcp_scan y port_scan
# args: 
#    - 1: ip
#    - 2: rango (24, 16, 8)
# ejemplo de uso:
#    sudo ./recon.sh 172.17.0.2 24


# Descubrimiento de equipos
nmap -sn $1/$2 -oN scope

file_scan='scope'

## extrae la raíz de la IP para hacer luego el escaneo
if [ $2 = 24 ]; then
    ip_raiz="$(echo "$1" | cut -d '.' -f1,2,3)"
    echo -e "llega $ip_raiz"
elif [ $2 = 16 ]; then
    ip_raiz="$(echo "$1" | cut -d '.' -f1,2)"
elif [ $2 = 8 ]; then
    ip_raiz="$(echo "$1" | cut -d '.' -f1)"
fi

## filtra el número de IP con máscara 24
ips="$(cat $file_scan | grep -oP '[0-9]$' | sed '1d' | cut -d ' ' -f5 | sort -u | xargs | tr ' ' '\n' | cut -d '.' -f4 | xargs | tr ' ' ',')"

# Escaneo de nmap
sudo nmap -sS -Pn --min-rate 5000 -p- --open $ip_raiz.$ips -oN tcp_scan

tcp_scan='tcp_scan'

## filtra los puertos extraídos en el escáner
ports="$(grep '^[0-9]' $tcp_scan | cut -d '/' -f1 | sort -u | xargs | tr ' ' ',')"

# Escaneo de servicios de los puertos encontrados en las ips descubiertas
sudo nmap -p$ports -sC -sV --open $ip_raiz.$ips -Pn -oN port_scan
