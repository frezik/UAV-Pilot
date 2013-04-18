use Test::More tests => 3;
use v5.14;
use UAV::Pilot::Sender::ARDrone::Mock;
use UAV::Pilot::Device::ARDrone;
use UAV::Pilot::REPLCommands;


my $ardrone = UAV::Pilot::Sender::ARDrone::Mock->new({
    host => 'localhost',
});
my $repl = UAV::Pilot::REPLCommands->new({
    device => UAV::Pilot::Device::ARDrone->new({
        sender => $ardrone,
    }),
});
isa_ok( $repl => 'UAV::Pilot::REPLCommands' );

UAV::Pilot::REPLCommands::run_cmd( 'takeoff;' );
cmp_ok( scalar($ardrone->saved_commands), '==', 0,
    'run_cmd does nothing when called without $self' );

$repl->run_cmd( 'takeoff;' );
my @saved_cmds = $ardrone->saved_commands;
is_deeply( 
    \@saved_cmds,
    [ "AT*REF=1,290718208\r" ],
    "Takeoff command executed",
);
