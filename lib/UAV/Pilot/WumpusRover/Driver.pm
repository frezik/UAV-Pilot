package UAV::Pilot::WumpusRover::Driver;
use v5.14;
use Moose;
use namespace::autoclean;
use UAV::Pilot::WumpusRover::PacketFactory;

has 'port' => (
    is      => 'ro',
    isa     => 'Int',
    default => 45000,
);
has 'host' => (
    is  => 'ro',
    isa => 'Str',
);
has '_socket' => (
    is  => 'rw',
    isa => 'IO::Socket::INET',
);

with 'UAV::Pilot::Driver';
with 'UAV::Pilot::Logger';


sub connect
{
    my ($self) = @_;
    my $logger = $self->_logger;

    $logger->info( 'Connecting . . . ' );
    $self->_init_connection;

    my $startup_request = UAV::Pilot::WumpusRover::PacketFactory->fresh_packet(
        'RequestStartupMessage' );
    # TODO find out what Ardupilot wants for these params
    $startup_request->system_type( 0x00 );
    $startup_request->system_id( 0x00 );
    $self->_send_packet( $startup_request );

    return 1;
}


sub _init_connection
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

sub send_radio_output_packet
{
    my ($self, @channels) = @_;
    my $radio_packet = UAV::Pilot::WumpusRover::PacketFactory->fresh_packet(
        'RadioOutputs' );

    foreach my $i (1..8) {
        my $value = $channels[$i-1] // 0;
        my $packet_field = 'ch' . $i . '_out';
        $radio_packet->$packet_field( $value );
    }

    $self->_send_packet( $radio_packet );
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

