use Test::More tests => 4;
use v5.14;
use UAV::Pilot;
use UAV::Pilot::Sender;
use UAV::Pilot::Sender::ARDrone;
use UAV::Pilot::Sender::ARDrone::Mock;

my $ardrone_mock = UAV::Pilot::Sender::ARDrone::Mock->new({
    port => 7776,
});
ok( $ardrone_mock, "Created object" );
isa_ok( $ardrone_mock => 'UAV::Pilot::Sender::ARDrone::Mock' );
cmp_ok( $ardrone_mock->port, '==', 7776, "Port set" );


my $seq = 1;
$ardrone_mock->at_ref( 1, 0 );
my $str = $ardrone_mock->last_cmd;
cmp_ok( $str, 'eq', "AT*REF=$seq,290718208\r", "Takeoff command" );
$seq++;
