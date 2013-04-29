#!/usr/bin/perl
use v5.14;
use warnings;
use UAV::Pilot::Sender::ARDrone;


my $HOST        = shift || '192.168.1.1';
my $PORT        = UAV::Pilot::Sender::ARDrone->ARDRONE_PORT_NAV_DATA;
my $SOCKET_TYPE = UAV::Pilot::Sender::ARDrone->ARDRONE_PORT_NAV_DATA_TYPE;


my $sender = UAV::Pilot::Sender::ARDrone->new({
    host => $HOST,
});
my $port = $sender->ARDRONE_PORT_NAV_DATA;
my $socket = IO::Socket::INET->new(
    Proto     => $SOCKET_TYPE,
    PeerPort  => $PORT,
    PeerAddr  => $HOST,
    LocalPort => $PORT,
) or die "Could not open socket: $!\n";

$sender->connect;
$socket->send('foo');
say "Sent init packet, waiting for status packet . . . ";
my $buf = '';
$socket->read( \$buf, 4096 );
say "Got status packet: $buf";

$sender->at_config( $sender->ARDRONE_CONFIG_GENERAL_NAVDATA_DEMO, 'TRUE' );

say "Ready to receive data from $HOST:$PORT";
while( my $in = $socket->read( \$buf, 4096 ) ) {
    say "Got packet: $buf";
}
