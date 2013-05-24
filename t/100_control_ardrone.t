use Test::More tests => 51;
use v5.14;
use UAV::Pilot::Driver::ARDrone::Mock;
use UAV::Pilot::Control::ARDrone;
use Test::Moose;

my $ardrone = UAV::Pilot::Driver::ARDrone::Mock->new({
    host => 'localhost',
});
$ardrone->connect;
my $dev = UAV::Pilot::Control::ARDrone->new({
    sender => $ardrone,
});
isa_ok( $dev => 'UAV::Pilot::Control::ARDrone' );
does_ok( $dev => 'UAV::Pilot::Control' );

$ardrone->saved_commands; # Flush saved commands from connect() call

my $seq = 2;
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
        name   => "Roll method executed",
    },
    {
        method => 'yaw',
        args   => [ 1 ],
        expect => [ "AT*PCMD=~SEQ~,1,0,0,0,1065353216\r" ],
        name   => "Yaw method executed",
    },
    {
        method => 'vert_speed',
        args   => [ 0.5 ],
        expect => [ "AT*PCMD=~SEQ~,1,0,0,1056964608,0\r" ],
        name   => "Pitch method executed",
    },
    {
        method => 'calibrate',
        args   => [],
        expect => [ "AT*CALIB=~SEQ~,0\r" ],
        name   => "Calibrate method executed",
    },
    {
        method => 'phi_m30',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","0,1000"\r} ],
        name   => "phi_m30 method executed",
    },
    {
        method => 'phi_30',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","1,1000"\r} ],
        name   => "phi_30 method executed",
    },
    {
        method => 'theta_m30',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","2,1000"\r} ],
        name   => "theta_m30 method executed",
    }, 
    {
        method => 'theta_30',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","3,1000"\r} ],
        name   => "theta_30 method executed",
    }, 
    {
        method => 'theta_20deg_yaw_200',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","4,1000"\r} ],
        name   => "theta_20deg_yaw_200 method executed",
    }, 
    {
        method => 'theta_20deg_yaw_m200',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","5,1000"\r} ],
        name   => "theta_20deg_yaw_m200 method executed",
    }, 
    {
        method => 'turnaround',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","6,5000"\r} ],
        name   => "turnaround method executed",
    }, 
    {
        method => 'turnaround_godown',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","7,5000"\r} ],
        name   => "turnaround_godown method executed",
    }, 
    {
        method => 'yaw_shake',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","8,2000"\r} ],
        name   => "yaw_shake method executed",
    }, 
    {
        method => 'yaw_dance',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","9,5000"\r} ],
        name   => "yaw_dance method executed",
    }, 
    {
        method => 'phi_dance',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","10,5000"\r} ],
        name   => "phi_dance method executed",
    }, 
    {
        method => 'theta_dance',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","11,5000"\r} ],
        name   => "theta_dance method executed",
    }, 
    {
        method => 'vz_dance',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","12,5000"\r} ],
        name   => "vz_dance method executed",
    }, 
    {
        method => 'wave',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","13,5000"\r} ],
        name   => "wave method executed",
    }, 
    {
        method => 'phi_theta_mixed',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","14,5000"\r} ],
        name   => "phi_theta_mixed method executed",
    }, 
    {
        method => 'double_phi_theta_mixed',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","15,5000"\r} ],
        name   => "double_phi_theta_mixed method executed",
    }, 
    {
        method => 'flip_ahead',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","16,15"\r} ],
        name   => "flip_ahead method executed",
    }, 
    {
        method => 'flip_behind',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","17,15"\r} ],
        name   => "flip_behind method executed",
    }, 
    {
        method => 'flip_left',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","18,15"\r} ],
        name   => "Flip left method executed",
    },
    {
        method => 'flip_right',
        args   => [],
        expect => [ qq{AT*CONFIG=~SEQ~,"control:flight_anim","19,15"\r} ],
        name   => "flip_right method executed",
    }, 
    {
        method => 'emergency',
        args   => [],
        expect => [ "AT*REF=~SEQ~,290717952\r" ],
        name   => "Emergency state toggled executed",
    },
    {
        method => 'led_blink_green_red',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","0,1073741824,2"\r} ],
        name   => "led_blink_green_red method executed",
    },
    {
        method => 'led_blink_green',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","1,1073741824,2"\r} ],
        name   => "led_blink_green method executed",
    },
    {
        method => 'led_blink_red',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","2,1073741824,2"\r} ],
        name   => "led_blink_red method executed",
    },
    {
        method => 'led_blink_orange',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","3,1073741824,2"\r} ],
        name   => "led_blink_orange method executed",
    },
    {
        method => 'led_snake_green_red',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","4,1073741824,2"\r} ],
        name   => "led_snake_green_red method executed",
    },
    {
        method => 'led_fire',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","5,1073741824,2"\r} ],
        name   => "led_fire method executed",
    },
    {
        method => 'led_standard',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","6,1073741824,2"\r} ],
        name   => "led_standard method executed",
    },
    {
        method => 'led_red',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","7,1073741824,2"\r} ],
        name   => "led_red method executed",
    },
    {
        method => 'led_green',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","8,1073741824,2"\r} ],
        name   => "led_green method executed",
    },
    {
        method => 'led_red_snake',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","9,1073741824,2"\r} ],
        name   => "led_red_snake method executed",
    },
    {
        method => 'led_blank',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","10,1073741824,2"\r} ],
        name   => "led_blank method executed",
    },
    {
        method => 'led_right_missile',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","11,1073741824,2"\r} ],
        name   => "led_right_missile method executed",
    },
    {
        method => 'led_left_missile',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","12,1073741824,2"\r} ],
        name   => "led_left_missile method executed",
    },
    {
        method => 'led_double_missile',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","13,1073741824,2"\r} ],
        name   => "led_double_missile method executed",
    },
    {
        method => 'led_front_left_green_others_red',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","14,1073741824,2"\r} ],
        name   => "led_front_left_green_others_red method executed",
    },
    {
        method => 'led_front_right_green_others_red',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","15,1073741824,2"\r} ],
        name   => "led_front_right_green_others_red method executed",
    },
    {
        method => 'led_rear_right_green_others_red',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","16,1073741824,2"\r} ],
        name   => "led_rear_right_green_others_red method executed",
    },
    {
        method => 'led_rear_left_green_others_red',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","17,1073741824,2"\r} ],
        name   => "led_rear_left_green_others_red method executed",
    },
    {
        method => 'led_left_green_right_red',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","18,1073741824,2"\r} ],
        name   => "led_left_green_right_red method executed",
    },
    {
        method => 'led_left_red_right_green',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","19,1073741824,2"\r} ],
        name   => "led_left_red_right_green method executed",
    },
    {
        method => 'led_blink_standard',
        args   => [ 2.0, 2 ],
        expect => [ qq{AT*CONFIG=~SEQ~,"leds:leds_anim","20,1073741824,2"\r} ],
        name   => "led_blink_standard method executed",
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
