package UAV::Pilot::SDL::Events;
use v5.14;
use Moose;
use namespace::autoclean;
use AnyEvent;
use UAV::Pilot::SDL::EventHandler;


use constant TIMER_INTERVAL => 1 / 60;


has 'condvar' => (
    is  => 'ro',
    isa => 'AnyEvent::CondVar',
);
has '_handlers' => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[UAV::Pilot::SDL::EventHandler]',
    handles => {
        register => 'push',
    },
);


sub start_event_loop
{
    my ($self) = @_;

    my $timer; $timer = AnyEvent->timer(
        after => 1,
        interval => $self->TIMER_INTERVAL,
        cb       => sub {
            $_->process_events for @{ $self->_handlers };
            $timer;
        },
    );

    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

