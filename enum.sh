#!/bin/bash

# First scanner
sudo nmap -p- --open -sS --min-rate 5000 -vvv -n -Pn $1 -oG openPorts

file_scan='openPorts'

# Function for the extraction of the ports scanned
extractPorts(){
    ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
    ip_address="$(cat $1 | grep -oP '\d{1,3.\d{1,3.\d{1,3.\d{1,3}' | sort -u | head -n 1)"
    echo -e "\n[*] Extracting information...\n" > extractedPorts.tmp
    echo -e "\t[*] IP Address: $ip_address" >> extractedPorts.tmp
    echo -e "\t[*] Open ports: $ports\n" >> extractedPorts.tmp
    cat extractedPorts.tmp
    rm extractedPorts.tmp
}

# Call of the function. Lo hace en una subshell por lo que el valor de ports no puede salir a las vbles globales
# portos=$(extractPorts $file_scan)
#echo "$portos"

# Llama a la función
extractPorts $file_scan

# nmap with recon scripts to see the available services and their versions
echo 'SEARCHING INFO OF SERVICES'
sudo nmap -sCV -p$ports -Pn $1 -oN infoServices

# search for http port and if its found, starts gobuster
echo ''
search='80'
if echo "$ports" | tr ',' '\n' | grep -q "$search"; then
    echo 'starting GOBUSTER'
    gobuster dir -u http://$1/ -w /usr/share/wordlists/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -x html,php,sh,py,pdf -o gobusterResults.txt
fi

# search for smb service. If found, executes sripts vuln and safe from nmap. PONER OTRO COMANDO POQ NO DA INFO ADICIONAL
search='445'
if echo "$ports" | tr ',' '\n' | grep -q "$search"; then
    echo ''
    echo 'searching vulnerabilities of samba'
    sudo nmap --script "vuln and safe" -p445 $1 -oN smbVulnScan
fi

echo ''
echo 'END OF SCRIPT'
exit