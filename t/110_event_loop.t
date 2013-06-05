use Test::More tests => 2;
use v5.14;
use AnyEvent;
use UAV::Pilot::Driver::ARDrone::Mock;
use UAV::Pilot::Control::ARDrone::Event;
use Test::Moose;

my $ardrone = UAV::Pilot::Driver::ARDrone::Mock->new({
    host => 'localhost',
});
$ardrone->connect;
my $dev = UAV::Pilot::Control::ARDrone::Event->new({
    sender => $ardrone,
});
isa_ok( $dev => 'UAV::Pilot::Control::ARDrone::Event' );

my $cv = $dev->init_event_loop;
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
