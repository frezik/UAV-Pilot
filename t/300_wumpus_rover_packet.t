use Test::More tests => 13;
use strict;
use warnings;
use UAV::Pilot::WumpusRover::Packet;
use UAV::Pilot::Exceptions;


my $bad_header = make_packet( '3445', '03', '00', '00', '01', '0000' );
eval {
    local $SIG{__WARN__} = sub {}; # Temporarily suppress warnings
    UAV::Pilot::WumpusRover::Packet->new({
        packet => $bad_header
    });
};
if( $@ && $@->isa( 'UAV::Pilot::ArdupilotPacketException::BadHeader' ) ) {
    pass( 'Caught Bad Header exception' );
    cmp_ok( $@->got_header, '==', 0x3445, "BadHeader exception has got_header value" );
}
else {
    fail( 'Did not catch Bad Header exception' );
    fail( 'Fail matching magic number, too [placeholder failure for test count]' );
}

my $bad_checksum = make_packet( '3444', '03', '00', '00', '01', '040C' );
eval {
    local $SIG{__WARN__} = sub {}; # Temporarily suppress warnings
    UAV::Pilot::WumpusRover::Packet->new({
        packet => $bad_checksum
    });
};
if( $@ && $@->isa( 'UAV::Pilot::ArdupilotPacketException::BadChecksum' ) ) {
    pass( 'Caught Bad Checksum exception' );
    cmp_ok( $@->got_checksum, '==', 0x040C, "BadChecksum exception has got_checksum value" );
    cmp_ok( $@->expected_checksum, '==', 0x040D, "BadChecksum exception has expected_checksum value" );
}
else {
    fail( 'Did not catch Bad Header exception' );
    fail( 'Fail got checksum, too [placeholder failure for test count]' );
    fail( 'Fail expected checksum [placeholder failure for test count]' );
}


my $good_packet = make_packet( '3444', '03', '00', '00', '01', '040D' );
my $packet = UAV::Pilot::WumpusRover::Packet->new({
    packet => $good_packet
});
isa_ok( $packet => 'UAV::Pilot::WumpusRover::Packet' );
isa_ok( $packet => 'UAV::Pilot::WumpusRover::Packet::Ack' );
cmp_ok( $packet->preamble,        '==', 0x3344, "Preamble set" );
cmp_ok( $packet->payload_length,  '==', 0x03,   "Payload length set" );
cmp_ok( $packet->message_id,      '==', 0x01,   "Message ID set" );
cmp_ok( $packet->version,         '==', 0x00,   "Version set" );
cmp_ok( $packet->message_id_recv, '==', 0x01,   "Message ID received" );
cmp_ok( $packet->checksum,        '==', 0x040D, "Checksum" );



sub make_packet
{
    my (@hex_str) = @_;
    pack 'h*', join( '', @hex_str );
}
