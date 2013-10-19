package UAV::Pilot::WumpusRover::Packet::RadioMins;
use v5.14;
use Moose;
use namespace::autoclean;


use constant {
    payload_length => 16,
    message_id     => 0x50,
    payload_fields => [qw{
        ch1_min
        ch2_min
        ch3_min
        ch4_min
        ch5_min
        ch6_min
        ch7_min
        ch8_min
    }],
    payload_fields_length => {
        ch1_min => 2,
        ch2_min => 2,
        ch3_min => 2,
        ch4_min => 2,
        ch5_min => 2,
        ch6_min => 2,
        ch7_min => 2,
        ch8_min => 2,
    },
};

has 'ch1_min' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch2_min' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch3_min' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch4_min' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch5_min' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch6_min' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch7_min' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch8_min' => (
    is  => 'rw',
    isa => 'Int',
);

with 'UAV::Pilot::WumpusRover::Packet';


sub _encode_payload_for_write
{
    my ($self) = @_;
    my $payload = pack 'C2' x 8, map( {
        my $field = 'ch' . $_ . '_mins';
        $self->$field;
    } (1..8));
    return $payload;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

