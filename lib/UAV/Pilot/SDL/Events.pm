package UAV::Pilot::SDL::Events;
use v5.14;
use Moose;
use namespace::autoclean;
use AnyEvent;
use SDL::Event;
use SDL::Events;

with 'UAV::Pilot::EventHandler';



sub process_events
{
    my ($self) = @_;
    my $event = SDL::Event->new;
    SDL::Events::pump_events();

    while( SDL::Events::poll_event( $event ) ) {
        my $type = $event->type;
        exit 0 if $type == SDL_QUIT;
    }
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME

  UAV::Pilot::SDL::Events

=head1 DESCRIPTION

Handles the SDL event loop in terms of C<UAV::Pilot::Events>.  In 
particular, it automatically handles C<SDL_QUIT> events, which you'll need 
if you open any SDL windows (which 
C<UAV::Pilot::Control::ARDrone::SDLNavOutput> does, for instance).  Without 
that processing, you would need to manually stop the process with C<kill -9> 
or some such.

=cut
