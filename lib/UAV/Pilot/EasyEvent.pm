package UAV::Pilot::EasyEvent;
use v5.14;
use Moose;
use namespace::autoclean;

#with 'MooseX::Clone';


use constant {
    UNITS_MILLISECOND => 0,
};

has 'condvar' => (
    is  => 'ro',
    isa => 'AnyEvent::CondVar',
);
has '_timers' => (
    traits  => [ 'Array' ],
    is      => 'ro',
    isa     => 'ArrayRef[HashRef[Any]]',
    default => sub { [] },
    handles => {
        _add_timer => 'push',
    },
);
has '_events' => (
    traits  => [ 'Hash' ],
    is      => 'ro',
    isa     => 'HashRef[ArrayRef[Item]]',
    default => sub { {} },
    handles => {
        '_add_event' => 'set',
        '_event_type_exists' => 'exists',
    },
);


sub add_timer
{
    my ($self, $args) = @_;
    my $duration       = $$args{duration};
    my $duration_units = $$args{duration_units};
    my $callback       = $$args{cb};

    my $true_time = $self->_convert_time_units( $duration, $duration_units );
    my $new_self = ref($self)->new({
        condvar => $self->condvar,
    });

    $self->_add_timer({
        time         => $true_time,
        cb           => $callback,
        child_events => $new_self,
    });

    return $new_self;
}

sub add_event
{
    my ($self, $name, $callback) = @_;

    my ($cv, @callbacks);
    if( $self->_event_type_exists( $name ) ) {
        my $event  = $self->_events->{$name};
        $cv        = $event->[0];
        @callbacks = @{ $event->[1] };
    }
    else {
        $cv        = AnyEvent->condvar;
        @callbacks = ();
    }

    push @callbacks, $callback;
    $self->_add_event( $name => [ $cv, \@callbacks ] );

    $cv->cb( sub {
        $_->( $cv ) for @callbacks;
    });
    return 1;
}

sub send_event
{
    my ($self, $name, @args) = @_;
    my $cv = $self->_events->{$name}->[0];
    $cv->send( @args );
    return 1;
}

sub init_event_loop
{
    my ($self) = @_;

    foreach my $timer_def (@{ $self->_timers }) {
        my $timer; $timer = AnyEvent->timer(
            after => $timer_def->{time},
            cb    => sub {
                $timer_def->{cb}->();
                $timer_def->{child_events}->init_event_loop;
                $timer;
            },
        );
    }

    return 1;
}


sub _convert_time_units
{
    my ($self, $time, $unit) = @_;

    if( $self->UNITS_MILLISECOND == $unit ) {
        $time /= 1000;
    }

    return $time;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME

  UAV::Pilot::EasyEvent

=head1 SYNOPSIS

    my $cv = AnyEvent->condvar;
    my $event = UAV::Pilot::EasyEvent->new({
        condvar => $cv,
    });
    
    my @events;
    my $event2 = $event->add_timer({
        duration       => 100,
        duration_units => $event->UNITS_MILLISECOND,
        cb             => sub {
            push @events => 'First event',
        },
    })->add_timer({
        duration       => 10,
        duration_units => $event->UNITS_MILLISECOND,
        cb             => sub {
            push @events => 'Second event',
        },
    });
    
    $event2->add_timer({
        duration       => 50,
        duration_units => $event->UNITS_MILLISECOND,
        cb             => sub {
            push @events => 'Fourth event',
            $cv->send;
        },
    });
    $event2->add_timer({
        duration       => 10,
        duration_units => $event->UNITS_MILLISECOND,
        cb             => sub {
            push @events => 'Third event',
        },
    });
    
    
    $event->init_event_loop;
    $cv->recv;
    
    # After time passes, prints:
    # First event
    # Second event
    # Third event
    # Fourth event
    #
    say $_ for @events;

=head1 DESCRIPTION

C<AnyEvent> is the standard event framework used for C<UAV::Pilot>.  However, its 
interface isn't convenient for some of the typical things done for UAV piloting.  For 
instance, to put the code into plain English, we might want to say:

    Takeoff, wait 5 seconds, then pitch forward for 2 seconds, then pitch backwards 
    for 2 seconds, then land

In the usual C<AnyEvent> interface, this requires building the timers inside the callbacks 
of other timers, which leads to several levels of indentation.  C<UAV::Pilot::EasyEvent> 
simplifies the handling and syntax of this kind of event workflow.

=head1 METHODS

=head2 new

    new({
        condvar => $cv,
    })

Constructor.  The C<condvar> argument should be an C<AnyEvent::CondVar>.

=head2 add_timer

    add_timer({
        duration       => 100,
        duration_units => $event->UNITS_MILLISECOND,
        cb             => sub { ... },
    })

Add a timer to run in the event loop.  It will run after C<duration> units of time, with 
the units specified by C<duration_units>.  The C<cb> parameter is a reference to a 
subroutine to use as a callback.

Returns a child C<EasyEvent> object.  When the timer above has finished, any timers on 
child objects will be setup for execution.  This makes it easy to chain timers to run 
after each other.

=head2 init_event_loop

This method must be called after running a series of C<add_timer()> calls.  You only need 
to call this on the root object, not the children.

You must call C<recv> on the C<condvar> yourself.

=cut
