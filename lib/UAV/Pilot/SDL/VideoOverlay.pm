package UAV::Pilot::SDL::VideoOverlay;
use v5.14;
use Moose::Role;

requires 'process_video_overlay';

has 'video_overlay' => (
    is     => 'ro',
    isa    => 'Maybe[UAV::Pilot::SDL::Video]',
    writer => '_set_video_overlay',
);


sub init_video_overlay
{
    my ($self, $video) = @_;
    $self->_set_video_overlay( $video );
    return 1;
}


1;
__END__

