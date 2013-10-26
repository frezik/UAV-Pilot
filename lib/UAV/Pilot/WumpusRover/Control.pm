package UAV::Pilot::WumpusRover::Control;
use v5.14;
use Moose;
use namespace::autoclean;
use UAV::Pilot::WumpusRover::PacketFactory;

has 'host' => (
    is  => 'ro',
    isa => 'Str',
);
has 'port' => (
    is  => 'ro',
    isa => 'Int',
);
has '_turn' => (
    is      => 'ro',
    isa     => 'Int',
    default => 0,
    writer  => 'turn',
);
has '_throttle' => (
    is      => 'ro',
    isa     => 'Int',
    default => 0,
    writer  => 'throttle',
);

with 'UAV::Pilot::ControlRover';


after $_ => \&_send_move_packet for qw{ turn throttle };


sub connect
{
    my ($self) = @_;
    $self->_init_socket;

    my $packet = UAV::Pilot::WumpusRover::PacketFactory->fresh_packet(
        'RequestStartupMessage' );
    # TODO find out what Ardupilot wants for these params
    $packet->system_type( 0x0 );
    $packet->system_id( 0x0 );
    
    $self->_send_packet( $packet );
    return 1;
}

sub convert_sdl_input
{
    my ($self, $in) = @_;
    return $in;
}

sub _send_move_packet
{
    my ($self) = @_;
    my $packet = UAV::Pilot::WumpusRover::PacketFactory->fresh_packet(
        'RadioOutputs' );

    $packet->ch1_out( $self->_throttle );
    $packet->ch2_out( $self->_turn );

    return $self->_send_packet( $packet );
}

sub _send_packet
{
    my ($self, $packet) = @_;
    # TODO
    return 1;
}

before '_send_packet' => sub {
    my ($self, $packet) = @_;
    $packet->make_checksum_clean;
    return 1;
};


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

