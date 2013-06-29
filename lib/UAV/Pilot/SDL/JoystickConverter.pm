package UAV::Pilot::SDL::JoystickConverter;
use v5.14;
use Moose::Role;


use constant MAX_AXIS_INT => 32768;
use constant MIN_AXIS_INT => -32787;

requires 'convert_sdl_input';


1;
__END__


=head1 NAME

  UAV::Pilot::SDL::JoystickConverter

=head1 DESCRIPTION

Role for objects that would take axis data from the SDL joystick input and convert it into 
the numbers needed for their specific driver.

=head1 CONSTANTS

=head2 MAX_AXIS_INT

=head2 MIN_AXIS_INT

=head1 REQUIRED METHODS

=head2 convert_sdl_input

Will be passed an SDL joystick value between C<MAX_AXIS_INT> and C<MIN_AXIS_INT>.  Should 
return an equivilent value for your UAV.

=cut
