package UAV::Pilot::Control::ARDrone::SDLNavOutput;
use v5.14;
use Moose;
use namespace::autoclean;
use File::Spec;
use SDL;
use SDLx::App;
use SDLx::Text;
use SDL::Event;
use SDL::Events;
use SDL::Video qw{ :surface :video };
use UAV::Pilot;

use constant {
    SDL_TITLE  => 'Nav Output',
    SDL_WIDTH  => 600,
    SDL_HEIGHT => 200,
    SDL_DEPTH  => 24,
    SDL_FLAGS  => SDL_HWSURFACE | SDL_HWACCEL | SDL_ANYFORMAT,
    BG_COLOR   => [ 0,   0,   0   ],
    TEXT_LABEL_COLOR => [ 0,   0,   255 ],
    TEXT_VALUE_COLOR => [ 255, 0,   0   ],
    TEXT_SIZE  => 20,
    TEXT_FONT  => 'typeone.ttf',

    ROLL_LABEL_X      => 50,
    PITCH_LABEL_X     => 150,
    YAW_LABEL_X       => 250,
    ALTITUDE_LABEL_X  => 350,
    BATTERY_LABEL_X   => 450,

    ROLL_VALUE_X      => 50,
    PITCH_VALUE_X     => 150,
    YAW_VALUE_X       => 250,
    ALTITUDE_VALUE_X  => 350,
    BATTERY_VALUE_X   => 450,
};


has 'sdl' => (
    is  => 'ro',
    isa => 'SDLx::App',
);
has '_bg_color' => (
    is  => 'ro',
);
has '_bg_rect' => (
    is  => 'ro',
    isa => 'SDL::Rect',
);
has '_txt_label' => (
    is  => 'ro',
    isa => 'SDLx::Text',
);
has '_txt_value' => (
    is  => 'ro',
    isa => 'SDLx::Text',
);


sub BUILDARGS
{
    my ($class, $args) = @_;
    my @bg_color_parts = @{ $class->BG_COLOR };
    my @txt_color_parts = @{ $class->TEXT_LABEL_COLOR };
    my @txt_value_color_parts = @{ $class->TEXT_VALUE_COLOR };

    my $sdl = SDLx::App->new(
        title  => $class->SDL_TITLE,
        width  => $class->SDL_WIDTH,
        height => $class->SDL_HEIGHT,
        depth  => $class->SDL_DEPTH,
        flags  => $class->SDL_FLAGS,
    );
    $sdl->add_event_handler( sub {
        return 0 if $_[0]->type == SDL_QUIT;
        return 1;
    });

    my $bg_color = SDL::Video::map_RGB( $sdl->format, @bg_color_parts );
    my $bg_rect = SDL::Rect->new( 0, 0, $class->SDL_WIDTH, $class->SDL_HEIGHT );

    my $font_path = File::Spec->catfile(
        UAV::Pilot->default_module_dir,
        $class->TEXT_FONT,
    );
    my $label = SDLx::Text->new(
        font    => $font_path,
        color   => [ @txt_color_parts ],
        size    => $class->TEXT_SIZE,
        h_align => 'center',
    );
    my $value = SDLx::Text->new(
        font    => $font_path,
        color   => [ @txt_value_color_parts ],
        size    => $class->TEXT_SIZE,
        h_align => 'center',       
    );

    $$args{sdl}        = $sdl;
    $$args{_bg_color}  = $bg_color;
    $$args{_bg_rect}   = $bg_rect;
    $$args{_txt_label} = $label;
    $$args{_txt_value} = $value;
    return $args;
}


sub render
{
    my ($self, $nav) = @_;
    $self->_clear_screen;

    $self->_write_label( 'ROLL',     $self->ROLL_LABEL_X,     150 );
    $self->_write_label( 'PITCH',    $self->PITCH_LABEL_X,    150 );
    $self->_write_label( 'YAW',      $self->YAW_LABEL_X,      150 );
    $self->_write_label( 'ALTITUDE', $self->ALTITUDE_LABEL_X, 150 );
    $self->_write_label( 'BATTERY',  $self->BATTERY_LABEL_X,  150 );

    $self->_write_value_float_round( $nav->roll,     $self->ROLL_VALUE_X,     50 );
    $self->_write_value_float_round( $nav->pitch,    $self->PITCH_VALUE_X,    50 );
    $self->_write_value_float_round( $nav->yaw,      $self->YAW_VALUE_X,      50 );
    $self->_write_value( $nav->altitude, $self->ALTITUDE_VALUE_X, 50 );
    $self->_write_value( $nav->battery_voltage_percentage . '%',
        $self->BATTERY_VALUE_X,  50 );

    SDL::Video::update_rects( $self->sdl, $self->_bg_rect );
    return 1;
}


sub _clear_screen
{
    my ($self) = @_;
    SDL::Video::fill_rect(
        $self->sdl,
        $self->_bg_rect,
        $self->_bg_color,
    );
    return 1;
}

sub _write_label
{
    my ($self, $text, $x, $y) = @_;
    my $txt = $self->_txt_label;
    my $app = $self->sdl;

    $txt->write_xy( $app, $x, $y, $text );

    return 1;
}

sub _write_value
{
    my ($self, $text, $x, $y) = @_;
    my $txt = $self->_txt_value;
    my $app = $self->sdl;

    $txt->write_xy( $app, $x, $y, $text );

    return 1;
}

sub _write_value_float_round
{
    my ($self, $text, $x, $y) = @_;
    my $txt = $self->_txt_value;
    my $app = $self->sdl;

    my $rounded = sprintf( '%.2f', $text );

    $txt->write_xy( $app, $x, $y, $rounded );

    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

