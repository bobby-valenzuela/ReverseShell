#!/usr/bin/python3

"""
Setup:

sudo apt install python3-pip
pip3 install --pre scapy[basic]
"""

"""
Description: Detects (possible) ARP apoofing.

Technicially, it just checks for any ARP packets being received and will let us know if we're receiving an ARP request in which the IP/MAC association has been changed.
This would (likely) be due to some of ARP poisoning.
"""

"""
Usage: sudo python3 arpDetector.py
"""

from scapy.all import sniff

IP_MAC_Map = {}

def processPacket(packet):
	src_IP = packet['ARP'].psrc
	src_MAC = packet['Ether'].src
	if src_MAC in IP_MAC_Map.keys():
		
		if IP_MAC_Map[src_MAC] != src_IP :
			try:
				old_IP = IP_MAC_Map[src_MAC]
			except:
				old_IP = "unknown"
			message = ("\n Possible ARP attack detected \n " 
				+ "It is possible that the machine with IP address \n " 
				+ str(old_IP) + " is pretending to be " + str(src_IP) +"\n ")
			return message
	else:
		IP_MAC_Map[src_MAC] = src_IP

# count: Number of packets to sniff (0 = continuous)
# filter: Type of packet to capture
# store: Number of packets to store
# prn: function to call when a packet is received
sniff(count=0, filter="arp", store = 0, prn = processPacket)
