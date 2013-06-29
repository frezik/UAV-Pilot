package UAV::Pilot::Driver::ARDrone::VideoHandler;
use v5.14;
use Moose::Role;

requires 'process_video_frame';

1;
__END__


=head1 NAME

  UAV::Pilot::Driver::ARDrone::VideoHandler

=head1 DESCRIPTION

Objects which do this role can be passed to C<UAV::Pilot::Driver::ARDrone::Video>.  They 
will handle a video frame-by-frame.

=head1 REQUIRED METHODS

=head1 process_video_frame

Will be passed an arrayref containing the bytes of the h264 frame.

=cut
