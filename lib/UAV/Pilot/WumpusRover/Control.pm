package UAV::Pilot::WumpusRover::Control;
use v5.14;
use Moose;
use namespace::autoclean;
use UAV::Pilot::WumpusRover::PacketFactory;
use IO::Socket::INET;

has 'host' => (
    is  => 'ro',
    isa => 'Str',
);
has 'port' => (
    is  => 'ro',
    isa => 'Int',
);
has '_socket' => (
    is  => 'rw',
    isa => 'IO::Socket::INET',
);
has 'turn' => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);
has 'throttle' => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

with 'UAV::Pilot::ControlRover';
with 'UAV::Pilot::Logger';



sub connect
{
    my ($self) = @_;
    my $logger = $self->_logger;

    $logger->info( 'Connecting . . . ' );
    $self->_init_socket;

    $logger->info( 'Sending Request Startup Message packet' );
    my $packet = UAV::Pilot::WumpusRover::PacketFactory->fresh_packet(
        'RequestStartupMessage' );
    # TODO find out what Ardupilot wants for these params
    $packet->system_type( 0x0 );
    $packet->system_id( 0x0 );
    
    $self->_send_packet( $packet );
    $logger->info( 'Request Startup Message packet sent' );
    $logger->info( 'Finished connecting' );
    return 1;
}

sub convert_sdl_input
{
    my ($self, $in) = @_;
    return $in;
}

sub send_move_packet
{
    my ($self) = @_;
    my $packet = UAV::Pilot::WumpusRover::PacketFactory->fresh_packet(
        'RadioOutputs' );

    $packet->ch1_out( $self->throttle );
    $packet->ch2_out( $self->turn );

    return $self->_send_packet( $packet );
}

sub _send_packet
{
    my ($self, $packet) = @_;
    $packet->write( $self->_socket );
    return 1;
}
# Cleanup packet in 'before' so the Mock version also does it
before '_send_packet' => sub {
    my ($self, $packet) = @_;
    $packet->make_checksum_clean;
    return 1;
};

sub _init_socket
{
    my ($self) = @_;
    my $logger = $self->_logger;

    $logger->info( 'Open UDP socket to ' . $self->host . ':' . $self->port );
    my $socket = IO::Socket::INET->new(
        Proto    => 'udp',
        PeerHost => $self->host,
        PeerPort => $self->port,
    ) or UAV::Pilot::IOException->throw({
        error => 'Could not open socket: ' . $!,
    });
    $logger->info( 'Done opening socket' );

    $self->_socket( $socket );
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

