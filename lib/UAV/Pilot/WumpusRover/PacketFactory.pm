package UAV::Pilot::WumpusRover::PacketFactory;
use v5.14;
use warnings;
use UAV::Pilot;
use UAV::Pilot::Exceptions;
use UAV::Pilot::WumpusRover::Packet;
use UAV::Pilot::WumpusRover::Packet::Ack;
use UAV::Pilot::WumpusRover::Packet::Heartbeat;
use UAV::Pilot::WumpusRover::Packet::RequestStartupMessage;
use UAV::Pilot::WumpusRover::Packet::StartupMessage;
use UAV::Pilot::WumpusRover::Packet::RadioTrims;
use UAV::Pilot::WumpusRover::Packet::RadioMins;
use UAV::Pilot::WumpusRover::Packet::RadioMaxes;
use UAV::Pilot::WumpusRover::Packet::RadioOutputs;


use constant PACKET_CLASS_PREFIX  => 'UAV::Pilot::WumpusRover::Packet::';
use constant PREAMBLE             => 0x3444;
use constant MESSAGE_ID_CLASS_MAP => {
    0x00 => 'Ack',
    0x01 => 'Heartbeat',
    0x07 => 'RequestStartupMessage',
    0x08 => 'StartupMessage',
    0x50 => 'RadioTrims',
    0x51 => 'RadioMins',
    0x52 => 'RadioMaxes',
    0x53 => 'RadioOutputs',
};


sub read_packet
{
    my ($self, $packet) = @_;
    my @packet = unpack 'C*', $packet;

    my $preamble       = ($packet[0] << 8 ) | $packet[1];
    UAV::Pilot::ArdupilotPacketException::BadHeader->throw({
        got_header => $preamble,
    }) if $self->PREAMBLE != $preamble;

    my $payload_length = $packet[2];
    my $message_id     = $packet[3];
    my $version        = $packet[4];

    my $last_payload_i = 4 + $payload_length;
    my @payload        = @packet[5..$last_payload_i];
    my $checksum1      = $packet[-2];
    my $checksum2      = $packet[-1];

    my ($expect_checksum1, $expect_checksum2) = UAV::Pilot->checksum_fletcher8(
        $payload_length, $message_id, $version, @payload );
    UAV::Pilot::ArdupilotPacketException::BadChecksum->throw({
        got_checksum1      => $checksum1,
        got_checksum2      => $checksum2,
        expected_checksum1 => $expect_checksum1,
        expected_checksum2 => $expect_checksum2,
    }) if ($expect_checksum1 != $checksum1) || ($expect_checksum2 != $checksum2);

    if(! exists $self->MESSAGE_ID_CLASS_MAP->{$message_id}) {
        warn sprintf( 'No class found for message ID 0x%02x', $message_id )
            . "\n";
        return undef;
    }
    my $class = $self->PACKET_CLASS_PREFIX
        . $self->MESSAGE_ID_CLASS_MAP->{$message_id};
    my $new_packet = $class->new({
        preamble  => $preamble,
        version   => $version,
        checksum1 => $checksum1,
        checksum2 => $checksum2,
        payload   => \@payload,
    });
    return $new_packet;
}

sub fresh_packet
{
    my ($self, $type) = @_;
    my $class = $self->PACKET_CLASS_PREFIX . $type;

    my $packet = eval {
        $class->new({
            fresh => 1,
        });
    };
    if( $@ ) {
        die "[PacketFactory] Could not init '$class': $@\n";
    }

    return $packet;
}


1;
__END__

