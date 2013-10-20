package UAV::Pilot::WumpusRover::Driver::Mock;
use v5.14;
use Moose;
use namespace::autoclean;

extends 'UAV::Pilot::WumpusRover::Driver';


has 'last_sent_packet' => (
    is     => 'rw',
    isa    => 'UAV::Pilot::WumpusRover::Packet',
    writer => '_send_packet',
);

sub _init_connection
{
    my ($self) = @_;
    # Do nothing on purpose
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

