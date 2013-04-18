use Test::More tests => 3;
use v5.14;
use UAV::Pilot::Sender::ARDrone::Mock;
use UAV::Pilot::Device::ARDrone;

my $ardrone = UAV::Pilot::Sender::ARDrone::Mock->new({
    host => 'localhost',
});
my $dev = UAV::Pilot::Device::ARDrone->new({
    sender => $ardrone,
});
isa_ok( $dev => 'UAV::Pilot::Device::ARDrone' );
isa_ok( $dev => 'UAV::Pilot::Device' );

$dev->takeoff;
my @saved_cmds = $ardrone->saved_commands;
is_deeply( 
    \@saved_cmds,
    [ "AT*REF=1,290718208\r" ],
    "Takeoff command executed",
);
