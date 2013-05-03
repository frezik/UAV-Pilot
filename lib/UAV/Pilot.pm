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
