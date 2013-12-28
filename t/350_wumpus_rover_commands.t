use Test::More tests => 7;
use strict;
use warnings;
use UAV::Pilot::WumpusRover::Control;
use UAV::Pilot::WumpusRover::Driver::Mock;
use UAV::Pilot::Commands;
use AnyEvent;

my $LIB_DIR = 'share';


my $driver = UAV::Pilot::WumpusRover::Driver::Mock->new({
    host => 'localhost',
    port => 49000,
});
$driver->connect;
my $control = UAV::Pilot::WumpusRover::Control->new({
    driver => $driver,
});

my $repl = UAV::Pilot::Commands->new({
    controller_callback_wumpusrover => sub { $control },
});
my $cv = AnyEvent->condvar;


$repl->add_lib_dir( UAV::Pilot->default_module_dir );
$repl->load_lib( 'WumpusRover', {
    controller => $control,
    condvar    => $cv,
});
pass( "WumpusRover library loaded" );

my @TESTS = (
    {
        cmd    => 'throttle 100;',
        expect => {
            packet_type => 'RadioOutputs',
            ch1_out     => 100,
            ch2_out     => 0,
        },
        name   => "Throttle command",
    },
    {
        cmd    => 'turn 90;',
        expect => {
            packet_type => 'RadioOutputs',
            ch1_out     => 100,
            ch2_out     => 90,
        },
        name   => "Turn command (combined with previous throttle)",
    },
    {
        cmd    => 'stop;',
        expect => {
            packet_type => 'RadioOutputs',
            ch1_out     => 0,
            ch2_out     => 0,
        },
        name   => "Stop command",
    },
);
foreach my $test (@TESTS) {
    my $cmd       = $$test{cmd};
    my $test_name = $$test{name};
    my $expect    = $$test{expect};

    my $expect_packet_type = 'UAV::Pilot::WumpusRover::Packet::'
        . delete $$expect{packet_type};

    $repl->run_cmd( $cmd );
    # This would normally be handled by UAV::Pilot::WumpusRover::Control::Event,
    # but we're not using that in this test.
    $control->send_move_packet;

    my $last_sent_packet = $driver->last_sent_packet;
    my $got = {
        map {
            $_ => $last_sent_packet->$_;
        } keys %$expect
    };
    
    isa_ok( $last_sent_packet => $expect_packet_type );
    is_deeply( 
        $got,
        $expect,
        $test_name,
    );
}
