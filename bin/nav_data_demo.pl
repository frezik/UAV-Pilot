#!/usr/bin/perl
use v5.14;
use warnings;
use UAV::Pilot::Sender::ARDrone;
use IO::Socket::Multicast;


my $HOST           = shift || '192.168.1.1';
my $MULTICAST_ADDR = UAV::Pilot::Sender::ARDrone->ARDRONE_MULTICAST_ADDR;
my $PORT           = UAV::Pilot::Sender::ARDrone->ARDRONE_PORT_NAV_DATA;
my $SOCKET_TYPE    = UAV::Pilot::Sender::ARDrone->ARDRONE_PORT_NAV_DATA_TYPE;
my $IFACE          = 'wlan0';


my $sender = UAV::Pilot::Sender::ARDrone->new({
    host => $HOST,
});
my $port = $sender->ARDRONE_PORT_NAV_DATA;
say "Opening $SOCKET_TYPE socket on $HOST:$PORT, local port $PORT . . . ";
my $socket = IO::Socket::Multicast->new(
    Proto     => $SOCKET_TYPE,
    PeerPort  => $PORT,
    PeerAddr  => $HOST,
    LocalAddr => $MULTICAST_ADDR,
    LocalPort => $PORT,
    ReuseAddr => 1,
) or die "Could not open socket: $!\n";

say "Adding self to multicast address $MULTICAST_ADDR . . . ";
$socket->mcast_add( $MULTICAST_ADDR, $IFACE )
    or die "Could not subscribe to '$MULTICAST_ADDR' multicast: $!\n";

$sender->connect;

$socket->send( "foo" );
$sender->at_config(
    $sender->ARDRONE_CONFIG_GENERAL_NAVDATA_DEMO,
    $sender->TRUE,
);

say "Sent init packet, waiting for status packet . . . ";
my $buf = '';
while(1) {
    last if $socket->recv( $buf, 1024 );
    say "Nothing yet . . . ";
    sleep 1;
}
say "Got status packet: " . to_hex( $buf );

say "Ready to receive data from $HOST:$PORT";
while( my $in = $socket->recv( $buf, 4096 ) ) {
    my $hex_str = to_hex( $buf );
    say "Got packet: " . $hex_str;
}


sub to_hex
{
    my ($in) = @_;
    return join( '',
        map {
            sprintf '%02x', $_;
        } unpack( 'C*', $in )
    );
}
