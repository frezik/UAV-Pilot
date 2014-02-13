use Test::More tests => 14;
use v5.14;

use_ok( 'UAV::Pilot' );
use_ok( 'UAV::Pilot::Exceptions' );
use_ok( 'UAV::Pilot::Driver' );
use_ok( 'UAV::Pilot::Control' );
use_ok( 'UAV::Pilot::ControlHelicopter' );
use_ok( 'UAV::Pilot::ControlRover' );
use_ok( 'UAV::Pilot::Server' );
use_ok( 'UAV::Pilot::Commands' );
use_ok( 'UAV::Pilot::EasyEvent' );
use_ok( 'UAV::Pilot::EventHandler' );
use_ok( 'UAV::Pilot::Events' );
use_ok( 'UAV::Pilot::NavCollector' );
use_ok( 'UAV::Pilot::NavCollector::AckEvents' );
use_ok( 'UAV::Pilot::ControlRover' );
