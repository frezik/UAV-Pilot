package UAV::Pilot::WumpusRover::Packet::RadioTrims;
use v5.14;
use Moose;
use namespace::autoclean;


use constant {
    payload_length => 16,
    message_id     => 0x50,
    payload_fields => [qw{
        ch1_trim
        ch2_trim
        ch3_trim
        ch4_trim
        ch5_trim
        ch6_trim
        ch7_trim
        ch8_trim
    }],
    payload_fields_length => {
        ch1_trim => 2,
        ch2_trim => 2,
        ch3_trim => 2,
        ch4_trim => 2,
        ch5_trim => 2,
        ch6_trim => 2,
        ch7_trim => 2,
        ch8_trim => 2,
    },
};

has 'ch1_trim' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch2_trim' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch3_trim' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch4_trim' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch5_trim' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch6_trim' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch7_trim' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch8_trim' => (
    is  => 'rw',
    isa => 'Int',
);

with 'UAV::Pilot::WumpusRover::Packet';


sub _encode_payload_for_write
{
    my ($self) = @_;
    my $payload = pack 'C2' x 8, map( {
        my $field = 'ch' . $_ . '_trim';
        $self->$field;
    } (1..8));
    return $payload;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

