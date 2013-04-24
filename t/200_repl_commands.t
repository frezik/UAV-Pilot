use Test::More tests => 9;
use v5.14;
use UAV::Pilot::Sender::ARDrone::Mock;
use UAV::Pilot::Device::ARDrone;
use UAV::Pilot::REPLCommands;


my $ardrone = UAV::Pilot::Sender::ARDrone::Mock->new({
    host => 'localhost',
});
$ardrone->connect;
my $repl = UAV::Pilot::REPLCommands->new({
    device => UAV::Pilot::Device::ARDrone->new({
        sender => $ardrone,
    }),
});
isa_ok( $repl => 'UAV::Pilot::REPLCommands' );

$ardrone->saved_commands; # Flush saved commands from connect() call

UAV::Pilot::REPLCommands::run_cmd( 'takeoff;' );
cmp_ok( scalar($ardrone->saved_commands), '==', 0,
    'run_cmd does nothing when called without $self' );

my $seq = 1; # One command already sent by $ardrone->connect()
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
    {
        cmd    => 'pitch -1;',
        expect => [ "AT*PCMD=~SEQ~,1,0,-1082130432,0,0\r" ],
        name   => "Pitch command executed",
    },
    {
        cmd    => 'roll -1;',
        expect => [ "AT*PCMD=~SEQ~,1,-1082130432,0,0,0\r" ],
        name   => "Roll command executed",
    },
    {
        cmd    => 'yaw 1;',
        expect => [ "AT*PCMD=~SEQ~,1,0,0,0,1065353216\r" ],
        name   => "Yaw command executed",
    },
    {
        cmd    => 'vert_speed 0.5;',
        expect => [ "AT*PCMD=~SEQ~,1,0,0,1056964608,0\r" ],
        name   => "Vert Speed command executed",
    },
    {
        cmd    => 'calibrate;',
        expect => [ "AT*CALIB=~SEQ~,0\r" ],
        name   => "Calibrate command executed",
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
