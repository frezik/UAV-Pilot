#!/usr/bin/perl
use v5.14;
use warnings;
use AnyEvent;
use SDL;
use SDL::Joystick;
use UAV::Pilot;
use UAV::Pilot::Commands;
use UAV::Pilot::Driver::ARDrone;
use UAV::Pilot::Control::ARDrone::Event;

SDL::init_sub_system( SDL_INIT_JOYSTICK );
die "No joysticks found\n" unless SDL::Joystick::num_joysticks();


my $IP             = '192.168.1.1';
my $JOYSTICK_NUM   = 0;
my $ROLL_AXIS      = 0;
my $PITCH_AXIS     = 1;
my $YAW_AXIS       = 2;
my $THROTTLE_AXIS  = 3;
my $TAKEOFF_BUTTON = 0;
my $MAX_AXIS_INT   = 32767;


sub init_ardrone
{
    my $ardrone = UAV::Pilot::Driver::ARDrone->new({
        host => $IP,
    });
    $ardrone->connect;

    my $dev = UAV::Pilot::Control::ARDrone::Event->new({
        sender => $ardrone,
    });

    return $dev;
}

sub to_ardrone_float
{
    my ($num) = @_;
    return $num / $MAX_AXIS_INT;
}


{
    #my $dev = init_ardrone;
    say "Connecting to joystick [" . SDL::Joystick::name( $JOYSTICK_NUM ) . "]";
    my $joystick = SDL::Joystick->new( $JOYSTICK_NUM );
    die "Could not open joystick $JOYSTICK_NUM\n" unless $joystick;

    #my $cv = $dev->init_event_loop;
    my $cv = AnyEvent->condvar;
    my $is_flying = 0;
    my $prev_takeoff_btn = 0;
    my $timer; $timer = AnyEvent->timer(
        after => 1,
        interval => 1 / 60,
        cb => sub {
            SDL::Joystick::update();
            my $roll        = to_ardrone_float( $joystick->get_axis( $ROLL_AXIS ) );
            my $pitch       = to_ardrone_float( $joystick->get_axis( $PITCH_AXIS ) );
            my $yaw         = to_ardrone_float( $joystick->get_axis( $YAW_AXIS ) );
            my $throttle    = - to_ardrone_float( $joystick->get_axis( $THROTTLE_AXIS ) );
            my $takeoff_btn = $joystick->get_button( $TAKEOFF_BUTTON );

            # Only takeoff/land after we let off the button
            if( $prev_takeoff_btn && ($takeoff_btn == 0) ) {
                if( $is_flying ) {
                    $is_flying = 0;
                }
                else {
                    $is_flying = 1;
                }
            }
            $prev_takeoff_btn = $takeoff_btn;

            say "Joystick roll [$roll], pitch [$pitch], yaw [$yaw], throttle [$throttle], takeoff btn [$takeoff_btn], is_flying [$is_flying]";
            
            $timer;
        },
    );

    $cv->recv;
    $joystick->close;
}
