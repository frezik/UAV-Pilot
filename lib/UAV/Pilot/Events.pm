package UAV::Pilot::Events;
use v5.14;
use Moose;
use namespace::autoclean;
use AnyEvent;
use UAV::Pilot::EventHandler;


use constant TIMER_INTERVAL => 1 / 60;


has 'condvar' => (
    is  => 'ro',
    isa => 'AnyEvent::CondVar',
);
has '_handlers' => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[UAV::Pilot::EventHandler]',
    default => sub {[]},
    handles => {
        register => 'push',
    },
);


sub init_event_loop
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


=head1 NAME

  UAV::Pilot::Events

=head1 SYNOPSIS

    my $condvar = AnyEvent->condvar;
    my $events = UAV::Pilot::Events->new({
        condvar => $condvar,
    });
    $events->register( ... );
    $events->init_event_loop;
    $condvar->recv;

=head1 DESCRIPTION

Handles event loops on a regular timer.

=head1 METHODS

=head2 new

    new({
        condvar => $cv,
    })

Constructor.  The C<condvar> argument is an C<AnyEvent::Condvar>.

=head2 register

    register( $event_handler )

Adds a object that does the C<UAV::Pilot::EventHandler> role to the list.  The 
C<process_events> method on that object will be called each time the event loop runs.

=head2 init_event_loop

Sets up the event loop.  Note that you must still call C<recv> on the C<AnyEvent::Condvar> 
to start the loop running.

=cut
