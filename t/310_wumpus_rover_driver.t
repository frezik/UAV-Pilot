use Test::More tests => 11;
use v5.14;
use UAV::Pilot::WumpusRover::Driver::Mock;
use Test::Moose;

my $wumpus = UAV::Pilot::WumpusRover::Driver::Mock->new({
    host => 'localhost',
    port => 49005,
});
ok( $wumpus, "Created object" );
isa_ok( $wumpus => 'UAV::Pilot::WumpusRover::Driver' );
does_ok( $wumpus => 'UAV::Pilot::Driver' );
cmp_ok( $wumpus->port, '==', 49005, "Port set" );

ok( $wumpus->connect, "Connect to WumpusRover" );
my $startup_request_packet = $wumpus->last_sent_packet;
isa_ok( $startup_request_packet
    => 'UAV::Pilot::WumpusRover::Packet::RequestStartupMessage' );

$wumpus->set_ch1( 150 );
my $radio1_packet = $wumpus->last_sent_packet;
isa_ok( $radio1_packet => 'UAV::Pilot::WumpusRover::Packet::RadioOutputs' );
cmp_ok( $wumpus->ch1, '==', 150, "Channel1 set" );
ok(! defined $wumpus->ch2, "Channel2 not set" );

$wumpus->set_ch2( 70 );
my $radio2_packet = $wumpus->last_sent_packet;
cmp_ok( $wumpus->ch1, '==', 150, "Channel1 set" );
cmp_ok( $wumpus->ch2, '==', 70,  "Channel2 set" );
