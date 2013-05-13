package UAV::Pilot::Sender::ARDrone::NavPacket::Option;
use v5.14;
use Moose;
use namespace::autoclean;

has 'id' => (
    is  => 'ro',
    isa => 'Int',
);
has 'size' => (
    is  => 'ro',
    isa => 'Int',
);
has 'data' => (
    is  => 'ro',
    isa => 'Int',
);


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

