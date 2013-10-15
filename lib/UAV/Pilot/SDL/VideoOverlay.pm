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


=head1 NAME

  UAV::Pilot::SDL::VideoOverlay

=head1 DESCRIPTION

A role for objects to draw on top of a video.  Requires a
C<process_video_overlay()> method, which will be passed the C<UAV::Pilot::SDL::Window> object that the video is drawing to.

Where C<$video> is an C<UAV::Pilot::SDL::Video> object, you can set an 
C<$overlay> object with:

    $video->register_video_overlay( $overlay );

B<NOTE>: This is still experimental.  Lines tend to flicker and show up as 
black.  This is probably due to the SDL YUV hardware overlay.

=cut
