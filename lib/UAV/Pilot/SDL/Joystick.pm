package UAV::Pilot::SDL::Joystick;
use v5.14;
use Moose;
use namespace::autoclean;
use SDL;
use SDL::Joystick;
use File::HomeDir;
use YAML ();

SDL::init_sub_system( SDL_INIT_JOYSTICK );

use constant MAX_AXIS_INT      => 32767;
use constant TIMER_INTERVAL    => 1 / 60;
use constant DEFAULT_CONF_FILE => 'sdl_joystick.yml';
use constant DEFAULT_CONF      => {
    joystick_num  => 0,
    roll_axis     => 0,
    pitch_axis    => 1,
    yaw_axis      => 2,
    throttle_axis => 3,
    takeoff_btn   => 0,
};


with 'UAV::Pilot::SDL::EventHandler';

has 'condvar' => (
    is  => 'ro',
    isa => 'AnyEvent::CondVar',
);
has 'joystick_num' => (
    is      => 'ro',
    isa     => 'Int',
    default => 0,
);
has 'roll_axis' => (
    is      => 'ro',
    isa     => 'Int',
    default => 0,
);
has 'pitch_axis' => (
    is      => 'ro',
    isa     => 'Int',
    default => 1,
);
has 'yaw_axis' => (
    is      => 'ro',
    isa     => 'Int',
    default => 2,
);
has 'throttle_axis' => (
    is      => 'ro',
    isa     => 'Int',
    default => 3,
);
has 'takeoff_btn' => (
    is      => 'ro',
    isa     => 'Int',
    default => 0, 
);
has 'is_in_air' => (
    traits  => ['Bool'],
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
    handles => {
        toggle_is_in_air => 'toggle',
        set_is_in_air    => 'set',
        unset_is_in_air  => 'unset',
    },
);
has 'controller' => (
    is  => 'ro',
    isa => 'UAV::Pilot::Control',
);
has 'joystick' => (
    is  => 'ro',
    isa => 'SDL::Joystick',
);
has '_prev_takeoff_btn_status' => (
    is  => 'rw',
    isa => 'Bool',
);


sub BUILDARGS
{
    my ($self, $args) = @_;
    my $new_args = $self->_process_args( $args );

    my $joystick = SDL::Joystick->new( $new_args->{joystick_num} );
    die "Could not open joystick $$new_args{joystick_num}\n" unless $joystick;
    $new_args->{joystick} = $joystick;

    return $new_args;
}


sub process_events
{
    my ($self) = @_;
    SDL::Joystick::update();
    my $joystick = $self->joystick;
    my $dev = $self->controller;

    my $roll = $self->_sdl_axis_to_float( $joystick->get_axis(
        $self->roll_axis ) );
    my $pitch = $self->_sdl_axis_to_float( $joystick->get_axis(
        $self->pitch_axis ) );
    my $yaw = $self->_sdl_axis_to_float( $joystick->get_axis(
        $self->yaw_axis ) );
    my $throttle = - $self->_sdl_axis_to_float( $joystick->get_axis(
        $self->throttle_axis ) );
    my $takeoff_btn = $joystick->get_button( $self->takeoff_btn );

    # Only takeoff/land after we let off the button
    if( $self->_prev_takeoff_btn_status && ($takeoff_btn == 0) ) {
        if( $self->is_in_air ) {
            $self->unset_is_in_air;
            $dev->land;
        }
        else {
            $self->set_is_in_air;
            $dev->takeoff;
        }
    }
    $self->_prev_takeoff_btn_status( $takeoff_btn );

    $dev->roll( $roll );
    $dev->pitch( $pitch );
    $dev->yaw( $yaw );
    $dev->vert_speed( $throttle );

    return 1;
}

sub close
{
    my ($self) = @_;
    $self->joystick->close;
    return 1;
}


sub _sdl_axis_to_float
{
    my ($self, $num) = @_;
    my $float = $num / $self->MAX_AXIS_INT;
    $float = 1.0 if $float > 1.0;
    $float = -1.0 if $float < -1.0;
    return $float;
}

sub _process_args
{
    my ($self, $args) = @_;
    my $conf_dir = UAV::Pilot->default_config_dir;
    my $conf_path = File::Spec->catfile( $conf_dir, $self->DEFAULT_CONF_FILE );
    my $conf_args = $self->_get_conf( $conf_path );

    my %new_args = (
        %$conf_args,
        condvar      => $args->{condvar},
        controller   => $args->{controller},
    );
    return \%new_args;
}

sub _get_conf
{
    my ($self, $conf_path) = @_;
    YAML::DumpFile( $conf_path, $self->DEFAULT_CONF ) unless -e $conf_path;
    my $conf = YAML::LoadFile( $conf_path );
    return $conf;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

