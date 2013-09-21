use Test::More tests => 1;
use AnyEvent;
use UAV::Pilot::Driver::ARDrone;
use UAV::Pilot::Control::ARDrone;
use UAV::Pilot::EasyEvent;


package MockDriver;
use Moose;

extends 'UAV::Pilot::Driver::ARDrone';

has 'num_read_nav' => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

sub read_nav_packet
{
    my ($self) = @_;
    $self->num_read_nav( $self->num_read_nav + 1 );
    return 1;
}


package main;

my $driver = MockDriver->new;
my $control = UAV::Pilot::Control::ARDrone->new({
    driver => $driver,
});

$control->setup_read_nav_event;

my $read_time = $control->NAV_EVENT_READ_TIME;
my $read_duration = $read_time * 2 + ($read_time / 2);
my $cv = AnyEvent->condvar;
my $timer; $timer = AnyEvent->timer(
    after    => $read_duration,
    cb => sub {
        cmp_ok( $driver->num_read_nav, '==', 2, "Read nav events" );
        $cv->send;
        $timer;
    },
);
$cv->recv;
