package UAV::Pilot::Control::ARDrone::Event;
use v5.14;
use Moose;
use namespace::autoclean;
use AnyEvent;

extends 'UAV::Pilot::Control::ARDrone';

# The AR.Drone SDK manual says sending commands every 30ms is needed for smooth control
use constant CONTROL_TIMING_INTERVAL => 30 / 1000;

has 'cur_pitch' => (
    is      => 'ro',
    isa     => 'Num',
    default => 0,
    writer  => 'pitch',
);
has 'cur_roll' => (
    is      => 'ro',
    isa     => 'Num',
    default => 0,
    writer  => 'roll',
);
has 'cur_yaw' => (
    is      => 'ro',
    isa     => 'Num',
    default => 0,
    writer  => 'yaw',
);
has 'cur_vert_speed' => (
    is      => 'ro',
    isa     => 'Num',
    default => 0,
    writer  => 'vert_speed',
);

with 'UAV::Pilot::SDL::NavFeeder';



sub init_event_loop
{
    my ($self) = @_;
    $self->hover;

    my $cv = AnyEvent->condvar;

    my $control_timer; $control_timer = AnyEvent->timer(
        after    => 0.1,
        interval => $self->CONTROL_TIMING_INTERVAL,
        cb => sub {
            if( $self->cur_roll
                || $self->cur_pitch
                || $self->cur_vert_speed
                || $self->cur_yaw
            ) {
                $self->driver->at_pcmd( 1, 0,
                    $self->cur_roll,
                    $self->cur_pitch,
                    $self->cur_vert_speed,
                    $self->cur_yaw,
                );
            }

            $control_timer;
        },
    );
    my $comwatch_timer; $comwatch_timer = AnyEvent->timer(
        after    => 1,
        interval => 1.5,
        cb => sub {
            $self->reset_watchdog;
            $comwatch_timer;
        },
    );

    return $cv;
}

sub hover
{
    my ($self) = @_;
    $self->$_( 0 ) for qw{
        pitch
        roll
        yaw
        vert_speed
    };
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME

  UAV::Pilot::Control::ARDrone::Event

=head1 SYNOPSIS

    my $sender = UAV::Pilot::Driver::ARDrone->new( ... );
    $sender->connect;
    my $dev = UAV::Pilot::Control::ARDrone::Event->new({
        sender => $sender,
    });
    
    my $cv = $uav->init_event_loop;
    $cv->pitch( -0.8 );
    $cv->recv; # Will now pitch forward until you kill the process

=head1 DESCRIPTION

AnyEvent-based version of C<UAV::Pilot::Control::ARDrone>.  With the normal module, you 
need to send movement commands yourself every 30ms to maintain smooth control.  By using 
an event loop, this module handles the timing for you.

=head1 METHODS

=head2 init_event_loop

Sets up the event loop and returns the AnyEvent::CondVar.  You will need to call C<recv()> 
on that condvar to start the event loop running.

=head2 hover

Stops all movement.

=cut
