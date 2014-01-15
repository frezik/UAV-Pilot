package UAV::Pilot::WumpusRover;
use v5.14;
use warnings;
use Moose;
use namespace::autoclean;

use constant DEFAULT_PORT       => 49_000;
use constant DEFAULT_VIDEO_PORT => 49_001;


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

  UAV::Pilot::WumpusRover

=head1 DESCRIPTION

The WumpusRover was a project started specifically around C<UAV::Pilot>.  The 
library was always intended to be used on more than just the Parrot AR.Drone.  
With this addition, it is not only supporting a custom rover project, but also 
running much of the code on the rover itself.

The protocol is similar to ArduPilot protocol, taken from here:

L<http://code.google.com/p/ardupilot-mega/wiki/Protocol>

No tests were done against an existing ArduPilot implementation, so things may 
not be 100% compatible.  It should be close, however.  It is a goal to eventually
be compatible; this will happen Soon(tm).

=cut
