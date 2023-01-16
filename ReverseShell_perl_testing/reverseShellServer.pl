#!/usr/bin/perl -w


use strict;
use Socket;

# Use public IP unless otherwise specified
my $server = $ARGV[0] || "96.126.97.119";  # Host IP running the server

# use port 7890 as default
my $port = $ARGV[1] || 7890;
my $proto = getprotobyname('tcp');

# create a socket, make it reusable
socket(SOCKET, PF_INET, SOCK_STREAM, $proto) or die "Can't open socket $!\n";
setsockopt(SOCKET, SOL_SOCKET, SO_REUSEADDR, 1) or die "Can't set socket option to SO_REUSEADDR $!\n";

# bind to a port, then listen
bind( SOCKET, pack_sockaddr_in($port, inet_aton($server))) or die "Can't bind to port $port! \n";

listen(SOCKET, 5) or die "listen: $!";
print "SERVER started on port $port - awaiting connections...\n";

# accepting a connection
my $client_addr;
my $connected = 0;
my $response;

while ($client_addr = accept(NEW_SOCKET, SOCKET)) {

    print "[Connected] Enter a command: " if $connected == 0;

    while( my $line = <STDIN> ) {

        # do some stuff with $line
        print "[Connected] Enter a command: "  ;
        print NEW_SOCKET "$line";
        close NEW_SOCKET;
        $connected = 1;
        last;

    }

}
