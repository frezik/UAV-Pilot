package UAV::Pilot::WumpusRover::Packet::RequestStartupMessage;
use v5.14;
use Moose;
use namespace::autoclean;


use constant {
    payload_length => 2,
    message_id     => 0x07,
    payload_fields => [qw{
        system_type
        system_id
    }],
    payload_fields_length => {
        system_type => 1,
        system_id   => 1,
    },
};


has 'system_type' => (
    is  => 'rw',
    isa => 'Int',
);
has 'system_id' => (
    is  => 'rw',
    isa => 'Int',
);

with 'UAV::Pilot::WumpusRover::Packet';


sub _encode_payload_for_write
{
    my ($self) = @_;
    my $payload = pack 'C C',
        $self->system_type,
        $self->system_id;
    return $payload;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

