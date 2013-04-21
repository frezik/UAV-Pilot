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


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

