package UAV::Pilot::WumpusRover::Server;
use v5.14;
use Moose;
use namespace::autoclean;
use IO::Socket::INET ();
use UAV::Pilot::WumpusRover::PacketFactory;
use UAV::Pilot::WumpusRover::Server::Backend;

use constant BUF_LENGTH => 1024;


has 'listen_port' => (
    is      => 'ro',
    isa     => 'Int',
    default => 49_000,
);
has 'backend' => (
    is  => 'ro',
    isa => 'UAV::Pilot::WumpusRover::Server::Backend',
);
has '_socket' => (
    is  => 'rw',
    isa => 'Maybe[IO::Socket::INET]',
);
with 'UAV::Pilot::Server';
with 'UAV::Pilot::Logger';


sub init_listen_events
{
    my ($self, $cv) = @_;
    my $logger = $self->_logger;
    $logger->info( 'Starting listener on UDP port '
        . $self->listen_port );

    my $socket = IO::Socket::INET->new(
        Proto     => 'udp',
        LocalPort => $self->listen_port,
        Blocking  => 0,
    ) or UAV::Pilot::IOException->throw({
        error => 'Could not open socket: ' . $!,
    });
    $self->_socket( $socket );

    my $event; $event = AnyEvent->io(
        fh   => $socket,
        poll => 'r',
        cb   => sub {
            $logger->info( 'Received packet' );

            my $buf = undef;
            if( my $len = $socket->read( \$buf, $self->BUF_LENGTH ) ) {
                $logger->info( "Read $len bytes" );
                my $packet = UAV::Pilot::WumpusRover::PacketFactory
                    ->read_packet( $buf );
                $logger->info( 'Processing message ID: '
                    . $packet->message_id . ' (type: ' . ref($packet) . ')' );
                $self->process_packet( $packet );
            }
            else {
                $logger->info( "No data to read" );
            }

            $event;
        },
    );

    $logger->info( 'Done starting listener' );
    return 1;
}

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

