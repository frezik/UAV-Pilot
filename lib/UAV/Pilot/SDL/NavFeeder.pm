package UAV::Pilot::SDL::NavFeeder;
use v5.14;
use Moose::Role;


requires 'cur_pitch';
requires 'cur_roll';
requires 'cur_yaw';
requires 'cur_vert_speed';


1;
__END__


=head1 NAME

  UAV::Pilot::SDL::NavFeeder

=head1 DESCRIPTION

Role for objects that can provide data to navigation displays, such as 
C<UAV::Pilot::Control::SDLNavOutput>.

=head1 METHODS

=head2 cur_pitch

=head2 cur_roll

=head2 cur_yaw

=head2 cur_vert_speed

=cut
