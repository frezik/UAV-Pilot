use Test::More tests => 3;
use v5.14;
use AnyEvent;
use UAV::Pilot::WumpusRover::Driver::Mock;
use UAV::Pilot::WumpusRover::Control::Event;
use UAV::Pilot::EasyEvent;
use UAV::Pilot::SDL::Joystick;


my $wumpus = UAV::Pilot::WumpusRover::Driver::Mock->new({
});
$wumpus->connect;
my $dev = UAV::Pilot::WumpusRover::Control::Event->new({
    driver       => $wumpus,
    joystick_num => 0,

});

my $cv = AnyEvent->condvar;
my $event = UAV::Pilot::EasyEvent->new({
    condvar => $cv,
});
$dev->init_event_loop( $cv, $event );

$event->send_event( UAV::Pilot::SDL::Joystick->EVENT_NAME, {
    joystick_num => 0,
    roll         => UAV::Pilot::SDL::Joystick->MAX_AXIS_INT,
    pitch        => 0,
    yaw          => 0,
    throttle     => UAV::Pilot::SDL::Joystick->MAX_AXIS_INT,
    buttons      => [ 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, ],
});
cmp_ok( $dev->turn,     '==', 180, "Set turn from joystick" );
cmp_ok( $dev->throttle, '==', 100, "Set throttle from joystick" );

$event->send_event( UAV::Pilot::SDL::Joystick->EVENT_NAME, {
    joystick_num => 1,
    roll         => 0,
    pitch        => 0,
    yaw          => 0,
    throttle     => 0,
    buttons      => [ 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, ],
});
cmp_ok( $dev->throttle, '==', 100, "Only picks up events from joystick 0" );
