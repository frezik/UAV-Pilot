use Test::More tests => 3;
use v5.14;
use UAV::Pilot::Events;
use UAV::Pilot::EventHandler;
use AnyEvent;

package __Mock::EventHandler;
use Moose;

has 'condvar' => (
    is  => 'ro',
    isa => 'AnyEvent::CondVar',
);

sub process_events
{
    my ($self) = @_;
    $self->condvar->send( 'Event hit' );
    return 1;
}


package __Mock::Bad;
# Package intentionally left blank



package main;

my $condvar = AnyEvent->condvar;
my $events = UAV::Pilot::Events->new({
    condvar => $condvar,
});
isa_ok( $events => 'UAV::Pilot::Events' );


eval {
    $events->register( __Mock::Bad->new );
};
if( $@ ) {
    pass( 'Did not pass correct object with role EventHandler' );
}
else {
    fail( 'Should have caught error' );
}


my $handler = __Mock::EventHandler->new({
    condvar => $condvar,
});
UAV::Pilot::EventHandler->meta->apply( $handler );
$events->register( $handler );

$events->init_event_loop;
my $got_str = $condvar->recv;
cmp_ok( $got_str, 'eq', 'Event hit', "Event loop ran" );
