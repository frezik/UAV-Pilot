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

sub activate_events
{
    my ($self) = @_;

    foreach my $timer_def (@{ $self->_timers }) {
        my $timer; $timer = AnyEvent->timer(
            after => $timer_def->{time},
            cb    => sub {
                $timer_def->{cb}->();
                $timer_def->{child_events}->activate_events;
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

