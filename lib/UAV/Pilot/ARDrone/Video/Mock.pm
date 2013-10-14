package UAV::Pilot::ARDrone::Video::Mock;
use v5.14;
use Moose;
use namespace::autoclean;

extends 'UAV::Pilot::ARDrone::Video';

has 'emergency_count' => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);



sub emergency_restart
{
    my ($self) = @_;
    $self->emergency_count( $self->emergency_count + 1 );
    return 1;
}


sub _build_io
{
    my ($class, $args) = @_;
    my $file = $$args{file};
    open( my $fh, '<', $file ) 
        or UAV::Pilot::IOException->throw(
            error => "Could not open file '$file': $!",
        );
    return $fh;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

