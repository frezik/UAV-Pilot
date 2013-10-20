package UAV::Pilot::WumpusRover::Server;
use v5.14;
use Moose;
use namespace::autoclean;


has 'listen_port' => (
    is  => 'ro',
    isa => 'Int',
);
has 'backend' => (
    is  => 'ro',
    isa => 'UAV::Pilot::WumpusRover::Server::Backend',
);
with 'UAV::Pilot::Server';


sub process_packet
{
    my ($self, $packet) = @_;

    if( $self->backend->process_packet( $packet ) ) {
        my $ack = $self->_build_ack_packet( $packet );
        $self->_send_packet( $ack );
    }

    return 1;
}

sub _build_ack_packet
{
    my ($self, $packet) = @_;

    my $ack = UAV::Pilot::WumpusRover::PacketFactory->fresh_packet( 'Ack' );
    $ack->message_received_id( $packet->message_id );
    $ack->checksum_received1( $packet->checksum1 );
    $ack->checksum_received2( $packet->checksum2 );

    return $ack;
}

sub _send_packet
{
    my ($self, $packet) = @_;
    # TODO
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

