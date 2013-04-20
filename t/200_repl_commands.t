use Test::More tests => 4;
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

my $seq = 0;

my @TESTS = (
    {
        cmd    => 'takeoff;',
        expect => [ "AT*REF=~SEQ~,290718208\r" ],
        name   => "Takeoff command",
    },
    {
        cmd    => 'land;',
        expect => [ "AT*REF=~SEQ~,290717696\r" ],
        name   => "Land command",
    },
);
foreach my $test (@TESTS) {
    $seq++;

    my $cmd       = $$test{cmd};
    my $test_name = $$test{name};
    my @expect    = map {
        my $out = $_;
        $out =~ s/~SEQ~/$seq/g;
        $out;
    } @{ $$test{expect} };
    
    $repl->run_cmd( $cmd );
    my @saved_cmds = $ardrone->saved_commands;
    is_deeply( 
        \@saved_cmds,
        \@expect,
        $test_name,
    );
}
