package UAV::Pilot::Video::RawHandler;
use v5.14;
use Moose::Role;

requires 'process_raw_frame';

1;
__END__


=head1 NAME

  UAV::Pilot::Video::RawHandler

=head1 DESCRIPTION


A Moose role for processing raw video frames.  There is one required method, 
C<process_raw_frame>.  It will be passed:

=over 4

=item * $width

=item * $height

=item * $decoder

=back

The C<$decoder> object is a C<UAV::Pilot::Video::H264Decoder>, which will have processed the 
most recent frame data.

=cut
