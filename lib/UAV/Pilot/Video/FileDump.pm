package UAV::Pilot::Video::FileDump;
use v5.14;
use Moose;
use namespace::autoclean;

with 'UAV::Pilot::Video::H264Handler';

has 'fh' => (
    is  => 'ro',
    isa => 'Item',
);


sub process_h264_frame
{
    my ($self, $packet) = @_;
    my $fh = $self->fh;
    print $fh pack( 'C*', @$packet );
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME

  UAV::Pilot::Video::FileDump

=head1 SYNOPSIS

    open( my $vid_out, '>', 'video.h264' ) or die $!;
    my $file_dump = UAV::Pilot::Video::FileDump->new({
        fh => $vid_out,
    });
    my $video = UAV::Pilot::Driver::ARDrone::Video->new({
        handler => $file_dump,
        ...
    });

=head1 DESCRIPTION

Writes the h264 video frames to a file.  Afterwords, you should be able to play this file 
with mplayer or other video players that support h264 without being inside a container 
format.

=cut
