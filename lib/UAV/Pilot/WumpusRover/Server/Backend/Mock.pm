package UAV::Pilot::WumpusRover::Server::Backend::Mock;
use v5.14;
use Moose;
use namespace::autoclean;

extends 'UAV::Pilot::WumpusRover::Server::Backend';


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

