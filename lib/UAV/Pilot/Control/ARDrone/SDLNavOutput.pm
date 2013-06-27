package UAV::Pilot::Control::ARDrone::SDLNavOutput;
use v5.14;
use Moose;
use namespace::autoclean;
use File::Spec;
use Math::Trig ();
use SDL;
use SDLx::App;
use SDLx::Text;
use SDL::Event;
use SDL::Events;
use SDL::Video qw{ :surface :video };
use UAV::Pilot;
use UAV::Pilot::Driver::ARDrone::NavPacket;

use constant {
    SDL_TITLE  => 'Nav Output',
    SDL_WIDTH  => 600,
    SDL_HEIGHT => 200,
    SDL_DEPTH  => 24,
    SDL_FLAGS  => SDL_HWSURFACE | SDL_HWACCEL | SDL_ANYFORMAT,
    BG_COLOR   => [ 0,   0,   0   ],
    DRAW_VALUE_COLOR        => [ 0x33, 0xff, 0x33 ],
    DRAW_FEEDER_VALUE_COLOR => [ 0x33, 0x33, 0xff ],
    DRAW_CIRCLE_VALUE_COLOR => [ 0xa8, 0xa8, 0xa8 ],
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

    ROLL_DISPLAY_X                 => 50,
    PITCH_DISPLAY_X                => 150,
    YAW_DISPLAY_X                  => 250,
    ALTITUDE_DISPLAY_X             => 350,
    VERT_SPEED_DISPLAY_HALF_HEIGHT => 10,
    VERT_SPEED_DISPLAY_WIDTH       => 10,
    VERT_SPEED_BORDER_WIDTH_MARGIN => 2,
    BATTERY_DISPLAY_X              => 450,

    LINE_VALUE_HALF_MAX_HEIGHT => 10,
    LINE_VALUE_HALF_LENGTH     => 40,

    CIRCLE_VALUE_RADIUS => 40,
    
    BAR_MAX_HEIGHT => 40,
    BAR_WIDTH      => 10,
    BAR_PERCENT_COLOR_GRADIENT => [
        [ '255', '0', '0' ],
        [ '252', '3', '0' ],
        [ '250', '5', '0' ],
        [ '247', '8', '0' ],
        [ '245', '10', '0' ],
        [ '242', '13', '0' ],
        [ '240', '15', '0' ],
        [ '237', '18', '0' ],
        [ '234', '21', '0' ],
        [ '232', '23', '0' ],
        [ '229', '26', '0' ],
        [ '227', '28', '0' ],
        [ '224', '31', '0' ],
        [ '222', '33', '0' ],
        [ '219', '36', '0' ],
        [ '216', '39', '0' ],
        [ '214', '41', '0' ],
        [ '211', '44', '0' ],
        [ '209', '46', '0' ],
        [ '206', '49', '0' ],
        [ '203', '52', '0' ],
        [ '201', '54', '0' ],
        [ '198', '57', '0' ],
        [ '196', '59', '0' ],
        [ '193', '62', '0' ],
        [ '191', '64', '0' ],
        [ '188', '67', '0' ],
        [ '185', '70', '0' ],
        [ '183', '72', '0' ],
        [ '180', '75', '0' ],
        [ '178', '77', '0' ],
        [ '175', '80', '0' ],
        [ '173', '82', '0' ],
        [ '170', '85', '0' ],
        [ '167', '88', '0' ],
        [ '165', '90', '0' ],
        [ '162', '93', '0' ],
        [ '160', '95', '0' ],
        [ '157', '98', '0' ],
        [ '155', '100', '0' ],
        [ '152', '103', '0' ],
        [ '149', '106', '0' ],
        [ '147', '108', '0' ],
        [ '144', '111', '0' ],
        [ '142', '113', '0' ],
        [ '139', '116', '0' ],
        [ '137', '118', '0' ],
        [ '134', '121', '0' ],
        [ '131', '124', '0' ],
        [ '129', '126', '0' ],
        [ '126', '129', '0' ],
        [ '124', '131', '0' ],
        [ '121', '134', '0' ],
        [ '118', '137', '0' ],
        [ '116', '139', '0' ],
        [ '113', '142', '0' ],
        [ '111', '144', '0' ],
        [ '108', '147', '0' ],
        [ '106', '149', '0' ],
        [ '103', '152', '0' ],
        [ '100', '155', '0' ],
        [ '98', '157', '0' ],
        [ '95', '160', '0' ],
        [ '93', '162', '0' ],
        [ '90', '165', '0' ],
        [ '88', '167', '0' ],
        [ '85', '170', '0' ],
        [ '82', '173', '0' ],
        [ '80', '175', '0' ],
        [ '77', '178', '0' ],
        [ '75', '180', '0' ],
        [ '72', '183', '0' ],
        [ '70', '185', '0' ],
        [ '67', '188', '0' ],
        [ '64', '191', '0' ],
        [ '62', '193', '0' ],
        [ '59', '196', '0' ],
        [ '57', '198', '0' ],
        [ '54', '201', '0' ],
        [ '52', '203', '0' ],
        [ '49', '206', '0' ],
        [ '46', '209', '0' ],
        [ '44', '211', '0' ],
        [ '41', '214', '0' ],
        [ '39', '216', '0' ],
        [ '36', '219', '0' ],
        [ '33', '222', '0' ],
        [ '31', '224', '0' ],
        [ '28', '227', '0' ],
        [ '26', '229', '0' ],
        [ '23', '232', '0' ],
        [ '21', '234', '0' ],
        [ '18', '237', '0' ],
        [ '15', '240', '0' ],
        [ '13', '242', '0' ],
        [ '10', '245', '0' ],
        [ '8', '247', '0' ],
        [ '5', '250', '0' ],
        [ '3', '252', '0' ],
        [ '0', '255', '0' ],
    ],
};


with 'UAV::Pilot::SDL::EventHandler';

has 'sdl' => (
    is  => 'ro',
    isa => 'SDLx::App',
);
has 'driver' => (
    is  => 'ro',
    isa => 'UAV::Pilot::Driver',
);
has 'feeder' => (
    is  => 'ro',
    isa => 'Maybe[UAV::Pilot::SDL::NavFeeder]',
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
        my ($event, $app) = @_;
        if( $event->type == SDL_QUIT ) {
            $app->stop;
        }
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

    $self->_write_value_float_round( $nav->roll,     $self->ROLL_VALUE_X,     30 );
    $self->_write_value_float_round( $nav->pitch,    $self->PITCH_VALUE_X,    30 );
    $self->_write_value_float_round( $nav->yaw,      $self->YAW_VALUE_X,      30 );
    $self->_write_value( $nav->altitude . ' cm', $self->ALTITUDE_VALUE_X,     30 );
    $self->_write_value( $nav->battery_voltage_percentage . '%',
        $self->BATTERY_VALUE_X, 30 );

    my $line_color = $self->DRAW_VALUE_COLOR;

    my $feeder = $self->feeder;
    if( defined $feeder) {
        my $feeder_line_color = $self->DRAW_FEEDER_VALUE_COLOR;
        $self->_draw_line_value(   $feeder->cur_roll,  $self->ROLL_DISPLAY_X,  100,
            $feeder_line_color );
        $self->_draw_line_value(   $feeder->cur_pitch, $self->PITCH_DISPLAY_X, 100,
            $feeder_line_color );
        $self->_draw_circle_value( $feeder->cur_yaw,   $self->YAW_DISPLAY_X,   100,
            $feeder_line_color );
        $self->_draw_line_vert_indicator( $feeder->cur_vert_speed,
            $self->ALTITUDE_VALUE_X, 100, $self->VERT_SPEED_DISPLAY_HALF_HEIGHT,
            $self->VERT_SPEED_DISPLAY_WIDTH, $feeder_line_color, $line_color,
            $self->VERT_SPEED_BORDER_WIDTH_MARGIN );
    }

    $self->_draw_line_value(   $nav->roll,    $self->ROLL_DISPLAY_X,  100, $line_color );
    $self->_draw_line_value(   $nav->pitch,   $self->PITCH_DISPLAY_X, 100, $line_color );
    $self->_draw_circle_value( $nav->yaw,     $self->YAW_DISPLAY_X,   100, $line_color );

    # Should we draw anything for altitude?
    $self->_draw_bar_percent_value( $nav->battery_voltage_percentage,
        $self->BATTERY_DISPLAY_X, 100 );

    SDL::Video::update_rects( $self->sdl, $self->_bg_rect );
    return 1;
}

sub process_events
{
    my ($self) = @_;
    my $driver = $self->driver;
    if( $driver->read_nav_packet ) {
        my $nav_packet = $driver->last_nav_packet;
        $self->render( $nav_packet );
    }
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

sub _draw_line_value
{
    my ($self, $value, $center_x, $center_y, $color) = @_;
    my $app = $self->sdl;

    my $y_addition = int( $self->LINE_VALUE_HALF_MAX_HEIGHT * $value );
    my $right_y = $center_y - $y_addition;
    my $left_y  = $center_y + $y_addition;

    my $right_x = $center_x + $self->LINE_VALUE_HALF_LENGTH;
    my $left_x  = $center_x - $self->LINE_VALUE_HALF_LENGTH;

    $app->draw_line( [$left_x, $left_y], [$right_x, $right_y], $color );
    return 1;
}

sub _draw_circle_value
{
    my ($self, $value, $center_x, $center_y) = @_;
    my $app = $self->sdl;
    my $radius = $self->CIRCLE_VALUE_RADIUS;
    my $color  = $self->DRAW_CIRCLE_VALUE_COLOR;

    my $angle  = Math::Trig::pip2 * $value; # Note use of radians, not degrees
    my $line_x = $center_x - (sin($angle) * $radius);
    my $line_y = $center_y - (cos($angle) * $radius);

    $app->draw_circle( [$center_x, $center_y], $radius, $color );
    $app->draw_line( [$center_x, $center_y], [$center_x, $center_y - $radius], $color );

    $app->draw_line( [$center_x, $center_y], [$line_x, $line_y], $self->DRAW_VALUE_COLOR );

    return 1;
}

sub _draw_bar_percent_value
{
    my ($self, $value, $center_x, $center_y) = @_;
    my $app = $self->sdl;
    my $color = $self->BAR_PERCENT_COLOR_GRADIENT->[$value - 1];
    my $half_max_height = $self->BAR_MAX_HEIGHT / 2;
    my $half_width      = $self->BAR_WIDTH / 2;

    my $left_x   = $center_x - $half_width;
    my $right_x  = $center_x + $half_width;
    my $top_y    = $center_y - $half_max_height;
    my $bottom_y = $center_y + $half_max_height;

    my $percentage_height = sprintf( '%.0f', $self->BAR_MAX_HEIGHT * ($value / 100) );
    my $top_percentage_y = $bottom_y - $percentage_height;

    $app->draw_line( $$_[0], $$_[1], $color ) for (
        [ [$left_x, $top_y], [$right_x, $top_y] ],
        [ [$right_x, $top_y], [$right_x, $bottom_y] ],
        [ [$right_x, $bottom_y], [$left_x, $bottom_y] ],
        [ [$left_x, $bottom_y], [$left_x, $top_y] ],
    );
    $app->draw_rect( [ $left_x, $top_percentage_y, $self->BAR_WIDTH, $percentage_height ],
        $color );

    return 1;
}

sub _draw_line_vert_indicator
{
    my ($self, $value, $center_x, $center_y, $half_height, $width, $color, $top_bottom_color, $border_width_margin) = @_;
    my $app = $self->sdl;
    my $half_width = $width / 2;

    my $left_x          = $center_x - $half_width;
    my $right_x         = $center_x + $half_width;
    my $border_left_x   = $left_x   - $border_width_margin;
    my $border_right_x  = $right_x + $border_width_margin;
    my $border_top_y    = $center_y - $half_height;
    my $border_bottom_y = $center_y + $half_height;

    my $indicator_y = $center_y - ($half_height * $value);

    $app->draw_line( [$border_left_x, $border_top_y], [$border_right_x, $border_top_y], 
        $top_bottom_color );
    $app->draw_line( [$border_left_x, $border_bottom_y],
        [$border_right_x, $border_bottom_y], $top_bottom_color );
    $app->draw_line( [$left_x, $indicator_y], [$right_x, $indicator_y], $color );

    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME

  UAV::Pilot::Control::ARDrone::SDLNavOutput

=head1 SYNOPSIS

  my $condvar = AnyEvent->condvar;
  my $sdl_events = UAV::Pilot::SDL::Events->new({
      condvar => $condvar,
  });
  
  my $sdl_nav = UAV::Pilot::Control::ARDrone::SDLNavOutput->new({
      driver => UAV::Pilot::Driver::ARDrone->new( ... ),
  });
  $sdl_events->register( $sdl_nav );

=head1 DESCRIPTION

Graphically renders a C<UAV::Pilot::Driver::ARDrone::NavPacket> using SDL.

It does the C<UAV::Pilot::SDL::EventHandler> role, and thus can be processed by 
C<UAV::Pilot::SDL::Events>.  This is recommended, as C<UAV::Pilot::SDL::Events> will 
take care of the C<SDL_QUIT> events.  Without that, there's no way to stop the process 
other than C<kill -9>.

=head1 METHODS

=head2 new

  new({
      driver => UAV::Pilot::Driver::ARDrone->new( ... ),
  })

Constructor.  The param C<driver> takes a C<UAV::Pilot::Driver::ARDrone> object.

=head2 render

  render( $nav_packet )

Updates the graphic with the given nav packet data.

=cut
