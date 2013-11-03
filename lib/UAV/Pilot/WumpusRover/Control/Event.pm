package UAV::Pilot::WumpusRover::Control::Event;
use v5.14;
use Moose;
use namespace::autoclean;

use constant CONTROL_UPDATE_TIME => 1 / 60;

extends 'UAV::Pilot::WumpusRover::Control';

has '_packet_queue' => (
    is      => 'ro',
    isa     => 'ArrayRef[UAV::Pilot::WumpusRover::Packet]',
    default => sub { [] },
    traits  => ['Array'],
    handles => {
        _add_to_packet_queue => 'push',
    },
);


sub init_event_loop
{
    my ($self, $cv, $event) = @_;

    my $event_timer; $event_timer = AnyEvent->timer(
        after    => 0.01,
        interval => $self->CONTROL_UPDATE_TIME,
        cb       => sub {
            $self->send_move_packet;
            $event_timer;
        },
    );

    $self->driver->set_ack_callback( sub {
        # TODO
    });

    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

