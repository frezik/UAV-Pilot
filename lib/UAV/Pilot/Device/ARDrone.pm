package UAV::Pilot::Device::ARDrone;
use v5.14;
use Moose;
use namespace::autoclean;

extends 'UAV::Pilot::Device';


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

sub phi_m30
{
    my ($self) = @_;
    $self->sender->at_config(
        $self->sender->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM,
        sprintf( '%d,%d',
            $self->sender->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_M30_DEG,
            $self->sender->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_PHI_M30_DEG_MAYDAY,
        ),
    );
}

sub flip_left
{
    my ($self) = @_;
    $self->sender->at_config(
        $self->sender->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM,
        sprintf( '%d,%d',
            $self->sender->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_LEFT,
            $self->sender->ARDRONE_CONFIG_CONTROL_FLIGHT_ANIM_FLIP_LEFT_MAYDAY,
        ),
    );
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

