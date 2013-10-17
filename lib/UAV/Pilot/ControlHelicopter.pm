package UAV::Pilot::ControlHelicopter;
use v5.14;
use Moose::Role;


with 'UAV::Pilot::Control';
requires 'takeoff';


1;
__END__

