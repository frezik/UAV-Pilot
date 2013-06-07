package UAV::Pilot::Control::ARDrone;
use v5.14;
use Moose;
use namespace::autoclean;

with 'UAV::Pilot::Control';


sub takeoff
{
    my ($self) = @_;
    $self->sender->at_ref( 1, 0 );
    return 1;
}

sub land
{
    my ($self) = @_;
    $self->sender->at_ref( 0, 0 );
}

sub pitch
{
    my ($self, $pitch) = @_;
    $self->sender->at_pcmd( 1, 0, 0, $pitch, 0, 0 );
}

sub roll
{
    my ($self, $roll) = @_;
    $self->sender->at_pcmd( 1, 0, $roll, 0, 0, 0 );
}

sub yaw
{
    my ($self, $yaw) = @_;
    $self->sender->at_pcmd( 1, 0, 0, 0, 0, $yaw );
}

sub vert_speed
{
    my ($self, $speed) = @_;
    $self->sender->at_pcmd( 1, 0, 0, 0, $speed, 0 );
}

sub calibrate
{
    my ($self) = @_;
    $self->sender->at_calib( $self->sender->ARDRONE_CALIBRATION_DEVICE_MAGNETOMETER );
}

sub emergency
{
    my ($self) = @_;
    $self->sender->at_ref( 0, 1 );
    return 1;
}

sub reset_watchdog
{
    my ($self) = @_;
    $self->sender->at_comwdg();
    return 1;
}

sub hover
{
    my ($self) = @_;
    return 1;
}

{
    my $send = 'UAV::Pilot::Driver::ARDrone';
    my @FLIGHT_ANIMS = (
        {
            name   => 'phi_m30',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_M30_DEG,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_M30_DEG_MAYDAY,
        },
        {
            name   => 'phi_30',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_30_DEG,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_30_DEG_MAYDAY,
        },
        {
            name   => 'theta_m30',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_M30_DEG,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_M30_DEG_MAYDAY,
        },
        {
            name   => 'theta_30',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_30_DEG,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_30_DEG_MAYDAY,
        },
        {
            name   => 'theta_20deg_yaw_200',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_20DEG_YAW_200DEG,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_20DEG_YAW_200DEG_MAYDAY,
        },
        {
            name   => 'theta_20deg_yaw_m200',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_20DEG_YAW_M200DEG,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_20DEG_YAW_M200DEG_MAYDAY,
        },
        {
            name   => 'turnaround',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_TURNAROUND,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_TURNAROUND_MAYDAY,
        },
        {
            name   => 'turnaround_godown',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_TURNAROUND_GODOWN,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_TURNAROUND_GODOWN_MAYDAY,
        },
        {
            name   => 'yaw_shake',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_YAW_SHAKE,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_YAW_SHAKE_MAYDAY,
        },
        {
            name   => 'yaw_dance',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_YAW_DANCE,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_YAW_DANCE_MAYDAY,
        },
        {
            name   => 'phi_dance',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_DANCE,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_DANCE_MAYDAY,
        },
        {
            name   => 'theta_dance',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_DANCE,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_DANCE_MAYDAY,
        },
        {
            name   => 'vz_dance',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_VZ_DANCE,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_VZ_DANCE_MAYDAY,
        },
        {
            name   => 'wave',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_WAVE,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_WAVE_MAYDAY,
        },
        {
            name   => 'phi_theta_mixed',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_THETA_MIXED,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_THETA_MIXED_MAYDAY,
        },
        {
            name   => 'double_phi_theta_mixed',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_DOUBLE_PHI_THETA_MIXED,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_DOUBLE_PHI_THETA_MIXED_MAYDAY,
        },
        {
            name   => 'flip_ahead',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_AHEAD,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_AHEAD_MAYDAY,
        },
        {
            name   => 'flip_behind',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_BEHIND,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_BEHIND_MAYDAY,
        },
        {
            name   => 'flip_left',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_LEFT,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_LEFT_MAYDAY,
        },
        {
            name   => 'flip_right',
            anim   => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_RIGHT,
            mayday => $send->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_RIGHT_MAYDAY,
        },
    );
    foreach my $def (@FLIGHT_ANIMS) {
        my $name   = $def->{name};
        my $anim   = $def->{anim};
        my $mayday = $def->{mayday};

        no strict 'refs';
        *$name = sub {
            my ($self) = @_;
            $self->sender->at_config(
                $self->sender->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM,
                sprintf( '%d,%d', $anim, $mayday ),
            );
        };
    }
}

{
    my $send = 'UAV::Pilot::Driver::ARDrone';

    my @LED_ANIMS = (
        {
            name => 'led_blink_green_red',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_BLINK_GREEN_RED,
        },
        {
            name => 'led_blink_green',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_BLINK_GREEN,
        },
        {
            name => 'led_blink_red',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_BLINK_RED,
        },
        {
            name => 'led_blink_orange',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_BLINK_ORANGE,
        },
        {
            name => 'led_snake_green_red',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_SNAKE_GREEN_RED,
        },
        {
            name => 'led_fire',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_FIRE,
        },
        {
            name => 'led_standard',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_STANDARD,
        },
        {
            name => 'led_red',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_RED,
        },
        {
            name => 'led_green',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_GREEN,
        },
        {
            name => 'led_red_snake',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_RED_SNAKE,
        },
        {
            name => 'led_blank',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_BLANK,
        },
        {
            name => 'led_right_missile',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_RIGHT_MISSILE,
        },
        {
            name => 'led_left_missile',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_LEFT_MISSILE,
        },
        {
            name => 'led_double_missile',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_DOUBLE_MISSILE,
        },
        {
            name => 'led_front_left_green_others_red',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_FRONT_LEFT_GREEN_OTHERS_RED,
        },
        {
            name => 'led_front_right_green_others_red',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_FRONT_RIGHT_GREEN_OTHERS_RED,
        },
        {
            name => 'led_rear_left_green_others_red',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_REAR_LEFT_GREEN_OTHERS_RED,
        },
        {
            name => 'led_rear_right_green_others_red',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_REAR_RIGHT_GREEN_OTHERS_RED,
        },
        {
            name => 'led_left_green_right_red',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_LEFT_GREEN_RIGHT_RED,
        },
        {
            name => 'led_left_red_right_green',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_LEFT_RED_RIGHT_GREEN,
        },
        {
            name => 'led_blink_standard',
            anim => $send->ARDRONE_CONFIG_LED_ANIMATION_BLINK_STANDARD,
        },
    );
    foreach my $def (@LED_ANIMS) {
        my $name = $def->{name};
        my $anim = $def->{anim};

        no strict 'refs';
        *$name = sub {
            my ($self, $freq, $duration) = @_;
            $self->sender->at_config(
                $self->sender->ARDRONE_CONFIG_LEDS_LEDS_ANIM,
                sprintf( '%d,%d,%d',
                    $anim,
                    $self->sender->float_convert( $freq ),
                    $duration,
                ),
            );
        };
    }
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME

  UAV::Pilot::Control::ARDrone

=head1 SYNOPSIS

    my $sender = UAV::Pilot::Driver::ARDrone->new( ... );
    $sender->connect;
    my $dev = UAV::Pilot::Control::ARDrone->new({
        sender => $sender,
    });
    
    $dev->takeoff;
    $dev->pitch( 0.5 );
    $dev->wave;
    $dev->flip_left;
    $dev->land;

=head1 DESCRIPTION

L<UAV::Pilot::Control> implementation for the Parrot AR.Drone.

=head1 METHODS

=head2 takeoff

Takeoff.

=head2 land

Land.

=head2 pitch

    pitch( 0.5 )

Pitch (front-to-back movement).  Takes a floating point number between -1.0 and 1.0.  On 
the AR.Drone, negative numbers pitch the nose down and fly forward.

=head2 roll

    roll( -1.0 )

Roll (left-to-right movement).  Takes a floating point number between -1.0 and 1.0.  On 
the AR.Drone, negative numbers go left.

=head2 yaw

    yaw( -0.25 )

Yaw (spin).  Takes a floating point number between -1.0 and 1.0.  On the AR.Drone, 
negative numbers spin left.

=head2 vert_speed

    vert_speed( 0.7 )

Change the vertical speed.  Takes a floating point number between -1.0 and 1.0.  On the 
AR.Drone, negative numbers make it go down.

=head2 calibrate

Calibrates the magnetometer.  This must be done while in flight.  The drone will spin 
around (yaw movement) while it does this.

=head2 emergency

Toggles the emergency state.  If your UAV goes out of control, call this to immediately 
shut it off.  When in the emergency state, it will not be responsive to further commands.  
Call this again to bring it out of this state.

=head2 reset_watchdog

Sends a command to reset the watchdog process.  You need to send some command at least 
every 2 seconds, or else the AR.Drone thinks the connection was lost.  If you don't have 
anything else to send, send this one.

If you run C<start_event_loop()>, the reset will happen for you.

=head2 hover

Stops the UAV and hovers in place.

=head1 FLIGHT ANIMATION METHODS

The Parrot AR.Drone comes preprogrammed with a bunch of "flight animations" (complicated 
achrebatic manuevers).  You can call the methods below to run them.  Note that some of 
these need a generous amount of horizontal and vertical space, so be sure to be in a 
wide open area for testing.

I find "wave" and "flip_behind" are particularly good ways to impress house guests :)

    phi_m30_deg
    phi_30_deg
    theta_m30_deg
    theta_30_deg
    theta_20deg_yaw_200deg
    theta_20deg_yaw_m200deg
    turnaround
    turnaround_godown
    yaw_shake
    yaw_dance
    phi_dance
    theta_dance
    vz_dance
    wave
    phi_theta_mixed
    double_phi_theta_mixed
    flip_ahead
    flip_behind
    flip_left
    flip_right

=head1 LED ANIMATION METHODS

The LEDs on the Parrot AR.Drone can be directly controlled using these animation methods.  
They all take two parameters: the frequency (in Hz) as a floating point number, and 
the duration.

    led_blink_green_red
    led_blink_green
    led_blink_red
    led_blink_orange
    led_snake_green_red
    led_fire
    led_standard
    led_red
    led_green
    led_red_snake
    led_blank
    led_right_missile
    led_left_missile
    led_double_missile
    led_front_left_green_others_red
    led_front_right_green_others_red
    led_rear_right_green_others_red
    led_rear_left_green_others_red
    led_left_green_right_red
    led_left_red_right_green
    led_blink_standard

=cut
