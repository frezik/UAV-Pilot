use Test::More tests => 8;
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


cmp_ok( $dev->_convert_sdl_input( 0 ),      '==', 0.0,  "Convert SDL input 0" );
cmp_ok( $dev->_convert_sdl_input( 32768 ),  '==', 1.0,  "Convert SDL input 2**15" );
cmp_ok( $dev->_convert_sdl_input( -32767 ), '==', -0.999969482421875,
    "Convert SDL input -(2**15 + 1)" );
cmp_ok( $dev->_convert_sdl_input( 16384 ),  '==', 0.5,  "Convert SDL input 16384" );
cmp_ok( $dev->_convert_sdl_input( -32768 ), '==', -1.0, "Convert overflow input" );


my $cv = AnyEvent->condvar;
my $event = UAV::Pilot::EasyEvent->new({
    condvar => $cv,
});
$dev->init_event_loop( $cv, $event );

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
