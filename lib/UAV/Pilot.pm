package UAV::Pilot;
use v5.14;
use Moose;
use namespace::autoclean;
use File::Spec;

use constant MODULE_NAMESPACE => 'Modules';


sub default_module_dir
{
    my ($class) = @_;
    my $pack = __PACKAGE__;
    $pack =~ s/::/\//g;
    $pack .= '.pm';

    my $pack_path = $INC{$pack};
    $pack_path =~ s/\.pm\z//;

    my $module_path = File::Spec->catfile( $pack_path, $class->MODULE_NAMESPACE );
    return $module_path;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

  UAV::Pilot

=head1 SYNOPSIS

  use UAV::Pilot::Sender::ARDrone;
  use UAV::Pilot::Device::ARDrone;
  
  my $ardrone = UAV::Pilot::Sender::ARDrone->new({
      host => '192.168.1.1',
  });
  $ardrone->connect;
  
  my $dev = UAV::Pilot::Device::ARDrone->new({
      sender => $ardrone,
  });
  
  
  $dev->takeoff;
  $dev->pitch( 0.5 );
  $dev->flip_left;
  $dev->land;


=head1 DESCRIPTION

Library for controlling Unmanned Arieal Drones.


=head1 FIRST FLIGHT OF AR.DRONE

=head2 Initial Setup

Connect the battery and put on the indoor or outdoor hull (as needed).

By default, the AR.Drone starts as its own wireless access point.  Configure your wireless 
network to connect to it.

=head2 The Shell

The C<uav> program connects to the UAV and prompts for commands.  Simply start it and 
wait for the C<<uav>>> prompt.  You can exit by typing C<exit;>, C<quit;>, or C<q;>.

The shell takes Perl statements ending with 'C<;>'.  Only a basic shell is loaded by 
default.  You must first load the AR.Drone libraries into the system, which you can do with:

    load 'ARDrone';

The ARDrone module will now be loaded.  You can now tell it to takeoff, wave, flip, and land.

    takeoff;
    wave;
    flip_left;
    land;

If your drone suddenly stops, has all red lights, and won't takeoff again, then it went into 
emergency mode.  You get it out of this mode with the command:

    emergency;

Which also works to toggle emergency mode back on if your UAV goes out of control.

If needed, you can force emergency mode by grabbing the UAV in midair (one hand on top, one 
on the bottom) and flipping it over.

For simple piloting, the commands C<roll/pitch/yaw> can be used.  Each of these takes a 
single parameter of a floating point nubmer between -1.0 and 1.0:

    roll -0.5;
    pitch 1.0;
    yaw 0.25;

As you can see, sending a single command only causes the manuever for a brief moment 
before stopping.  Commands must be continuously sent in order to have smooth flight.

TODO Write how to send commands continuously once we figure out how

=end
