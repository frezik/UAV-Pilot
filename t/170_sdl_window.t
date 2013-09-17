use Test::More;
eval "use SDL;";
plan skip_all => 'SDL not installed' if $@;
plan tests => 1;

eval "use UAV::Pilot::SDL::Window::Mock;"; die $@ if $@;
eval "use UAV::Pilot::SDL::WindowEventHandler;"; die $@ if $@;


package MockWindowEventHandler;
use Moose;

with 'UAV::Pilot::SDL::WindowEventHandler';


sub draw {}


package main;

pass( "Placeholder test" );
