package UAV::Pilot;
use v5.14;
use Moose;
use namespace::autoclean;
use File::Spec;
use File::ShareDir;
use File::HomeDir;
use Log::Log4perl;

use constant DIST_NAME     => 'UAV-Pilot';
use constant LOG_CONF_FILE => 'log4perl.conf';

our $VERSION       = '0.9';
our $LOG_WAS_INITD = 0;


sub default_module_dir
{
    my ($class) = @_;
    my $dir = File::ShareDir::dist_dir( $class->DIST_NAME );
    return $dir;
}

sub default_config_dir
{
    my ($class) = @_;
    my $dir = File::HomeDir->my_dist_config( $class->DIST_NAME, {
        create => 1,
    });
    return $dir,
}

sub init_log
{
    my ($class) = @_;
    return if $LOG_WAS_INITD;
    my $conf_dir = $class->default_config_dir;
    my $log_conf = File::Spec->catfile( $conf_dir, $class->LOG_CONF_FILE );

    $class->_make_default_log_conf( $log_conf ) if ! -e $log_conf;

    Log::Log4perl::init( $log_conf );
    return 1;
}

sub checksum_fletcher8
{
    my ($class, @bytes) = @_;
    my $ck_a = 0;
    my $ck_b = 0;

    foreach (@bytes) {
        $ck_a = ($ck_a + $_)    & 0xFF;
        $ck_b = ($ck_b + $ck_a) & 0xFF;
    }

    return ($ck_a, $ck_b);
}

sub convert_32bit_LE
{
    my ($class, @bytes) = @_;
    my $val = $bytes[0]
        | ($bytes[1] << 8)
        | ($bytes[2] << 16)
        | ($bytes[3] << 24);
    return $val;
}

sub convert_16bit_LE
{
    my ($class, @bytes) = @_;
    my $val = $bytes[0] | ($bytes[1] << 8);
    return $val;
}

sub convert_32bit_BE
{
    my ($class, @bytes) = @_;
    my $val = ($bytes[0] << 24)
        | ($bytes[1] << 16)
        | ($bytes[2] << 8)
        | $bytes[3];
    return $val;
}

sub convert_16bit_BE
{
    my ($class, @bytes) = @_;
    my $val = ($bytes[0] << 8) | $bytes[1];
    return $val;
}

sub _make_default_log_conf
{
    my ($class, $out_file) = @_;

    open( my $out, '>', $out_file )
        or die "Can't open [$out_file] for writing: $!\n";

    print $out "log4j.rootLogger=WARN, A1\n";
    print $out "log4j.appender.A1=Log::Log4perl::Appender::Screen\n";
    print $out "log4j.appender.A1.layout=org.apache.log4j.PatternLayout\n";
    print $out "log4j.appender.A1.layout.ConversionPattern="
        . '%-4r [%t] %-5p %c %t - %m%n' . "\n";

    close $out;
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

  UAV::Pilot

=head1 SYNOPSIS

  use UAV::Pilot::ARDrone::Driver;
  use UAV::Pilot::ARDrone::Control;
  
  my $ardrone = UAV::Pilot::ARDrone::Driver->new({
      host => '192.168.1.1',
  });
  $ardrone->connect;
  
  my $dev = UAV::Pilot::ARDrone::Control->new({
      sender => $ardrone,
  });
  
  
  $dev->takeoff;
  $dev->pitch( 0.5 );
  $dev->flip_left;
  $dev->land;


=head1 DESCRIPTION

Library for controlling Unmanned Aerial Drones.


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

=head1 OTHER LINKS

L<http://www.wumpus-cave.net> - Developer's blog
L<http://projects.ardrone.org> - AR.Drone Open API
L<http://ardrone2.parrot.com> - AR.Drone Homepage

=head1 LICENSE

Copyright (c) 2013,  Timm Murray
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are 
permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of 
      conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of
      conditions and the following disclaimer in the documentation and/or other materials 
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS 
OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut
