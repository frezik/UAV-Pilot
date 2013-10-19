package UAV::Pilot::WumpusRover::Packet::Ack;
use v5.14;
use Moose;
use namespace::autoclean;


use constant {
    payload_length => 3,
    message_id     => 0x00,
    payload_fields => [qw{ message_received_id checksum_received }],
};


has 'message_received_id' => (
    is  => 'rw',
    isa => 'Int',
);
has 'checksum_received1' => (
    is  => 'rw',
    isa => 'Int',
);
has 'checksum_received2' => (
    is  => 'rw',
    isa => 'Int',
);

with 'UAV::Pilot::WumpusRover::Packet';


sub BUILDARGS
{
    my ($class, $args) = @_;
    my $payload = delete $args->{payload};
    my @payload = @$payload;

    $args->{message_received_id} = $payload[0];
    $args->{checksum_received1}  = $payload[1];
    $args->{checksum_received2}  = $payload[2];

    return $args;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

