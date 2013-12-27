use Test::More tests => 5;
use v5.14;
use AnyEvent;
use UAV::Pilot::ARDrone::Driver::Mock;
use UAV::Pilot::ARDrone::Control::Event;
use UAV::Pilot::EasyEvent;
use UAV::Pilot::SDL::Joystick;


my $ardrone = UAV::Pilot::ARDrone::Driver::Mock->new({
    host         => 'localhost',
});
$ardrone->connect;
my $dev = UAV::Pilot::ARDrone::Control::Event->new({
    driver               => $ardrone,
    joystick_num         => 0,
    joystick_takeoff_btn => 8,
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
    throttle     => 0,
    buttons      => [ 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, ],
});
$event->send_event( UAV::Pilot::SDL::Joystick->EVENT_NAME, {
    joystick_num => 1,
    roll         => 0,
    pitch        => UAV::Pilot::SDL::Joystick->MIN_AXIS_INT,
    yaw          => 0,
    throttle     => 0,
    buttons      => [ 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, ],
});
cmp_ok( $dev->cur_roll, '==', 1, "Only picks up events from joystick 0" );

ok(! $dev->in_air, "Hasn't taken off yet" );
$event->send_event( UAV::Pilot::SDL::Joystick->EVENT_NAME, {
    joystick_num => 0,
    roll         => UAV::Pilot::SDL::Joystick->MAX_AXIS_INT,
    pitch        => 0,
    yaw          => 0,
    throttle     => 0,
    buttons      => [ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, ],
});
ok( $dev->in_air, "Has taken off" );

$event->send_event( UAV::Pilot::SDL::Joystick->EVENT_NAME, {
    joystick_num => 0,
    roll         => UAV::Pilot::SDL::Joystick->MAX_AXIS_INT,
    pitch        => 0,
    yaw          => 0,
    throttle     => 0,
    buttons      => [ 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, ],
});
ok( $dev->in_air, "Still in air" );

$event->send_event( UAV::Pilot::SDL::Joystick->EVENT_NAME, {
    joystick_num => 0,
    roll         => UAV::Pilot::SDL::Joystick->MAX_AXIS_INT,
    pitch        => 0,
    yaw          => 0,
    throttle     => 0,
    buttons      => [ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, ],
});
ok(! $dev->in_air, "Landed" );
