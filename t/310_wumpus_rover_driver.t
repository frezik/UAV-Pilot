use Test::More tests => 10;
use v5.14;
use UAV::Pilot::WumpusRover::Driver::Mock;
use Test::Moose;

my $wumpus = UAV::Pilot::WumpusRover::Driver::Mock->new({
    host => 'localhost',
    port => 49005,
});
isa_ok( $wumpus => 'UAV::Pilot::WumpusRover::Driver' );
does_ok( $wumpus => 'UAV::Pilot::Driver' );
cmp_ok( $wumpus->port, '==', 49005, "Port set" );

ok( $wumpus->connect, "Connect to WumpusRover" );
my $startup_request_packet = $wumpus->last_sent_packet;
isa_ok( $startup_request_packet
    => 'UAV::Pilot::WumpusRover::Packet::RequestStartupMessage' );

$wumpus->send_radio_output_packet( 150 );
my $radio1_packet = $wumpus->last_sent_packet;
isa_ok( $radio1_packet => 'UAV::Pilot::WumpusRover::Packet::RadioOutputs' );
cmp_ok( $radio1_packet->ch1_out, '==', 150, "Channel1 set" );

$wumpus->send_radio_output_packet( 150, 70 );
my $radio2_packet = $wumpus->last_sent_packet;
cmp_ok( $radio2_packet->ch1_out, '==', 150, "Channel1 set" );
cmp_ok( $radio2_packet->ch2_out, '==', 70,  "Channel2 set" );
