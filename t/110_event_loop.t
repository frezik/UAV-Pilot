use Test::More tests => 2;
use v5.14;
use AnyEvent;
use UAV::Pilot::ARDrone::Driver::Mock;
use UAV::Pilot::ARDrone::Control::Event;
use UAV::Pilot::EasyEvent;
use Test::Moose;

my $ardrone = UAV::Pilot::ARDrone::Driver::Mock->new({
    host => 'localhost',
});
$ardrone->connect;
my $dev = UAV::Pilot::ARDrone::Control::Event->new({
    driver => $ardrone,
});
isa_ok( $dev => 'UAV::Pilot::ARDrone::Control::Event' );

my $cv = AnyEvent->condvar;
my $event = UAV::Pilot::EasyEvent->new({
    condvar => $cv,
});
$dev->init_event_loop( $cv, $event );
my $timer; $timer = AnyEvent->timer(
    after => 3,
    cb    => sub {
        my @saved_cmds = $ardrone->saved_commands;
        my $found = 0;
        foreach (@saved_cmds) {
            $found = 1 if /\AAT\*COMWDG=/;
        }
        ok( $found, "Com watchdog command sent" );
        $cv->send( "end program" );
    },
);
$cv->recv;
