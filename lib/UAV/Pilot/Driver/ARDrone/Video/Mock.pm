package UAV::Pilot::Driver::ARDrone::Video::Mock;
use v5.14;
use Moose;
use namespace::autoclean;

extends 'UAV::Pilot::Driver::ARDrone::Video';


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

