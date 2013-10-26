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
has '_condvar' => (
    is  => 'rw',
    isa => 'Maybe[AnyEvent::CondVar]',
);
with 'UAV::Pilot::Server';
with 'UAV::Pilot::Logger';


sub init_listen_events
{
    my ($self, $cv) = @_;
    $self->_logger->info( 'Starting listener on UDP port '
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
            $self->_read_packet;
            $event;
        },
    );

    $self->_condvar( $cv );
    $self->_logger->info( 'Done starting listener' );
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

sub _read_packet
{
    my ($self) = @_;
    my $logger = $self->_logger;
    $logger->info( 'Received packet' );

    my $buf = undef;
    my $len = read( $self->_socket, $buf, $self->BUF_LENGTH );
    if( defined($len) && ($len > 0) ) {
        my $len = length $buf;
        $logger->info( "Read $len bytes" );
        my $packet = eval {
            my $packet = UAV::Pilot::WumpusRover::PacketFactory
                ->read_packet( $buf );
            $logger->info( 'Processing message ID: '
                . $packet->message_id . ' (type: ' . ref($packet) . ')' );
            $self->process_packet( $packet );
        };
        if( ref($@) ) {
            if( $@->isa( 'UAV::Pilot::ArdupilotPacketException::Badheader' ) ) {
                $self->_logger->warn(
                    'Bad header in packet: [' . $@->got_header . ']' );
            }
            elsif( $@->isa(
                'UAV::Pilot::ArdupilotPacketException::BadChecksum'
            )) {
                $self->_logger->warn( 'Bad checksum in packet' );
                $self->_logger->warn( 'Expected checksum: '
                    . $@->expected_checksum1 . ', ' . $@->expected_checksum2 );
                $self->_logger->warn( 'Got checksum: '
                    . $@->got_checksum1 . ', ' . $@->got_checksum2 );
            }
            else {
                $self->_logger->warn( 'Got exception: ' . ref($@) );
                $@->rethrow;
            }
        }
        elsif( $@ ) {
            die "Error processing packet: $@\n";
        }
    }
    elsif(! defined $len) {
        # Error
        UAV::Pilot::IOException->throw({
            error => $!,
        });
    }
    else {
        # Shouldn't happen with AnyEvent.  Probably.
        $logger->info( "No data to read" );
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

