use Test::More tests => 9;
use strict;
use warnings;
use UAV::Pilot::Control;
use UAV::Pilot::ControlRover;
use UAV::Pilot::WumpusRover::Control;
use UAV::Pilot::WumpusRover::Driver::Mock;
use Test::Moose;


my $driver = UAV::Pilot::WumpusRover::Driver::Mock->new({
    host => 'localhost',
    port => 49000,
});
$driver->connect;

my $control = UAV::Pilot::WumpusRover::Control->new({
    driver => $driver,
});
isa_ok( $control => 'UAV::Pilot::WumpusRover::Control' );
does_ok( $control => 'UAV::Pilot::Control' );
does_ok( $control => 'UAV::Pilot::ControlRover' );


$control->throttle( 150 );
$control->send_move_packet;
my $throttle_packet = $driver->last_sent_packet;
isa_ok( $throttle_packet => 'UAV::Pilot::WumpusRover::Packet::RadioOutputs' );
cmp_ok( $throttle_packet->ch1_out, '==', 150, "Throttle setting sent" );
cmp_ok( $throttle_packet->ch2_out, '==', 0, "Not turning" );

$control->turn( -100 );
$control->send_move_packet;
my $turn_packet = $driver->last_sent_packet;
isa_ok( $turn_packet => 'UAV::Pilot::WumpusRover::Packet::RadioOutputs' );
cmp_ok( $turn_packet->ch1_out, '==', 150, "Still setting throttle" );
cmp_ok( $turn_packet->ch2_out, '==', -100, "And now turning to the left, too" );
