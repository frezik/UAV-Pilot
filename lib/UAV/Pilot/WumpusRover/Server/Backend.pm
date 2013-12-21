package UAV::Pilot::WumpusRover::Server::Backend;
use v5.14;
use Moose::Role;

use constant PACKET_METHOD_MAP => {
    'RequestStartupMessage' => '_packet_request_startup',
    'RadioTrims'            => '_packet_radio_trims',
    'RadioMins'             => '_packet_radio_mins',
    'RadioMaxes'            => '_packet_radio_maxes',
    'RadioOutputs'          => '_packet_radio_out',
};

requires $_ for values %{ +PACKET_METHOD_MAP };

with 'UAV::Pilot::Logger';

has 'started' => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
    writer  => '_set_started',
);


sub process_packet
{
    my ($self, $packet) = @_;

    my $packet_class = ref $packet;
    my ($short_class) = $packet_class =~ /:: (\w+) \z/x;

    if(! exists $self->PACKET_METHOD_MAP->{$short_class}) {
        $self->_logger->warn( "Couldn't find a method to handle packet"
            . " '$short_class'" );
        return 0;
    }

    my $method = $self->PACKET_METHOD_MAP->{$short_class};
    return $self->$method( $packet );
}


1;
__END__

