package UAV::Pilot::Control::ARDrone::Event;
use v5.14;
use Moose;
use namespace::autoclean;
use AnyEvent;

extends 'UAV::Pilot::Control::ARDrone';

# The AR.Drone SDK manual says sending commands every 30ms is needed for smooth control
use constant CONTROL_TIMING_INTERVAL => 30 / 1000;

has '_cur_pitch' => (
    is      => 'ro',
    isa     => 'Num',
    default => 0,
    writer  => 'pitch',
);
has '_cur_roll' => (
    is      => 'ro',
    isa     => 'Num',
    default => 0,
    writer  => 'roll',
);
has '_cur_yaw' => (
    is      => 'ro',
    isa     => 'Num',
    default => 0,
    writer  => 'yaw',
);
has '_cur_vert_speed' => (
    is      => 'ro',
    isa     => 'Num',
    default => 0,
    writer  => 'vert_speed',
);


sub _init_event_loop
{
    my ($self) = @_;
    $self->$_( 0 ) for qw{
        pitch
        roll
        yaw
        vert_speed
    };

    my $cv = AnyEvent->condvar;

    my $control_timer; $control_timer = AnyEvent->timer(
        after    => 0.1,
        interval => $self->CONTROL_TIMING_INTERVAL,
        cb => sub {
            if( $self->_cur_roll
                || $self->_cur_pitch
                || $self->_cur_vert_speed
                || $self->_cur_yaw
            ) {
                $self->sender->at_pcmd( 1, 0,
                    $self->_cur_roll,
                    $self->_cur_pitch,
                    $self->_cur_vert_speed,
                    $self->_cur_yaw,
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


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

