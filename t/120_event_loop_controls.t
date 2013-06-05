use Test::More tests => 3;
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

$dev->pitch( -0.8 );
my $found = 0;
my @saved_cmds = $ardrone->saved_commands;
foreach (@saved_cmds) {
    $found = 1 if /\AAT\*PCMD=\d+,\d+,\d+,-1085485875/;
}
ok(! $found, "Pitch command not yet sent" );

my $control_timer; $control_timer = AnyEvent->timer(
    after => 3,
    cb    => sub {
        my @saved_cmds = $ardrone->saved_commands;

        my $found = 0;
        foreach (@saved_cmds) {
            $found = 1 if /\AAT\*PCMD=\d+,\d+,\d+,-1085485875/;
        }
        ok( $found, "Pitch command sent" );

        $dev->hover;
    },
);
my $hover_timer; $hover_timer = AnyEvent->timer(
    after => 4,
    cb    => sub {
        my @saved_cmds = $ardrone->saved_commands;

        my $found = 0;
        foreach (@saved_cmds) {
            $found = 1 if /\AAT\*PCMD=/;
        }
        ok(! $found, "Hover mode, no movement command sent" );

        $cv->send( "end program" );
    },
);

$cv->recv;
