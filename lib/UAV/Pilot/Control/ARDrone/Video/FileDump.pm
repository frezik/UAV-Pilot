package UAV::Pilot::Control::ARDrone::Video::FileDump;
use v5.14;
use Moose;
use namespace::autoclean;

with 'UAV::Pilot::Driver::ARDrone::VideoHandler';

has 'fh' => (
    is  => 'ro',
    isa => 'Item',
);


sub process_video_frame
{
    my ($self, $packet) = @_;
    my @payload = @{ $$packet{payload} };
    $self->fh->print( pack( 'C*', @payload ) );
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

