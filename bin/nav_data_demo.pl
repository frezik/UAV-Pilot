#!/usr/bin/perl
use v5.14;
use warnings;
use UAV::Pilot::Driver::ARDrone;
use UAV::Pilot::Driver::ARDrone::NavPacket;
use IO::Socket::Multicast;


my $HOST           = shift || '192.168.1.1';
my $MULTICAST_ADDR = UAV::Pilot::Driver::ARDrone->ARDRONE_MULTICAST_ADDR;
my $PORT           = UAV::Pilot::Driver::ARDrone->ARDRONE_PORT_NAV_DATA;
my $SOCKET_TYPE    = UAV::Pilot::Driver::ARDrone->ARDRONE_PORT_NAV_DATA_TYPE;
my $IFACE          = 'wlan0';


say "Connectting to $HOST . . . ";
my $sender = UAV::Pilot::Driver::ARDrone->new({
    host => $HOST,
});
$sender->connect;

say "Ready to receive data from $HOST";
my $continue = 1;
while( $continue ) {
    if( $sender->read_nav_packet ) {
        my $last_nav_packet = $sender->last_nav_packet;
        say "Got nav packet: " . $last_nav_packet->to_string;
    }

    sleep 1;
}
