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


=head1 NAME

  UAV::Pilot::SDL::Events

=head1 SYNOPSIS

    my $condvar = AnyEvent->condvar;
    my $sdl_events = UAV::Pilot::SDL::Events->new({
        condvar => $condvar,
    });
    $sdl_events->register( ... );
    $sdl_events->start_event_loop;
    $condvar->recv;

=head1 DESCRIPTION

Handles the SDL event loop in terms of C<AnyEvent>.  In particular, it automatically handles 
C<SDL_QUIT> events, which you'll need if you open any SDL windows (which 
C<UAV::Pilot::Control::ARDrone::SDLNavOutput> does, for instance).  Without that processing, 
you would need to manually stop the process with C<kill -9> or some such.

=head1 METHODS

=head2 new

    new({
        condvar => $cv,
    })

Constructor.  The C<condvar> argument is an C<AnyEvent::Condvar>.

=head2 register

    register( $event_handler )

Adds a object that does the C<UAV::Pilot::SDL::EventHandler> role to the list.  The 
C<process_events> method on that object will be called each time the event loop runs.

=head2 start_event_loop

Sets up the event loop.  Note that you must still call C<recv> on the C<AnyEvent::Condvar> 
to start the loop running.

=cut
