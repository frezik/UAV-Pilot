package UAV::Pilot::WumpusRover::Driver::Mock;
use v5.14;
use Moose;
use namespace::autoclean;

extends 'UAV::Pilot::WumpusRover::Driver';


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

