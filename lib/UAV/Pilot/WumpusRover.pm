package UAV::Pilot::WumpusRover;
use v5.14;
use warnings;
use Moose;
use namespace::autoclean;

use constant DEFAULT_PORT => 49_000;


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

