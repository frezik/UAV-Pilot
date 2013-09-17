package UAV::Pilot::SDL::Window::Mock;
use v5.14;
use Moose;
use namespace::autoclean;

extends 'UAV::Pilot::SDL::Window';


sub BUILDARGS
{
    # Do nothing, so the parent's SDLx::App is never created
}

sub process_events
{
    # Do nothing, so nothing is ever drawn
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

