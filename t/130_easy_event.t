use Test::More tests => 8;
use v5.14;
use UAV::Pilot::EasyEvent;
use AnyEvent;

use constant EXPECT_ARG => 42;


my $cv = AnyEvent->condvar;
my $event = UAV::Pilot::EasyEvent->new({
    condvar => $cv,
});
isa_ok( $event => 'UAV::Pilot::EasyEvent' );

my @event_msgs;
my $new_event = $event->add_timer({
    duration       => 100,
    duration_units => $event->UNITS_MILLISECOND,
    cb => sub {
        push @event_msgs => "First event";
    },
});
my $new_event2 = $new_event->add_timer({
    duration => 50,
    duration_units => $event->UNITS_MILLISECOND,
    cb => sub {
        push @event_msgs => "Second event";
    },
});
$new_event2->add_timer({
    duration => 25,
    duration_units => $event->UNITS_MILLISECOND,
    cb => sub {
        push @event_msgs => "Fourth event";
    },
});
$new_event2->add_timer({
    duration => 10,
    duration_units => $event->UNITS_MILLISECOND,
    cb => sub {
        push @event_msgs => "Third event";
    },
});

my $i = 0;
my $did_one_off = 0;
my $timer; $timer = AnyEvent->timer(
    after => 1,
    cb => sub {
        is_deeply(
            \@event_msgs,
            [
                "First event",
                "Second event",
                "Third event",
                "Fourth event",
            ],
        );

        $event->send_event( 'foo_happens' );
        $i = 0;
        $did_one_off = 0;
        $event->send_event( 'foo_happens' );
        $event->send_event( 'foo_happens_with_argument', EXPECT_ARG );
        $cv->send( "End" );
    },
);

$event->add_event( 'foo_happens' => sub {
    cmp_ok( $i, '==', 0, "Foo happened" );
    $i++;
});
$event->add_event( 'foo_happens' => sub {
    cmp_ok( $i, '==', 1, "More foo happened" );
    $i += 2;
    $did_one_off = 1;
}, 1 );
$event->add_event( 'foo_happens' => sub {
    my $expect_i = $did_one_off ? 3 : 1;
    cmp_ok( $i, '==', $expect_i, "Even more foo happened" );
});
$event->add_event( 'foo_happens_with_argument' => sub {
    my ($arg1) = @_;
    cmp_ok( $arg1, '==', EXPECT_ARG, "Foo happened with an argument" );
});

$event->init_event_loop;
$cv->recv;
