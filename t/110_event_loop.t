use Test::More tests => 2;
use v5.14;
use AnyEvent;
use UAV::Pilot::Driver::ARDrone::Mock;
use UAV::Pilot::Control::ARDrone;
use UAV::Pilot::Control::ARDrone::Event;
use Test::Moose;

my $ardrone = UAV::Pilot::Driver::ARDrone::Mock->new({
    host => 'localhost',
});
$ardrone->connect;
my $dev = UAV::Pilot::Control::ARDrone->new({
    sender => $ardrone,
});

my $cv = $dev->init_event_loop;
isa_ok( $dev => 'UAV::Pilot::Control::ARDrone::Event' );
my $timer; $timer = AnyEvent->timer(
    after => 3,
    cb    => sub {
        my @saved_cmds = $ardrone->saved_commands;
        like( $saved_cmds[$#saved_cmds], qr/\AAT\*COMWDG=/, "Com watchdog command sent" );
        $cv->send( "end program" );
    },
);
$cv->recv;
