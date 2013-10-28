package UAV::Pilot::WumpusRover::Server::Backend::RaspberryPiI2C;
use v5.14;
use Moose;
use namespace::autoclean;
use UAV::Pilot::WumpusRover::Server::Backend;
use HiPi::BCM2835::I2C qw( :all );

use constant ADDR       => 0x28;
use constant DEVICE     => '/dev/i2c-1';
use constant BUSMODE    => 'i2c';
use constant SLAVE_ADDR => 0x04;
use constant REGISTER   => 0x00;

with 'UAV::Pilot::WumpusRover::Server::Backend';
with 'UAV::Pilot::Logger';

has '_i2c' => (
    is  => 'ro',
    isa => 'HiPi::BCM2835::I2C',
);


sub BUILDARGS
{
    my ($self, $args) = @_;

    my $i2c = HiPi::BCM2835::I2C->new(
        peripheral => BB_I2C_PERI_1,
        address    => $self->SLAVE_ADDR,
    );
    $args->{'_i2c'} = $i2c;

    return $args;
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
    my $byte_vec = $packet->make_byte_vector;
    my @bytes = unpack 'C*', $byte_vec;
    $self->_i2c->i2c_write( $self->REGISTER, $_ ) for @bytes;
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

