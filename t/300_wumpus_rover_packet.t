use Test::More tests => 31;
use strict;
use warnings;
use UAV::Pilot::WumpusRover::PacketFactory;
use UAV::Pilot::WumpusRover::Packet;
use UAV::Pilot::Exceptions;
use Test::Moose;


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


my $good_packet = make_packet( '3444', '03', '00', '00', '010A0B', '1934' );
my $packet = UAV::Pilot::WumpusRover::PacketFactory->read_packet( $good_packet );
does_ok( $packet => 'UAV::Pilot::WumpusRover::Packet' );
isa_ok( $packet => 'UAV::Pilot::WumpusRover::Packet::Ack' );
cmp_ok( $packet->preamble,            '==', 0x3444, "Preamble set" );
cmp_ok( $packet->payload_length,      '==', 0x03,   "Payload length set" );
cmp_ok( $packet->message_id,          '==', 0x00,   "Message ID set" );
cmp_ok( $packet->version,             '==', 0x00,   "Version set" );
cmp_ok( $packet->message_received_id, '==', 0x01,   "Message ID received" );
cmp_ok( $packet->checksum1,           '==', 0x19,   "Checksum1" );
cmp_ok( $packet->checksum2,           '==', 0x34,   "Checksum2" );
cmp_ok( $packet->checksum_received1,  '==', 0x0A,   "Checksum Received1" );
cmp_ok( $packet->checksum_received2,  '==', 0x0B,   "Checksum Received2" );


my $out = to_hex_string( write_packet( $packet ) );
cmp_ok( $out, 'eq', to_hex_string($good_packet),
    "Wrote packet data to filehandle" );


my $fresh_packet = UAV::Pilot::WumpusRover::PacketFactory->fresh_packet(
    'Heartbeat' );
isa_ok( $fresh_packet => 'UAV::Pilot::WumpusRover::Packet::Heartbeat' );
cmp_ok( $fresh_packet->message_id, '==', 0x01, "Message ID set" );

$fresh_packet->flight_mode( 1 );
$fresh_packet->timestamp( 0x1234 );
$fresh_packet->batt( 450 );
$fresh_packet->command_index( 0 );
ok(! $fresh_packet->_is_checksum_clean, "Checksum no longer correct" );

my $expect_packet = make_packet( '3444', '07', '01', '00', '01123401C20000',
    '12', '10' );
my $got_packet = to_hex_string( write_packet( $fresh_packet ) );
cmp_ok( $got_packet, 'eq', to_hex_string($expect_packet),
    "Wrote heartbeat packet" );
ok( $fresh_packet->_is_checksum_clean, "Checksum clean after write" );


my @TESTS = (
    # Each entry has 1 test plus the number of keys in 'fields'
    {
        expect_class => 'RequestStartupMessage',
        packet => make_packet( '3444', '02', '07', '00', '0A', 'A0',
            'B3', 'DA' ),
        fields => {
            system_type => 0x0A,
            system_id   => 0xA0,
        },
    },

    {
        expect_class => 'StartupMessage',
        packet => make_packet( '3444', '05', '08', '00', '0A', 'A0',
            'B0', '0B', 'C0', '32', 'F8' ),
        fields => {
            system_type      => 0x0A,
            system_id        => 0xA0,
            firmware_version => 0xB00BC0,
        },
    },
);
my $CLASS_PREFIX = 'UAV::Pilot::WumpusRover::Packet::';
foreach (@TESTS) {
    my $packet_data = $_->{packet};
    my %fields = %{ $_->{fields} };
    my $short_class  = $_->{expect_class};
    my $expect_class = $CLASS_PREFIX . $short_class;

    my $packet = UAV::Pilot::WumpusRover::PacketFactory->read_packet(
        $packet_data );
    isa_ok( $packet => $expect_class );

    foreach my $field (keys %fields ) {
        cmp_ok( $packet->$field, '==', $fields{$field},
            "$short_class->$field matches" );
    }
}


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

sub to_hex_string
{
    my ($str) = @_;
    my @str = unpack 'C*', $str;
    return join '', '0x', map( { sprintf '%02x', $_ } @str );
}
