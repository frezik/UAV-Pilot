package UAV::Pilot::WumpusRover::Driver;
use v5.14;
use Moose;
use namespace::autoclean;

has 'port' => (
    is      => 'ro',
    isa     => 'Int',
    default => 45000,
);

with 'UAV::Pilot::Driver';
with 'UAV::Pilot::Logger';


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

