package UAV::Pilot::ControlHelicopter;
use v5.14;
use Moose::Role;


with 'UAV::Pilot::Control';
requires 'takeoff';


1;
__END__

=head1 NAME

  UAV::Pilot::ControlHelicopter

=head1 DESCRIPTION

Role for any type of helicopter UAV.  This may include traditional monoprops, 
or more modern multipods.

Does the C<UAV::Pilot::Control> role.

Requires the method C<takeoff()>.

=cut
