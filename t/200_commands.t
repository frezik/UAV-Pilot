use Test::More tests => 5;
use v5.14;
use UAV::Pilot;
use UAV::Pilot::Sender::ARDrone::Mock;
use UAV::Pilot::Device::ARDrone;
use UAV::Pilot::Commands;

my $LIB_DIR = 'uav_mods';


my $ardrone = UAV::Pilot::Sender::ARDrone::Mock->new({
    host => 'localhost',
});
$ardrone->connect;
my $repl = UAV::Pilot::Commands->new({
    device => UAV::Pilot::Device::ARDrone->new({
        sender => $ardrone,
    }),
});
isa_ok( $repl => 'UAV::Pilot::Commands' );


eval {
    $repl->run_cmd( 'mock;' );
};
ok( $@, "No such command 'mock'" );

eval {
    $repl->run_cmd( q{load 'Mock';} );
};
ok( $@, "Could not find library named 'Mock' in search dirs" );

$repl->add_lib_dir( UAV::Pilot->default_module_dir );
$repl->run_cmd( q{load 'Mock';} );
$repl->run_cmd( 'mock;' );
ok( 1, "Mock command ran" );

$repl->run_cmd( q{load 'Mock' => 'Local'} );
$repl->run_cmd( 'Local::mock;' );
ok( 1, "Mock commands placed in namespace" );
