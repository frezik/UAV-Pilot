package UAV::Pilot::Device;
use v5.14;
use Moose::Role;

has 'sender' => (
    is  => 'ro',
    isa => 'UAV::Pilot::Sender',
);


1;
__END__


=head1 NAME

  UAV::Pilot::Device

=head1 DESCRIPTION

Role for high-level interfaces to drones.  External programs should usually write against a 
module that does this role.

=head1 ATTRIBUTES

=head2 sender

Instantiated C<UAV::Pilot::Sender> object.

=cut
