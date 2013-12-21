package UAV::Pilot::WumpusRover::Server::Backend::RaspberryPiI2C;
use v5.14;
use Moose;
use namespace::autoclean;
use UAV::Pilot::WumpusRover::Server::Backend;
use UAV::Pilot::WumpusRover::PacketFactory;
use HiPi::Device::I2C ();
use HiPi::BCM2835::I2C qw( :all );
use Time::HiRes ();

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
    default => 0x09,
);
has 'throttle_register' => (
    is      => 'ro',
    isa     => 'Int',
    default => 0x01,
);
has 'turn_register' => (
    is      => 'ro',
    isa     => 'Int',
    default => 0x02,
);
has 'i2c_device' => (
    is      => 'ro',
    isa     => 'Int',
    default => BB_I2C_PERI_1,
);
has '_last_time_packet_sent' => (
    is      => 'rw',
    isa     => 'Num',
    default => 0.0,
);


sub BUILD
{
    my ($self) = @_;
    my $logger = $self->_logger;
    $logger->info( 'Attempting to init i2c comm on slave addr ['
        . $self->slave_addr . ']' );

    my $i2c = HiPi::BCM2835::I2C->new(
        peripheral => $self->i2c_device,
        address    => $self->slave_addr,
    );
    $self->_set_i2c( $i2c );

    $logger->info( 'Init i2c comm done' );
    return 1;
}


sub _packet_request_startup
{
    my ($self, $packet) = @_;
    $self->_set_started( 1 );
    return 1;
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

    my $throttle = $packet->ch1_out;
    my $turn     = $packet->ch2_out;
    my @throttle_bytes = unpack 'cc', $throttle;
    my @turn_bytes     = unpack 'cc', $turn;

    $self->_write_packet( $self->throttle_register, @throttle_bytes );
    $self->_write_packet( $self->turn_register,     @turn_bytes     );
    return 1;
}


sub _write_packet
{
    my ($self, $register, @bytes) = @_;
    my $logger = $self->_logger;

    eval {
        $logger->info( "Writing [@bytes] to register [$register]" );
        $self->_i2c->bus_write( $register, @bytes );
    };
    if( $@ ) {
        $logger->warn( 'Could not write i2c data: ' . $@ );
    }

    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME

  UAV::Pilot::WumpusRover::Server::Backend::RaspberryPiI2C

=cut
