package UAV::Pilot::Video::H264Handler;
use v5.14;
use Moose::Role;

requires 'process_h264_frame';

1;
__END__


=head1 NAME

  UAV::Pilot::Video::H264Handler

=head1 DESCRIPTION

Objects which do this role can be passed to objects that handle video frames, such as 
C<UAV::Pilot::Driver::ARDrone::Video>.  They will handle an h264 video frame-by-frame.

=head1 REQUIRED METHODS

=head1 process_h264_frame

    process_h264_frame(
        $frame, # Arrayref of bytes containing the h264 frame
        $width,
        $height,
        $encoded_width,
        $encoded_height,
    );

=cut
