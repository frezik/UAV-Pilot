package UAV::Pilot::WumpusRover::Server;
use v5.14;
use Moose;
use namespace::autoclean;


use constant PROCESS_PACKET_MAP => {
    'RequestStartupMessage' => '_process_request_startup',
};


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

    my $process_method = $self->_get_process_method( $packet );
    return 0 unless defined $process_method;
    $self->$process_method( $packet );

    my $ack = $self->_build_ack_packet( $packet );
    $self->_send_packet( $ack );

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

sub _get_process_method
{
    my ($self, $packet) = @_;
    my $packet_class = ref $packet;
    my ($short_class) = $packet_class =~ /:: (\w+) \z/x;

    if(! exists $self->PROCESS_PACKET_MAP->{$short_class} ) {
        $self->_logger->warn( "No method found to process packet type"
            . " '$short_class'" );
        return undef;
    }

    my $process_method = $self->PROCESS_PACKET_MAP->{$short_class};
    return $process_method;
}

sub _process_request_startup
{
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

