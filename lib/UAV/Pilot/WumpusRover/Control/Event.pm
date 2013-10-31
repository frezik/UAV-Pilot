package UAV::Pilot::WumpusRover::Control::Event;
use v5.14;
use Moose;
use namespace::autoclean;

use constant CONTROL_UPDATE_TIME => 1 / 60;

extends 'UAV::Pilot::WumpusRover::Control';


sub init_event_loop
{
    my ($self, $cv, $event) = @_;
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

