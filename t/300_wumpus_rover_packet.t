use Test::More tests => 21;
use strict;
use warnings;
use UAV::Pilot::WumpusRover::PacketFactory;
use UAV::Pilot::WumpusRover::Packet;
use UAV::Pilot::Exceptions;


my $bad_header = make_packet( '3445', '03', '00', '00', '010000', '030C' );
eval {
    local $SIG{__WARN__} = sub {}; # Temporarily suppress warnings
    UAV::Pilot::WumpusRover::PacketFactory->read_packet( $bad_header );
};
if( $@ && $@->isa( 'UAV::Pilot::ArdupilotPacketException::BadHeader' ) ) {
    pass( 'Caught Bad Header exception' );
    cmp_ok( $@->got_header, '==', 0x3445, "BadHeader exception has got_header value" );
}
else {
    fail( 'Did not catch Bad Header exception' );
    fail( 'Fail matching magic number, too [placeholder failure for test count]' );
}

my $bad_checksum = make_packet(
    '3444',   # Preamble
    '03',     # Payload len *
    '00',     # Message ID *
    '00',     # Message Version *
    '010000', # Payload *
    '030D',   # Checksum (starred fields above are fed into checksum)
);
eval {
    local $SIG{__WARN__} = sub {}; # Temporarily suppress warnings
    UAV::Pilot::WumpusRover::PacketFactory->read_packet( $bad_checksum );
};
if( $@ && $@->isa( 'UAV::Pilot::ArdupilotPacketException::BadChecksum' ) ) {
    pass( 'Caught Bad Checksum exception' );
    cmp_ok( $@->got_checksum1, '==', 0x03, "BadChecksum exception has got_checksum1 value" );
    cmp_ok( $@->got_checksum2, '==', 0x0D, "BadChecksum exception has got_checksum2 value" );
    cmp_ok( $@->expected_checksum1, '==', 0x04, "BadChecksum exception has expected_checksum1 value" );
    cmp_ok( $@->expected_checksum2, '==', 0x15, "BadChecksum exception has expected_checksum2 value" );
}
else {
    fail( 'Did not catch Bad Header exception' );
    fail( 'Fail got checksum1, too [placeholder failure for test count]' );
    fail( 'Fail got checksum2, too [placeholder failure for test count]' );
    fail( 'Fail expected checksum1, too [placeholder failure for test count]' );
    fail( 'Fail expected checksum2, too [placeholder failure for test count]' );
}


my $good_packet = make_packet( '3444', '03', '00', '00', '010000', '030C' );
my $packet = UAV::Pilot::WumpusRover::PacketFactory->read_packet( $good_packet );
does_ok( $packet => 'UAV::Pilot::WumpusRover::Packet' );
isa_ok( $packet => 'UAV::Pilot::WumpusRover::Packet::Ack' );
cmp_ok( $packet->preamble,        '==', 0x3344, "Preamble set" );
cmp_ok( $packet->payload_length,  '==', 0x03,   "Payload length set" );
cmp_ok( $packet->message_id,      '==', 0x01,   "Message ID set" );
cmp_ok( $packet->version,         '==', 0x00,   "Version set" );
cmp_ok( $packet->message_id_recv, '==', 0x01,   "Message ID received" );
cmp_ok( $packet->checksum,        '==', 0x040D, "Checksum" );

my $out = write_packet( $packet );
cmp_ok( $out, 'eq', $good_packet, "Wrote packet data to filehandle" );


my $fresh_packet = UAV::Pilot::WumpusRover::PacketFactory->fresh_packet(
    'Heartbeat' );
isa_ok( $fresh_packet => 'UAV::Pilot::WumpusRover::Packet::Heartbeat' );
cmp_ok( $fresh_packet->message_id, '==', 0x01, "Message ID set" );

$fresh_packet->flight_mode( 1 );
$fresh_packet->timestamp( 0x1234 );
$fresh_packet->batt( 450 );
$fresh_packet->command_index( 0 );
ok(! $fresh_packet->_is_checksum_clean, "Checksum no longer correct" );

my $expect_packet = make_packet( '3444', );
my $got_packet = write_packet( $fresh_packet );
cmp_ok( $expect_packet, 'eq', $got_packet, "Wrote heartbeat packet" );
ok( $fresh_packet->_is_checksum_clean, "Checksum clean after write" );


sub write_packet
{
    my ($packet) = @_;
    my $out = '';

    open( my $fh, '>', \$out ) or die "Can't open ref to scalar: $!\n";
    $packet->write( $fh );
    close $fh;

    return $out;
}

sub make_packet
{
    my (@hex_str) = @_;
    pack 'H*', join( '', @hex_str );
}
