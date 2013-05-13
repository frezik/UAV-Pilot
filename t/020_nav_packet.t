use Test::More tests => 13;
use v5.14;
use warnings;

use UAV::Pilot::Sender::ARDrone::NavPacket;

my $bad_header = make_packet( '55667788' );
eval {
    UAV::Pilot::Sender::ARDrone::NavPacket->new({
        packet => $bad_header
    });
};
if( $@ && $@->isa( 'UAV::Pilot::NavPacketException::BadHeader' ) ) {
    pass( 'Caught Bad Header exception' );
}
else {
    local $TODO = "Not yet parsing";
    fail( 'Did not catch Bad Header exception' );
}


my $packet_data = make_packet( join('',
    '89776655',   # Header
    'd004800f',   # Drone state
    '336f0000',   # Sequence number
    '01000000',   # Vision flag
    # No options on this packet besides checksum
    'ffff',       # Checksum ID
    '0800',       # Checksum size
    'c1030000',   # Checksum data
) );
my $packet = UAV::Pilot::Sender::ARDrone::NavPacket->new({
    packet => $packet_data
});
isa_ok( $packet => 'UAV::Pilot::Sender::ARDrone::NavPacket' );

TODO: {
    local $TODO = "Need to implement packet parsing";
    cmp_ok( $packet->header,          '==', 0x55667788, "Header (magic number) parsed" );
    cmp_ok( $packet->drone_state,     '==', 0x0f8004d0, "Drone state parsed" );
    cmp_ok( $packet->sequence_num,    '==', 0x00006f33, "Sequence number parsed" );
    cmp_ok( $packet->vision_flag,     '==', 0x00000001, "Vision flag parsed" );
    cmp_ok( $packet->checksum_id,     '==', 0x0003,     "Checksum ID" );
    cmp_ok( $packet->checksum_length, '==', 0x00,       "Checksum length" );

    my ($checksum, @options) = @{ $packet->options };
    isa_ok( $checksum => 'UAV::Pilot::Sender::ARDrone::NavPacket::Option' );
    cmp_ok( scalar(@options), '==', 0, "Only one option found" );
    cmp_ok( $checksum->id,   '==', 0xffff,     "First option ID parsed" );
    cmp_ok( $checksum->size, '==', 0x0008,     "First option size parsed" );
    cmp_ok( $checksum->data, '==', 0xc1030000, "First option data parsed" );
}


sub make_packet
{
    my ($hex_str) = @_;
    pack 'h*', $hex_str;
}
