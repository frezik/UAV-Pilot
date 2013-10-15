package UAV::Pilot::NavCollector;
use v5.14;
use Moose::Role;

requires 'got_new_nav_packet';

1;
__END__


=head1 NAME

  UAV::Pilot::NavCollector

=head1 DESCRIPTION

Role for objects that will process navigation packets.  Requires the 
C<got_new_nav_packet( $packet )> method, which will take a
C<UAV::Pilot::ARDrone::NavPacket>.

=cut
