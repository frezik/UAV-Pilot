package UAV::Pilot::WumpusRover::Server::Backend::RaspberryPiI2C;
use v5.14;
use Moose;
use namespace::autoclean;
use UAV::Pilot::WumpusRover::Server::Backend;
use UAV::Pilot::WumpusRover::PacketFactory;
use HiPi::BCM2835::I2C qw( :all );

use constant REGISTER   => 0x00;


with 'UAV::Pilot::WumpusRover::Server::Backend';
with 'UAV::Pilot::Logger';

has '_i2c' => (
    is     => 'ro',
    isa    => 'HiPi::BCM2835::I2C',
    writer => '_set_i2c',
);
has 'slave_addr' => (
    is      => 'ro',
    isa     => 'Int',
    default => 0x10,
);
has 'register' => (
    is      => 'ro',
    isa     => 'Int',
    default => 0x1F,
);
has 'i2c_device' => (
    is      => 'ro',
    isa     => 'Int',
    default => BB_I2C_PERI_1,
);


sub BUILD
{
    my ($self) = @_;
    my $logger = $self->_logger;
    $logger->info( 'Attempting to init i2c comm on slave addr ['
        . $self->slave_addr . '] for register [' . $self->register . ']' );

    my $i2c = HiPi::BCM2835::I2C->new(
        peripheral => $self->i2c_device,
        address    => $self->slave_addr,
    );
    $self->_set_i2c( $i2c );

    $logger->info( 'Started i2c device, attempting to communicate' );
    # TODO Implement StartupMessage (not RequestStartupMessage) and use 
    # that here instead
    my $ack = UAV::Pilot::WumpusRover::PacketFactory->fresh_packet( 'Ack' );
    $ack->message_received_id( 0x00 );
    $ack->checksum_received1( 0x01 );
    $ack->checksum_received2( 0x02 );
    $ack->make_checksum_clean;
    $self->_write_packet( $ack );

    $logger->info( 'Init i2c comm done' );
    return 1;
}


sub _packet_request_startup
{
    # Ignore
}

sub _packet_radio_trims
{
    # Ignore
}

sub _packet_radio_mins
{
    # Ignore
}

sub _packet_radio_maxes
{
    # Ignore
}

sub _packet_radio_out
{
    my ($self, $packet) = @_;
    $self->_logger->info( 'Writing packet: ' . ref($packet) );
    $self->_write_packet( $packet );
    return 1;
}


sub _write_packet
{
    my ($self, $packet) = @_;
    my $byte_vec = $packet->make_byte_vector;
    my @bytes = unpack 'C*', $byte_vec;
    $self->_i2c->bus_write( $self->register, @bytes );
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

