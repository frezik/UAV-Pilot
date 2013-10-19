package UAV::Pilot::WumpusRover::Packet::RadioOutputs;
use v5.14;
use Moose;
use namespace::autoclean;


use constant {
    payload_length => 16,
    message_id     => 0x53,
    payload_fields => [qw{
        ch1_out
        ch2_out
        ch3_out
        ch4_out
        ch5_out
        ch6_out
        ch7_out
        ch8_out
    }],
    payload_fields_length => {
        ch1_out => 2,
        ch2_out => 2,
        ch3_out => 2,
        ch4_out => 2,
        ch5_out => 2,
        ch6_out => 2,
        ch7_out => 2,
        ch8_out => 2,
    },
};

has 'ch1_out' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch2_out' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch3_out' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch4_out' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch5_out' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch6_out' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch7_out' => (
    is  => 'rw',
    isa => 'Int',
);
has 'ch8_out' => (
    is  => 'rw',
    isa => 'Int',
);

with 'UAV::Pilot::WumpusRover::Packet';


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

