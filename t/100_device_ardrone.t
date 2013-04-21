use Test::More tests => 7;
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

my $seq = 0;

my @TESTS = (
    {
        method => 'takeoff',
        args   => [],
        expect => [ "AT*REF=~SEQ~,290718208\r" ],
        name   => "Takeoff method executed",
    },
    {
        method => 'land',
        args   => [],
        expect => [ "AT*REF=~SEQ~,290717696\r" ],
        name   => "Land method executed",
    },
    {
        method => 'pitch',
        args   => [ -1 ],
        expect => [ "AT*PCMD=~SEQ~,1,0,-1082130432,0,0\r" ],
        name   => "Pitch method executed",
    },
    {
        method => 'roll',
        args   => [ -1 ],
        expect => [ "AT*PCMD=~SEQ~,1,-1082130432,0,0,0\r" ],
        name   => "Pitch method executed",
    },
    {
        method => 'yaw',
        args   => [ 1 ],
        expect => [ "AT*PCMD=~SEQ~,1,0,0,0,1065353216\r" ],
        name   => "Pitch method executed",
    },
);
foreach my $test (@TESTS) {
    $seq++;

    my $method    = $$test{method};
    my $args      = $$test{args},
    my $test_name = $$test{name};
    my @expect    = map {
        my $out = $_;
        $out =~ s/~SEQ~/$seq/g;
        $out;
    } @{ $$test{expect} };
    
    $dev->$method( @$args );
    my @saved_cmds = $ardrone->saved_commands;
    is_deeply( 
        \@saved_cmds,
        \@expect,
        $test_name,
    );
}
