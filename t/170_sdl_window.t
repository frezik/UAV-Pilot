use Test::More;
eval "use SDL;";
plan skip_all => 'SDL not installed' if $@;
plan tests => 13;

eval "use UAV::Pilot::SDL::Window::Mock;"; die $@ if $@;
eval "use UAV::Pilot::SDL::WindowEventHandler;"; die $@ if $@;


package MockWindowEventHandler;
use Moose;

with 'UAV::Pilot::SDL::WindowEventHandler';


sub draw {}


package main;

my $window = UAV::Pilot::SDL::Window::Mock->new;
isa_ok( $window => 'UAV::Pilot::SDL::Window' );
cmp_ok( $window->width,  '==', 0, "No width set on base window" );
cmp_ok( $window->height, '==', 0, "No height set on base window" );


local $TODO = "Not yet implemented";
my $child1 = MockWindowEventHandler->new({
    width  => 1,
    height => 1,
});
$child1->add_to_window( $window );
cmp_ok( $window->width,  '==', 1, "Width set for first child" );
cmp_ok( $window->height, '==', 1, "Height set for first child" );

my $child2 = MockWindowEventHandler->new({
    width  => 2,
    height => 2,
});
$child2->add_to_window( $window, $window->TOP );
cmp_ok( $window->width,  '==', 2, "Width set for second child on top" );
cmp_ok( $window->height, '==', 3, "Height set for second child child on top" );

my $child3 = MockWindowEventHandler->new({
    width  => 3,
    height => 3,
});
$child3->add_to_window( $window, $window->BOTTOM );
cmp_ok( $window->width,  '==', 3, "Width set for third child on top" );
cmp_ok( $window->height, '==', 6, "Height set for third child on top" );

my $child4 = MockWindowEventHandler->new({
    width  => 4,
    height => 4,
});
$child4->add_to_window( $window, $window->LEFT );
cmp_ok( $window->width,  '==', 7, "Width set for fourth child on left" );
cmp_ok( $window->height, '==', 6, "Height set for fourth child on left" );

my $child5 = MockWindowEventHandler->new({
    width  => 5,
    height => 5,
});
$child5->add_to_window( $window, $window->RIGHT );
cmp_ok( $window->width,  '==', 12, "Width set for fifth child on right" );
cmp_ok( $window->height, '==', 6, "Height set for fifth child on right" );
