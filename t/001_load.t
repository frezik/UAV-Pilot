use Test::More tests => 10;
use v5.14;

use_ok( 'UAV::Pilot' );
use_ok( 'UAV::Pilot::Exceptions' );
use_ok( 'UAV::Pilot::Sender' );
use_ok( 'UAV::Pilot::Sender::ARDrone::NavPacket' );
use_ok( 'UAV::Pilot::Sender::ARDrone::NavPacket::Option' );
use_ok( 'UAV::Pilot::Sender::ARDrone' );
use_ok( 'UAV::Pilot::Sender::ARDrone::Mock' );
use_ok( 'UAV::Pilot::Device' );
use_ok( 'UAV::Pilot::Device::ARDrone' );
use_ok( 'UAV::Pilot::Commands' );
