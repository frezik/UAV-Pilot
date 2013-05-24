package UAV::Pilot::Control;
use v5.14;
use Moose::Role;

has 'sender' => (
    is   => 'ro',
    does => 'UAV::Pilot::Driver',
);


1;
__END__


=head1 NAME

  UAV::Pilot::Control

=head1 DESCRIPTION

Role for high-level interfaces to drones.  External programs should usually write against a 
module that does this role.

=head1 ATTRIBUTES

=head2 sender

Instantiated C<UAV::Pilot::Driver> object.

=cut
