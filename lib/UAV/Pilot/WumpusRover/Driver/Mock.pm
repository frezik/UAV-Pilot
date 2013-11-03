package UAV::Pilot::WumpusRover::Driver::Mock;
use v5.14;
use Moose;
use namespace::autoclean;
use UAV::Pilot::WumpusRover::PacketFactory;

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

after '_send_packet' => sub {
    my ($self, $packet) = @_;
    $packet->make_checksum_clean;

    my $ack = UAV::Pilot::WumpusRover::PacketFactory->fresh_packet( 'Ack' );
    $ack->message_received_id( $packet->message_id );
    $ack->checksum_received1( $packet->checksum1 );
    $ack->checksum_received2( $packet->checksum2 );
    $ack->make_checksum_clean;

    $self->_process_ack( $ack );
    return 1;
};


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

