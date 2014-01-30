package UAV::Pilot::WumpusRover::Video::Mock;
use v5.14;
use warnings;
use Moose;
use namespace::autoclean;
use UAV::Pilot::WumpusRover::Video;

extends 'UAV::Pilot::WumpusRover::Video';

has 'file' => (
    is  => 'ro',
    isa => 'Str',
);


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

