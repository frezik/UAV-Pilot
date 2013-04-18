package UAV::Pilot::Device;
use v5.14;
use Moose;
use namespace::autoclean;

has 'sender' => (
    is  => 'ro',
    isa => 'UAV::Pilot::Sender',
);


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

