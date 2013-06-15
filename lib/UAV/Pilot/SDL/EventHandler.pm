package UAV::Pilot::SDL::EventHandler;
use v5.14;
use Moose::Role;

requires 'process_events';

1;
__END__


=head1 NAME

  UAV::Pilot::SDL::EventHandler

=head1 DESCRIPTION

Role for objects that will be passed into C<UAV::Pilot::SDL::Events>.

Requires the method C<process_events>, which will be called to handle the events for this 
object.

=cut
