package UAV::Pilot::WumpusRover::Packet::Ack;
use v5.14;
use Moose;
use namespace::autoclean;

use constant payload_length => 3;
use constant message_id     => 0x00;
use constant payload_fields => [ 'message_received_id', 'checksum_received' ];


has 'message_received_id' => (
    is  => 'rw',
    isa => 'Int',
);
has 'checksum_received' => (
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
    $args->{checksum_received}   = pack 'C2', @payload[1,2];

    return $args;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

