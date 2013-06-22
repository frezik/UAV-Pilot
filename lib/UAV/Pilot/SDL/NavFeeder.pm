package UAV::Pilot::SDL::NavFeeder;
use v5.14;
use Moose::Role;


requires 'cur_pitch';
requires 'cur_roll';
requires 'cur_yaw';
requires 'cur_vert_speed';


1;
__END__
