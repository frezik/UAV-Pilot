use Test::More tests => 16;
use v5.14;

my $is_sdl_installed = do {
    eval "use SDL ()";
    $@ ? 0 : 1;
};

use_ok( 'UAV::Pilot' );
use_ok( 'UAV::Pilot::Exceptions' );
use_ok( 'UAV::Pilot::Driver' );
use_ok( 'UAV::Pilot::Driver::ARDrone' );
use_ok( 'UAV::Pilot::Driver::ARDrone::NavPacket' );
use_ok( 'UAV::Pilot::Driver::ARDrone::Mock' );
use_ok( 'UAV::Pilot::Control' );
use_ok( 'UAV::Pilot::Control::ARDrone' );
use_ok( 'UAV::Pilot::Control::ARDrone::Event' );
use_ok( 'UAV::Pilot::Control::ARDrone::SDLNavOutput' );
use_ok( 'UAV::Pilot::Commands' );
use_ok( 'UAV::Pilot::EasyEvent' );

SKIP: {
    skip "SDL not installed", 2 unless $is_sdl_installed;
    use_ok( 'UAV::Pilot::Control::ARDrone::SDLNavOutput' );
    use_ok( 'UAV::Pilot::SDL::EventHandler' );
    use_ok( 'UAV::Pilot::SDL::Joystick' );
    use_ok( 'UAV::Pilot::SDL::Events' );
}
