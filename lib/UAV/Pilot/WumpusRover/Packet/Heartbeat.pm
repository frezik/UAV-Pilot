package UAV::Pilot::WumpusRover::Packet::Heartbeat;
use v5.14;
use Moose;
use namespace::autoclean;


use constant {
    payload_length => 7,
    message_id     => 0x01,
    payload_fields => [qw{ flight_mode timestamp batt command_index }],
    payload_fields_length => {
        flight_mode   => 1,
        timestamp     => 2,
        batt          => 2,
        command_index => 2,
    },
};


has 'flight_mode' => (
    is  => 'rw',
    isa => 'Int',
);
has 'timestamp' => (
    is  => 'rw',
    isa => 'Int',
);
has 'batt' => (
    is  => 'rw',
    isa => 'Int',
);
has 'command_index' => (
    is  => 'rw',
    isa => 'Int',
);

with 'UAV::Pilot::WumpusRover::Packet';


sub _encode_payload_for_write
{
    my ($self) = @_;
    my $packet = pack 'C n n n ',
        $self->flight_mode,
        $self->timestamp,
        $self->batt,
        $self->command_index;
    return $packet;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

