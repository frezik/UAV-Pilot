package UAV::Pilot::ControlRover;
use v5.14;
use Moose::Role;


with 'UAV::Pilot::Control';
requires 'throttle';
requires 'turn';


1;
__END__

