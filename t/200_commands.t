use Test::More tests => 7;
use v5.14;
use UAV::Pilot;
use UAV::Pilot::ARDrone::Driver::Mock;
use UAV::Pilot::ARDrone::Control;
use UAV::Pilot::Commands;

my $LIB_DIR = 'uav_mods';


my $ardrone = UAV::Pilot::ARDrone::Driver::Mock->new({
    host => 'localhost',
});
$ardrone->connect;
my $repl = UAV::Pilot::Commands->new({
    device => UAV::Pilot::ARDrone::Control->new({
        driver => $ardrone,
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

$repl->run_cmd( q(load 'Mock', { namespace => 'Local' };) );
$repl->run_cmd( 'Local::mock;' );
ok( 1, "Mock commands placed in namespace" );

$repl->run_cmd( q(load 'MockInit', { setting => 5 };) );
cmp_ok( $UAV::Pilot::mock_init_set, '==', 5,
    "MockInit loaded and ran uav_module_init() with param" );

eval {
    $repl->run_cmd( 'uav_module_init();' );
};
ok( $@, "MockInit uav_module_init() call does not appear" );
