use Test::More tests => 2;
use v5.14;
use UAV::Pilot::EasyEvent;
use AnyEvent;


my $cv = AnyEvent->condvar;
my $event = UAV::Pilot::EasyEvent->new({
    condvar => $cv,
});
isa_ok( $event => 'UAV::Pilot::EasyEvent' );

my @event_msgs;
$event = $event->after_time({
    duration       => 100,
    duration_units => $event->UNITS_MILLISECOND,
    cb => sub {
        push @event_msgs => "First event";
    },
});
$event = $event->after_time({
    duration => 50,
    duration_units => $event->UNITS_MILLISECOND,
    cb => sub {
        push @event_msgs => "Second event";
    },
})->after_time({
    duration => 25,
    duration_units => $event->UNITS_MILLISECOND,
    cb => sub {
        push @event_msgs => "Third event";
    },
});

my $timer; $timer = AnyEvent->timer(
    after => 1,
    cb => sub {
        local $TODO = "Implement EasyEvent::after_time()";
        is_deeply(
            \@event_msgs,
            [
                "First event",
                "Second event",
                "Third event",
            ],
        );
        $cv->send( "End program" );
    },
);

$event->run;
