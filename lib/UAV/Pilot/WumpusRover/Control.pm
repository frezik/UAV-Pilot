package UAV::Pilot::WumpusRover::Control;
use v5.14;
use Moose;
use namespace::autoclean;
use UAV::Pilot::WumpusRover::PacketFactory;
use IO::Socket::INET;


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
has 'driver' => (
    is  => 'ro',
    isa => 'UAV::Pilot::WumpusRover::Driver',
);

with 'UAV::Pilot::ControlRover';
with 'UAV::Pilot::Logger';



sub connect
{
    my ($self) = @_;
    $self->driver->connect;
    my $logger = $self->_logger;


    $logger->info( 'Sending Request Startup Message packet' );
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
    my @channels = (
        $self->throttle,
        $self->turn,
    );
    return $self->driver->send_radio_output_packet( @channels );
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

