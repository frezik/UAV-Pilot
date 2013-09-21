package UAV::Pilot::NavCollector::AckEvents;
use v5.14;
use Moose;
use namespace::autoclean;

with 'UAV::Pilot::NavCollector';


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

    if( $new_ack != $last_ack ) {
        my $event = $self->easy_event;
        $event->send_event( 'nav_ack_toggle', $new_ack );

        if( $new_ack ) {
            $event->send_event( 'nav_ack_on' );
        }
        else {
            $event->send_event( 'nav_ack_off' );
        }

        $self->_last_ack_status( $new_ack );
    }

    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

