#!/usr/bin/perl
use v5.14;
use warnings;
use UAV::Pilot::Sender::ARDrone;


my $HOST = shift || '192.168.1.1';
my $PORT = 5554;


my $sender = UAV::Pilot::Sender::ARDrone->new({
    host => $HOST,
});
my $socket = IO::Socket::INET->new(
    Proto    => 'udp',
    PeerPort => $PORT,
    PeerAddr => $HOST,
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
