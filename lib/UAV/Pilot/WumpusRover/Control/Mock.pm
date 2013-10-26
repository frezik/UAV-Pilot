package UAV::Pilot::WumpusRover::Control::Mock;
use v5.14;
use Moose;
use namespace::autoclean;
use UAV::Pilot::WumpusRover::Control;

extends 'UAV::Pilot::WumpusRover::Control';

has 'last_packet_out' => (
    is     => 'ro',
    isa    => 'UAV::Pilot::WumpusRover::Packet',
    writer => '_send_packet',
);
has 'out_server' => (
    is  => 'ro',
    isa => 'UAV::Pilot::WumpusRover::Server',
);


sub _init_socket
{
    # Do nothing on purpose
    return 1;
}



no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

