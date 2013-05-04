package UAV::Pilot::Sender::ARDrone;
use v5.14;
use Moose;
use namespace::autoclean;
use IO::Socket;

use UAV::Pilot::Exceptions;

use constant {
    ARDRONE_CALIBRATION_DEVICE_MAGNETOMETER => 0,
    ARDRONE_CALIBRATION_DEVICE_NUMBER       => 1,

    ARDRONE_CTRL_GET_CONFIG => 4,

    ARDRONE_PORT_COMMAND            => 5556,
    ARDRONE_PORT_COMMAND_TYPE       => 'udp',
    ARDRONE_PORT_NAV_DATA           => 5554,
    ARDRONE_PORT_NAV_DATA_TYPE      => 'udp',
    ARDRONE_PORT_VIDEO_P264_V1      => 5555,
    ARDRONE_PORT_VIDEO_P264_V2      => 5555,
    ARDRONE_PORT_VIDEO_P264_V1_TYPE => 'udp',
    ARDRONE_PORT_VIDEO_P264_V2_TYPE => 'tcp',
    ARDRONE_PORT_VIDEO_H264         => 5553,
    ARDRONE_PORT_VIDEO_H264_TYPE    => 'tcp',
    ARDRONE_PORT_CTRL               => 5559,
    ARDRONE_PORT_CTRL_TYPE          => 'tcp',

    ARDRONE_CONFIG_GENERAL_NAVDATA_DEMO                        => 'general:navdata_demo',

    ARDRONE_CONFIG_NETWORK_SSID_SINGLE_PLAYER => 'network:ssid_single_player',
    ARDRONE_CONFIG_NETWORK_WIFI_MODE          => 'network:wifi_mode',
    ARDRONE_CONFIG_NETWORK_WIFI_MODE_AP       => 0,
    ARDRONE_CONFIG_NETWORK_WIFI_MODE_JOIN     => 1,
    ARDRONE_CONFIG_NETWORK_WIFI_MODE_STATION  => 2,
    ARDRONE_CONFIG_NETWORK_OWNER_MAC          => 'network:owner_mac',

    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM                         => 'control:flight_anim',
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_M30_DEG             => 0,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_30_DEG              => 1,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_M30_DEG           => 2,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_30_DEG            => 3,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_20DEG_YAW_200DEG  => 4,,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_20DEG_YAW_M200DEG => 5,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_TURNAROUND              => 6,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_TURNAROUND_GODOWN       => 7,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_YAW_SHAKE               => 8,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_YAW_DANCE               => 9,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_DANCE               => 10,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_DANCE             => 11,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_VZ_DANCE                => 12,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_WAVE                    => 13,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_THETA_MIXED         => 14,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_DOUBLE_PHI_THETA_MIXED  => 15,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_AHEAD              => 16,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_BEHIND             => 17,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_LEFT               => 18,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_RIGHT              => 19,

    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_M30_DEG_MAYDAY             => 1000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_30_DEG_MAYDAY              => 1000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_M30_DEG_MAYDAY           => 1000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_30_DEG_MAYDAY            => 1000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_20DEG_YAW_200DEG_MAYDAY  => 1000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_20DEG_YAW_M200DEG_MAYDAY => 1000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_TURNAROUND_MAYDAY              => 5000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_TURNAROUND_GODOWN_MAYDAY       => 5000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_YAW_SHAKE_MAYDAY               => 2000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_YAW_DANCE_MAYDAY               => 5000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_DANCE_MAYDAY               => 5000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_THETA_DANCE_MAYDAY             => 5000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_VZ_DANCE_MAYDAY                => 5000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_WAVE_MAYDAY                    => 5000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_THETA_MIXED_MAYDAY         => 5000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_DOUBLE_PHI_THETA_MIXED_MAYDAY  => 5000,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_AHEAD_MAYDAY              => 15,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_BEHIND_MAYDAY             => 15,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_LEFT_MAYDAY               => 15,
    ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_RIGHT_MAYDAY              => 15,
};



extends 'UAV::Pilot::Sender';

has 'port' => (
    is      => 'rw',
    isa     => 'Int',
    default => 5556,
);

has 'host' => (
    is  => 'rw',
    isa => 'Str',
);

has 'seq' => (
    is      => 'ro',
    isa     => 'Int',
    default => 0,
    writer  => '__set_seq',
);

has '_socket' => (
    is => 'rw',
);


sub connect
{
    my ($self) = @_;
    my $socket = IO::Socket::INET->new(
        Proto    => 'udp',
        PeerPort => $self->port,
        PeerAddr => $self->host,
    ) or UAV::Pilot::IOException->throw(
        error => 'Could not open socket: ' . $!,
    );
    $self->_socket( $socket );

    $self->_init_drone;
    return 1;
}

sub at_ref
{
    my ($self, $takeoff, $emergency) = @_;

    # According to the ARDrone developer docs, bits 18, 20, 22, 24, and 28 should be 
    # init'd to one, and all others to zero.  Bit 9 is takeoff, 8 is emergency shutoff.
    my $cmd_number = (1 << 18) 
        | (1 << 20)
        | (1 << 22)
        | (1 << 24)
        | (1 << 28)
        | ($takeoff << 9)
        | ($emergency << 8);

    my $cmd = 'AT*REF=' . $self->_next_seq . ',' . $cmd_number . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}

sub at_pcmd
{
    my ($self, $do_progressive, $do_combined_yaw,
        $roll, $pitch, $vert_speed, $yaw) = @_;

    if( ($roll > 1) || ($roll < -1) ) {
        UAV::Pilot::NumberOutOfRangeException->throw(
            error => 'Roll should be between 1.0 and -1.0',
        );
    }
    if( ($pitch > 1) || ($pitch < -1) ) {
        UAV::Pilot::NumberOutOfRangeException->throw(
            error => 'Pitch should be between 1.0 and -1.0',
        );       
    }
    if( ($vert_speed > 1) || ($vert_speed < -1) ) {
        UAV::Pilot::NumberOutOfRangeException->throw(
            error => 'Vertical speed should be between 1.0 and -1.0',
        );       
    }
    if( ($yaw > 1) || ($yaw < -1) ) {
        UAV::Pilot::NumberOutOfRangeException->throw(
            error => 'Yaw should be between 1.0 and -1.0',
        );       
    }

    # According to docs *always* set Progressive bit to 1, or else drone enters 
    # hover mode.  Set Absolute bit to 1 for absolute control.
    my $cmd_number = (1 << 0)
        | ($do_combined_yaw << 1)
        | (!$do_progressive << 2);

    my $cmd = 'AT*PCMD='
        . join( ',', 
            $self->_next_seq,
            $cmd_number,
            $self->_float_convert( $roll ),
            $self->_float_convert( $pitch ),
            $self->_float_convert( $vert_speed ),
            $self->_float_convert( $yaw ),
        )
        . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}

sub at_pcmd_mag
{
    my ($self, $do_progressive, $do_combined_yaw,
        $roll, $pitch, $vert_speed, $angular_speed,
        $magneto, $magneto_accuracy) = @_;

    if( ($roll >= 1) || ($roll <= -1) ) {
        UAV::Pilot::NumberOutOfRangeException->throw(
            error => 'Roll should be between 1.0 and -1.0',
        );
    }
    if( ($pitch >= 1) || ($pitch <= -1) ) {
        UAV::Pilot::NumberOutOfRangeException->throw(
            error => 'Pitch should be between 1.0 and -1.0',
        );       
    }
    if( ($vert_speed >= 1) || ($vert_speed <= -1) ) {
        UAV::Pilot::NumberOutOfRangeException->throw(
            error => 'Vertical speed should be between 1.0 and -1.0',
        );       
    }
    if( ($angular_speed >= 1) || ($angular_speed <= -1) ) {
        UAV::Pilot::NumberOutOfRangeException->throw(
            error => 'Angular speed should be between 1.0 and -1.0',
        );       
    }
    if( ($magneto >= 1) || ($magneto <= -1) ) {
        UAV::Pilot::NumberOutOfRangeException->throw(
            error => 'Magneto should be between 1.0 and -1.0',
        );       
    }
    if( ($magneto_accuracy >= 1) || ($magneto_accuracy <= -1) ) {
        UAV::Pilot::NumberOutOfRangeException->throw(
            error => 'Magneto accuracy should be between 1.0 and -1.0',
        );       
    }

    my $cmd_number = ($do_progressive << 0)
        | ($do_combined_yaw << 1);

    my $cmd = 'AT*PCMD_MAG='
        . join( ',', 
            $self->_next_seq,
            $cmd_number,
            $self->_float_convert( $roll ),
            $self->_float_convert( $pitch ),
            $self->_float_convert( $vert_speed ),
            $self->_float_convert( $angular_speed ),
            $self->_float_convert( $magneto  ),
            $self->_float_convert( $magneto_accuracy ),
        )
        . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}

sub at_ftrim
{
    my ($self) = @_;

    my $cmd = 'AT*FTRIM=' . $self->_next_seq . ",\r";
    $self->_send_cmd( $cmd );

    return 1;
}

sub at_calib
{
    my ($self, $device) = @_;

    my $cmd = 'AT*CALIB=' . $self->_next_seq . ",$device" . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}

sub at_config
{
    my ($self, $name, $value) = @_;

    my $cmd = 'AT*CONFIG=' . $self->_next_seq
        . ',' . qq{"$name"}
        . ',' . qq{"$value"}
        . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}

sub at_config_ids
{
    my ($self, $session_id, $user_id, $app_id) = @_;

    my $cmd = 'AT*CONFIG_IDS=' . $self->_next_seq . ','
        . join( ',',
            $session_id,
            $user_id,
            $app_id,
        )
        . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}

sub at_comwdg
{
    my ($self) = @_;

    my $cmd = 'AT*COMWDG=' . $self->_next_seq . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}

sub at_ctrl
{
    my ($self, $val) = @_;

    my $cmd = 'AT*CTRL=' . $self->_next_seq . ",$val" . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}


sub _send_cmd
{
    my ($self, $cmd) = @_;
    $self->_socket->send( $cmd );
    return 1;
}

sub _next_seq
{
    my ($self) = @_;
    my $next_seq = $self->seq + 1;
    $self->__set_seq( $next_seq );
    return $next_seq;
}

sub _init_drone
{
    my ($self) = @_;
    $self->at_ftrim;
    return 1;
}

# Takes an IEEE-754 float and converts its exact bits in memory to a signed 32-bit integer.
# Yes, the ARDrone dev docs actually say to put floats across the wire in this format.
sub _float_convert
{
    my ($self, $float) = @_;
    my $int = unpack( "l", pack( "f", $float ) );
    return $int;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

