use Test::More tests => 5;
use strict;
use warnings;
use AnyEvent;
use UAV::Pilot::Control;
use UAV::Pilot::ControlRover;
use UAV::Pilot::EasyEvent;
use UAV::Pilot::WumpusRover::Control::Event;
use UAV::Pilot::WumpusRover::Driver::Mock;
use Test::Moose;


my $driver = UAV::Pilot::WumpusRover::Driver::Mock->new({
    host => 'localhost',
    port => 49000,
});
$driver->connect;

my $control = UAV::Pilot::WumpusRover::Control::Event->new({
    driver => $driver,
});
isa_ok( $control => 'UAV::Pilot::WumpusRover::Control::Event' );
isa_ok( $control => 'UAV::Pilot::WumpusRover::Control' );

my $cv = AnyEvent->condvar;
my $event = UAV::Pilot::EasyEvent->new({
    condvar => $cv,
});
$control->init_event_loop( $cv, $event );

my $ack_recv = 0;
my $checksum1_match = 0;
my $checksum2_match = 0;
$event->add_event( 'ack_recv' => sub {
    my ($sent_packet, $ack_packet) = @_;
    $ack_recv++;
    $checksum1_match++
        if $sent_packet->checksum1 == $ack_packet->checksum_received1;
    $checksum2_match++
        if $sent_packet->checksum2 == $ack_packet->checksum_received2;
});

my $write_time = $control->CONTROL_UPDATE_TIME;
my $write_duration = $write_time * 2 + ($write_time / 2);
my $test_timer; $test_timer = AnyEvent->timer(
    after => $write_duration,
    cb => sub {
        cmp_ok( $ack_recv, '>', 1, "Ack control packets" );
        cmp_ok( $checksum1_match, '==', $ack_recv, "Checksum1 matched up" );
        cmp_ok( $checksum2_match, '==', $ack_recv, "Checksum2 matched up" );
        $cv->send;
        $test_timer;
    },
);

my $send_timer; $send_timer = AnyEvent->timer(
    after => $write_time,
    cb => sub {
        $control->throttle( 100 );
        $control->turn( -50 );
        $send_timer;
    },
);


$cv->recv;
