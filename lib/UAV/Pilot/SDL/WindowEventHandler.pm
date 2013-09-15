package UAV::Pilot::SDL::WindowEventHandler;
use v5.14;
use Moose::Role;

requires 'draw';
requires 'width';
requires 'height';

1;
__END__


=head1 NAME

  UAV::Pilot::SDL::WindowEventHandler

=head1 DESCRIPTION

Role for objects that will be passed into C<UAV::Pilot::SDL::Window> as 
children.

Requires the method C<draw>, which will be called on the object to draw 
itself.  It will be passed the C<UAV::Pilot::SDL::Window> object.

Also requires C<width> and C<height> methods.

=cut
