package UAV::Pilot::SDL::Window::Mock;
use v5.14;
use Moose;
use namespace::autoclean;

extends 'UAV::Pilot::SDL::Window';

has 'sdl' => (
    is  => 'rw',
    isa => 'MockSDL',
);


sub BUILDARGS
{
    my ($class, $args) = @_;
    my $sdl = MockSDL->new;
    $$args{sdl} = $sdl;
    return $args;
}

sub process_events
{
    # Do nothing, so nothing is ever drawn
}


no Moose;
__PACKAGE__->meta->make_immutable;


package MockSDL;
use Moose;

sub resize {} # ignore

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

