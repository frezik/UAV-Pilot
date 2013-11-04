package UAV::Pilot::WumpusRover::Server;
use v5.14;
use Moose;
use namespace::autoclean;
use IO::Socket::INET ();
use UAV::Pilot::WumpusRover::PacketFactory;
use UAV::Pilot::WumpusRover::Server::Backend;
use Time::HiRes ();
use Errno qw(:POSIX);

use constant BUF_LENGTH => 1024;
use constant SLEEP_LOOP_US => 1_000_000 / 100; # In microseconds


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


sub start_listen_loop
{
    my ($self) = @_;
    $self->_init_socket;

    my $CONTINUE = 1;
    while($CONTINUE) {
        if(! $self->_read_packet ) {
            # If we didn't read a packet, sleep for a while 
            Time::HiRes::usleep( $self->SLEEP_LOOP_US );
        }
    }

    return 1;
}

sub process_packet
{
    my ($self, $packet) = @_;
    my $backend = $self->backend;

    my $process = sub {
        if( $backend->process_packet($packet) ) {
            my $ack = $self->_build_ack_packet( $packet );
            $self->_send_packet( $ack );           
        }
    };

    if(! $backend->started) {
        if( $packet->isa(
            'UAV::Pilot::WumpusRover::Packet::RequestStartupMessage' )) {
            $process->();
        }
        else {
            $self->_logger->warn( "Recieved packet, but we need a"
                . " RequestStartupMessage first");
        }
    }
    else {
        $process->();
    }

    return 1;
}

sub _read_packet
{
    my ($self) = @_;
    my $logger = $self->_logger;
    my $return = 1;
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
        # Possible error
        if($!{EAGAIN} || $!{EWOULDBLOCK}) {
            $logger->info( 'No data to read' );
        }
        else {
            UAV::Pilot::IOException->throw({
                error => $!,
            });
        }
    }
    else {
        $return = 0;
        $logger->info( "No data to read" );
    }

    return $return;
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

sub _init_socket
{
    my ($self) = @_;
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

    $self->_logger->info( 'Done starting listener' );
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

