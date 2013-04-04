use Test::More tests => 15;
use v5.14;
use UAV::Pilot;
use UAV::Pilot::Exceptions;
use UAV::Pilot::Sender;
use UAV::Pilot::Sender::ARDrone;
use UAV::Pilot::Sender::ARDrone::Mock;

my $ardrone_mock = UAV::Pilot::Sender::ARDrone::Mock->new({
    host => 'localhost',
    port => 7776,
});
ok( $ardrone_mock, "Created object" );
isa_ok( $ardrone_mock => 'UAV::Pilot::Sender::ARDrone::Mock' );
cmp_ok( $ardrone_mock->port, '==', 7776, "Port set" );

ok( $ardrone_mock->connect, "Connect to ARDrone" );


my $seq = 0;

my @TESTS = (
    {
        run       => 'at_ref',
        args      => [ 1, 0 ],
        expect    => "AT*REF=~SEQ~,290718208\r",
        test_name => 'Takeoff command',
    },
    {
        run       => 'at_pcmd',
        args      => [ 1, 1, -0.8, -0.8, -0.8, -0.8 ],
        expect    => "AT*PCMD=~SEQ~,3,-1085485875,-1085485875,-1085485875,-1085485875\r",
        test_name => 'Set progressive motion command',
    },
    {
        run       => 'at_ftrim',
        args      => [],
        expect    => "AT*FTRIM=~SEQ~\r",
        test_name => 'Set reference to horizontal plane command',
    },
    {
        run       => 'at_config',
        args      => [ 'SYSLOG:output', '5' ],
        expect    => qq{AT*CONFIG=~SEQ~,"SYSLOG:output","5"\r},
        test_name => 'Set config option command',
    },
    {
        run       => 'at_config_ids',
        args      => [ '1234', '5678', '9012' ],
        expect    => "AT*CONFIG_IDS=~SEQ~,1234,5678,9012\r",
        test_name => 'Config IDs command',
    },
    {
        run       => 'at_comwdg',
        args      => [ ],
        expect    => "AT*COMWDG=~SEQ~\r",
        test_name => 'Reset comm watchdog command',
    },
    {
        run       => 'at_led',
        args      => [ 1, 1.5, 6 ],
        expect    => "AT*LED=~SEQ~,1,1.5,6\r",
        test_name => 'Play LED sequence command',
    },
    {
        run       => 'at_anim',
        args      => [ 1, 20 ],
        expect    => "AT*ANIM=~SEQ~,1,20\r",
        test_name => 'Animation command',
    },
);
foreach (@TESTS) {
    $seq++;

    my $method = $_->{run};
    my @args   = @{ $_->{args} };
    my $expect = $_->{expect};
    $expect =~ s/~SEQ~/$seq/g;
    my $test_name = $_->{test_name};

    $ardrone_mock->$method( @args );
    my $got = $ardrone_mock->last_cmd;
    cmp_ok( $got, 'eq', $expect, $test_name );
}


eval {
    $ardrone_mock->at_pcmd( 1, 1, 2, 0, 0, 0 );
};
if( $@ && $@->isa( 'UAV::Pilot::NumberOutOfRangeException' ) ) {
    ok( 'Caught Out of Range exception' );
    cmp_ok( $seq, '==', $ardrone_mock->seq,
        "Sequence was not incrmented for Out of Range error" );
}

my $ardrone_port_check = UAV::Pilot::Sender::ARDrone::Mock->new({
    host => 'localhost',
});
cmp_ok( $ardrone_port_check->port, '==', 5556, "Correct default port" );
