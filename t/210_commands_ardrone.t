use Test::More tests => 29;
use v5.14;
use UAV::Pilot::Sender::ARDrone::Mock;
use UAV::Pilot::Device::ARDrone;
use UAV::Pilot::Commands;


my $ardrone = UAV::Pilot::Sender::ARDrone::Mock->new({
    host => 'localhost',
});
$ardrone->connect;
my $repl = UAV::Pilot::Commands->new({
    device => UAV::Pilot::Device::ARDrone->new({
        sender => $ardrone,
    }),
});

$ardrone->saved_commands; # Flush saved commands from connect() call

UAV::Pilot::Commands::run_cmd( 'takeoff;' );
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
    {
        cmd    => 'phi_m30;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","0,1000"\r} ],
        name   => "Phi m30 command executed",
    },
    {
        cmd    => 'phi_30;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","1,1000"\r} ],
        name   => "Phi 30 command executed",
    },
    {
        cmd    => 'theta_m30;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","2,1000"\r} ],
        name   => "Theta m30 command executed",
    },
    {
        cmd    => 'theta_30;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","3,1000"\r} ],
        name   => "Theta 30 command executed",
    },
    {
        cmd    => 'theta_20deg_yaw_200;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","4,1000"\r} ],
        name   => "Theta_20deg_yaw_200 command executed",
    },
    {
        cmd    => 'theta_20deg_yaw_m200;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","5,1000"\r} ],
        name   => "Theta_20deg_yaw_m200 command executed",
    },
    {
        cmd    => 'turnaround;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","6,5000"\r} ],
        name   => "Turnaround command executed",
    },
    {
        cmd    => 'turnaround_godown;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","7,5000"\r} ],
        name   => "Turnaround God Own (go down) command executed",
    },
    {
        cmd    => 'yaw_shake;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","8,2000"\r} ],
        name   => "Yaw Shake command executed",
    },
    {
        cmd    => 'yaw_dance;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","9,5000"\r} ],
        name   => "Yaw Dance command executed",
    },
    {
        cmd    => 'phi_dance;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","10,5000"\r} ],
        name   => "Phi Dance command executed",
    },
    {
        cmd    => 'theta_dance;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","11,5000"\r} ],
        name   => "Theta Dance command executed",
    },
    {
        cmd    => 'vz_dance;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","12,5000"\r} ],
        name   => "VZ Dance command executed",
    },
    {
        cmd    => 'wave;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","13,5000"\r} ],
        name   => "Wave command executed",
    },
    {
        cmd    => 'phi_theta_mixed;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","14,5000"\r} ],
        name   => "Phi Theta Mixed command executed",
    },
    {
        cmd    => 'double_phi_theta_mixed;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","15,5000"\r} ],
        name   => "Double Phi Theta Mixed command executed",
    },
    {
        cmd    => 'flip_ahead;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","16,15"\r} ],
        name   => "Flip Ahead command executed",
    },
    {
        cmd    => 'flip_behind;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","17,15"\r} ],
        name   => "Flip Behind command executed",
    },
    {
        cmd    => 'flip_left;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","18,15"\r} ],
        name   => "Flip left command executed",
    },
    {
        cmd    => 'flip_right;',
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","19,15"\r} ],
        name   => "Flip Right command executed",
    },
    {
        cmd    => 'emergency;',
        expect => [ "AT*REF=~SEQ~,290717952\r" ],
        name   => "Emergency command",
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
