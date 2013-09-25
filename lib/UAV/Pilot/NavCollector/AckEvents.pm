package UAV::Pilot::NavCollector::AckEvents;
use v5.14;
use Moose;
use namespace::autoclean;

with 'UAV::Pilot::NavCollector';
with 'UAV::Pilot::Logger';


has 'easy_event' => (
    is  => 'ro',
    isa => 'UAV::Pilot::EasyEvent',
);
has '_last_ack_status' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);


sub got_new_nav_packet
{
    my ($self, $packet) = @_;
    my $new_ack = $packet->state_control_received;
    my $last_ack = $self->_last_ack_status;
    my $event = $self->easy_event;
    my $logger = $self->_logger;

    $logger->info( "Got nav ACK of $new_ack, old ack is $last_ack" );
    my $send_event = $new_ack
        ? 'nav_ack_on'
        : 'nav_ack_off';
    $logger->inf( "Sending $send_event event" );
    $event->send_event( $send_event );

    if( $new_ack != $last_ack ) {
        $logger->inf( "Sending nav_ack_toggle event" );
        $event->send_event( 'nav_ack_toggle', $new_ack );
        $self->_last_ack_status( $new_ack );
    }

    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

