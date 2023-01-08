#!/usr/bin/env bash

# If not root or sudoer...
{ [[ $(id -u) -eq 0 ]] || $(sudo -v &>/dev/null) ; } || { echo -e "Please run with sudo privileges.\nExiting..." ; exit 1 ; } 

# Install Pckages
# sudo apt update &> /dev/null && echo "Apt cache updated!"
# sudo apt install netdiscover -y &> /dev/null && echo "Netdiscover has been installed!"
# sudo apt install dsniff -y &> /dev/null && echo "Dsniff has been installed!"
# sudo apt install net-tools -y &> /dev/null && echo "Dsniff has been installed!" # route command


# Enable port-forwarding
sudo sysctl -w net.ipv4.ip_forward=1 &> /dev/null || sudo echo 1 > /proc/sys/net/ipv4/ip_forward &> /dev/null

# Veryfy port-forwarding is enabled, if not then exit
port_forwarding_enabled=$(sudo cat /proc/sys/net/ipv4/ip_forward)
{ [[ ${port_forwarding_enabled} -eq 1 ]] && echo "Port-Fowarding Enabled!" ; } || { echo -e "Port-Fowarding could not be enabled...\nExiting!" ; exit 1 ; }

# Get default gateway
default_gateway=$(ip route show | egrep "default\s*via" | cut -d " " -f 3 | xargs )     # Using xargs just to trim leading/trailing white-space

# RegxMatch to verify we've found the default gateway
[[ ! "${default_gateway}" =~ ([0-9]\.){1,3} ]] && { echo -e "Could not find default gateway.\nExiting..." ; exit 1 ; }

printf "Your default gateway is: ${default_gateway}\n"


# Get interface in use

# sudo netdiscover

# Disable port-forwarding
