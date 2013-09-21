package UAV::Pilot::NavProcessor;
use v5.14;
use Moose;
use namespace::autoclean;


has 'collectors' => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[UAV::Pilot::NavCollector]',
    default => sub {[]},
    handles => {
        add_nav_collector => 'push',
    },
);
has 'easy_event' => (
    is  => 'ro',
    isa => 'UAV::Pilot::EasyEvent',
);
has '_last_nav_ack' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);


sub got_new_nav_packet
{
    my ($self, $packet) = @_;

    my $ack_status = $packet->state_control_received;
    if( $self->_last_nav_ack != $ack_status ) {
        $self->_last_nav_ack( $ack_status );
        my $event = $self->easy_event;

        $event->send_event( 'nav_ack_toggle', $ack_status );
        if( $ack_status ) {
            $event->send_event( 'nav_ack_on' );
        }
        else {
            $event->send_event( 'nav_ack_off' );
        }
    }

    $_->got_new_nav_packet( $ack_status ) for @{ $self->collectors };

    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

