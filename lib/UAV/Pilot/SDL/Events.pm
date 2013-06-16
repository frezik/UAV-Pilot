package UAV::Pilot::SDL::Events;
use v5.14;
use Moose;
use namespace::autoclean;
use AnyEvent;
use UAV::Pilot::SDL::EventHandler;
use SDL::Event;
use SDL::Events;


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
            $self->_process_SDL_events;
            $_->process_events for @{ $self->_handlers };
            $timer;
        },
    );

    return 1;
}


sub _process_SDL_events
{
    my ($self) = @_;
    my $event = SDL::Event->new;
    SDL::Events::pump_events();

    while( SDL::Events::poll_event( $event ) ) {
        my $type = $event->type;
        $self->condvar->send if $type == SDL_QUIT;
    }
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

