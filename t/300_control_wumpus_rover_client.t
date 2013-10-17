use Test::More tests => 5;
use v5.14;
use UAV::Pilot::WumpusRoverClient::Driver::Mock;
use Test::Moose;

my $wumpus = UAV::Pilot::WumpusRoverClient::Driver::Mock->new({
    host => 'localhost',
    port => 49005,
});
ok( $wumpus, "Created object" );
isa_ok( $wumpus => 'UAV::Pilot::WumpusRoverClient' );
does_ok( $wumpus => 'UAV::Pilot::Driver' );
cmp_ok( $wumpus->port, '==', 49005, "Port set" );

ok( $wumpus->connect, "Connect to WumpusRover" );
