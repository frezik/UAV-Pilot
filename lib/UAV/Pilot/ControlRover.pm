package UAV::Pilot::ControlRover;
use v5.14;
use Moose::Role;


with 'UAV::Pilot::Control';
requires 'throttle';
requires 'turn';


1;
__END__


=head1 NAME

  UAV::Pilot::ControlRover

=head1 DESCRIPTION

Role for any kind of ground vehicle.

Does the C<UAV::Pilot::Control> role.

Requires the methods C<throttle( $throttle )> and C<turn( $turn )>.

=cut
