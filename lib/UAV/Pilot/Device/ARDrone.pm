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


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

