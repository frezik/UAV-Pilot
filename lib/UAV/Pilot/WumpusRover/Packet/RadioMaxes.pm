package UAV::Pilot::WumpusRover::Packet::RadioMaxes;
use v5.14;
use Moose;
use namespace::autoclean;


use constant {
    payload_length => 16,
    message_id     => 0x50,
    payload_fields => [qw{
        ch1_max
        ch2_max
        ch3_max
        ch4_max
        ch5_max
        ch6_max
        ch7_max
        ch8_max
    }],
    payload_fields_length => {
        ch1_max => 2,
        ch2_max => 2,
        ch3_max => 2,
        ch4_max => 2,
        ch5_max => 2,
        ch6_max => 2,
        ch7_max => 2,
        ch8_max => 2,
    },
};

has 'ch1_max' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch2_max' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch3_max' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch4_max' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch5_max' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch6_max' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch7_max' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch8_max' => (
    is  => 'rw',
    isa => 'Int',
);

with 'UAV::Pilot::WumpusRover::Packet';


sub _encode_payload_for_write
{
    my ($self) = @_;
    my $payload = pack 'C2' x 8, map( {
        my $field = 'ch' . $_ . '_max';
        $self->$field;
    } (1..8));
    return $payload;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

