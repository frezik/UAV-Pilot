package UAV::Pilot::SDL::JoystickConverter;
use v5.14;
use Moose::Role;


use constant MAX_AXIS_INT => 32768;
use constant MIN_AXIS_INT => -32787;

requires 'convert_sdl_input';


1;
__END__

