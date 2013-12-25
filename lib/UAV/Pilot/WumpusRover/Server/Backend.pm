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
requires qw{
   ch1_max_out ch1_min_out
   ch2_max_out ch2_min_out
   ch3_max_out ch3_min_out
   ch4_max_out ch4_min_out
   ch5_max_out ch5_min_out
   ch6_max_out ch6_min_out
   ch7_max_out ch7_min_out
   ch8_max_out ch8_min_out
};

with 'UAV::Pilot::Logger';

has 'started' => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
    writer  => '_set_started',
);


sub process_packet
{
    my ($self, $packet, $server) = @_;

    my $packet_class = ref $packet;
    my ($short_class) = $packet_class =~ /:: (\w+) \z/x;

    if(! exists $self->PACKET_METHOD_MAP->{$short_class}) {
        $self->_logger->warn( "Couldn't find a method to handle packet"
            . " '$short_class'" );
        return 0;
    }

    my $method = $self->PACKET_METHOD_MAP->{$short_class};
    return $self->$method( $packet, $server );
}

#
# Implement _map_ch1_value() through _map_ch8_value() here
#
foreach my $i (1..8) {
    my $sub_name = '_map_ch' . $i . '_value';
    my $min_in = 'ch' . $i . '_min';
    my $max_in = 'ch' . $i . '_max';
    my $min_out = 'ch' . $i . '_min_out';
    my $max_out = 'ch' . $i . '_max_out';

    no strict 'refs';
    *$sub_name = sub {
        my ($self, $server, $val) = @_;
        return $server->_map_value(
            $server->$min_in,
            $server->$max_in,
            $self->$min_out,
            $self->$max_out,
            $val,
        );
    }
}


1;
__END__

