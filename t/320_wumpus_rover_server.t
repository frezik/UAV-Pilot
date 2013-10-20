use Test::More tests => 6;
use strict;
use warnings;
use UAV::Pilot::WumpusRover::PacketFactory;
use UAV::Pilot::WumpusRover::Server::Mock;
use UAV::Pilot::WumpusRover::Server::Backend::Mock;
use Test::Moose;


my $backend = UAV::Pilot::WumpusRover::Server::Backend::Mock->new;
my $server = UAV::Pilot::WumpusRover::Server::Mock->new({
    listen_port => 65534,
    backend     => $backend,
});
isa_ok( $server => 'UAV::Pilot::WumpusRover::Server' );
does_ok( $server => 'UAV::Pilot::Server' );


my $startup_request = UAV::Pilot::WumpusRover::PacketFactory->fresh_packet(
    'RequestStartupMessage' );
$startup_request->system_type( 1 );
$startup_request->system_id( 2 );
$startup_request->make_checksum_clean;
$server->process_packet( $startup_request );

my $ack_packet = $server->last_packet_out;
isa_ok( $ack_packet => 'UAV::Pilot::WumpusRover::Packet::Ack' );
cmp_ok( $ack_packet->message_received_id, '==', $startup_request->message_id,
    "Message ID received set on ACK packet" );
cmp_ok( $ack_packet->checksum_received1, '==', $startup_request->checksum1,
    "Checksum1 received set on ACK packet" );
cmp_ok( $ack_packet->checksum_received2, '==', $startup_request->checksum2,
    "Checksum2 received set on ACK packet" );
