use Test::More tests => 9;
use v5.14;

use_ok( 'UAV::Pilot' );
use_ok( 'UAV::Pilot::Exceptions' );
use_ok( 'UAV::Pilot::Driver' );
use_ok( 'UAV::Pilot::Driver::ARDrone' );
use_ok( 'UAV::Pilot::Driver::ARDrone::NavPacket' );
use_ok( 'UAV::Pilot::Driver::ARDrone::Mock' );
use_ok( 'UAV::Pilot::Control' );
use_ok( 'UAV::Pilot::Control::ARDrone' );
use_ok( 'UAV::Pilot::Commands' );
