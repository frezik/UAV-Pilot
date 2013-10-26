use Test::More tests => 10;
use strict;
use warnings;
use UAV::Pilot::Control;
use UAV::Pilot::ControlRover;
use UAV::Pilot::WumpusRover::Control::Mock;
use Test::Moose;


my $control = UAV::Pilot::WumpusRover::Control::Mock->new({
    host       => 'localhost',
    port       => 49000,
});
isa_ok( $control => 'UAV::Pilot::WumpusRover::Control' );
does_ok( $control => 'UAV::Pilot::Control' );
does_ok( $control => 'UAV::Pilot::ControlRover' );

$control->connect;
my $start_request_packet = $control->last_packet_out;
isa_ok( $start_request_packet
    => 'UAV::Pilot::WumpusRover::Packet::RequestStartupMessage' );

$control->throttle( 150 );
$control->send_move_packet;
my $throttle_packet = $control->last_packet_out;
isa_ok( $throttle_packet => 'UAV::Pilot::WumpusRover::Packet::RadioOutputs' );
cmp_ok( $throttle_packet->ch1_out, '==', 150, "Throttle setting sent" );
cmp_ok( $throttle_packet->ch2_out, '==', 0, "Not turning" );

$control->turn( -100 );
$control->send_move_packet;
my $turn_packet = $control->last_packet_out;
isa_ok( $turn_packet => 'UAV::Pilot::WumpusRover::Packet::RadioOutputs' );
cmp_ok( $turn_packet->ch1_out, '==', 150, "Still setting throttle" );
cmp_ok( $turn_packet->ch2_out, '==', -100, "And now turning to the left, too" );
