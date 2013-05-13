package UAV::Pilot::Sender::ARDrone::NavPacket;
use v5.14;
use Moose;
use namespace::autoclean;

use UAV::Pilot::Sender::ARDrone::NavPacket::Option;

has 'header' => (
    is  => 'ro',
    isa => 'Int',
);
has 'drone_state' => (
    is  => 'ro',
    isa => 'Int',
);
has 'sequence_num' => (
    is  => 'ro',
    isa => 'Int',
);
has 'vision_flag' => (
    is  => 'ro',
    isa => 'Int',
);
has 'checksum_id' => (
    is  => 'ro',
    isa => 'Int',
);
has 'checksum_length' => (
    is  => 'ro',
    isa => 'Int',
);
has 'options' => (
    is  => 'ro',
    isa => 'ArrayRef[UAV::Pilot::Sender::ARDrone::NavPacket::Option]',
    default => sub {
        [UAV::Pilot::Sender::ARDrone::NavPacket::Option->new],
    },
);


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

