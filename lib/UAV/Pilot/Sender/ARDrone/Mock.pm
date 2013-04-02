package UAV::Pilot::Sender::ARDrone::Mock;
use v5.14;
use Moose;
use namespace::autoclean;

extends 'UAV::Pilot::Sender::ARDrone';


has 'last_cmd' => (
    is     => 'ro',
    isa    => 'Str',
    writer => '_send_cmd',
);


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

