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


sub _make_gstreamer_connection_cmd
{
    my ($class, $args) = @_;
    my $file = $args->{file};
    my @cmd = (
        'filesrc',
        'location=' . $file,
    );
    return @cmd;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

