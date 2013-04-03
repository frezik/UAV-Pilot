use Test::More tests => 6;
use v5.14;
use UAV::Pilot;
use UAV::Pilot::Sender;
use UAV::Pilot::Sender::ARDrone;
use UAV::Pilot::Sender::ARDrone::Mock;

my $ardrone_mock = UAV::Pilot::Sender::ARDrone::Mock->new({
    port => 7776,
});
ok( $ardrone_mock, "Created object" );
isa_ok( $ardrone_mock => 'UAV::Pilot::Sender::ARDrone::Mock' );
cmp_ok( $ardrone_mock->port, '==', 7776, "Port set" );


my $seq = 1;

my @TESTS = (
    {
        run       => 'at_ref',
        args      => [ 1, 0 ],
        expect    => "AT*REF=~SEQ~,290718208\r",
        test_name => 'Takeoff command',
    },
    {
        run       => 'at_pcmd',
        args      => [ 1, 1, 0.5, 0.25, -0.5, -1 ],
        expect    => "AT*PCMD=~SEQ~,3,0.5,0.25,-0.5,-1\r",
        test_name => 'Set progressive motion command',
    },
    {
        run       => 'at_ftrim',
        args      => [],
        expect    => "AT*FTRIM=~SEQ~\r",
        test_name => 'Set reference to horizontal plane',
    },
);
foreach (@TESTS) {
    my $method = $_->{run};
    my @args   = @{ $_->{args} };
    my $expect = $_->{expect};
    $expect =~ s/~SEQ~/$seq/g;
    my $test_name = $_->{test_name};

    $ardrone_mock->$method( @args );
    my $got = $ardrone_mock->last_cmd;
    cmp_ok( $got, 'eq', $expect, $test_name );

    $seq++;
}


eval {
    $ardrone_mock->at_pcmd( 1, 1, 2, 0, 0, 0 );
};
if( $@ ) {
    local $TODO = "Errors not yet thrown";
    ok( 'Caught Out of Range error' );
    cmp_ok( $seq, '==', $ardrone_mock->seq,
        "Sequence was not incrmented for Out of Range error" );
}
