package UAV::Pilot::Control::ARDrone::Event;
use v5.14;
use Moose;
use namespace::autoclean;
use AnyEvent;

extends 'UAV::Pilot::Control::ARDrone';


sub _init_event_loop
{
    my ($self) = @_;
    my $cv = AnyEvent->condvar;

    my $timer; $timer = AnyEvent->timer(
        after    => 1,
        interval => 1.5,
        cb => sub {
            $self->reset_watchdog;
            $timer;
        },
    );

    return $cv;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

