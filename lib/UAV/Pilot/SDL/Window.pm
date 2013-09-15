package UAV::Pilot::SDL::Window;
use v5.14;
use Moose;
use namespace::autoclean;
use SDL::Video qw{ :surface :video };

with 'UAV::Pilot::EventHandler';

use constant {
    SDL_TITLE  => 'UAV::Pilot',
    SDL_WIDTH  => 640,
    SDL_HEIGHT => 200,
    SDL_DEPTH  => 24,
    SDL_FLAGS  => SDL_HWSURFACE | SDL_HWACCEL | SDL_ANYFORMAT,
    BG_COLOR   => [ 0,   0,   0   ],
};


has 'sdl' => (
    is  => 'ro',
    isa => 'SDLx::App',
);
has 'children' => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[HashRef[Item]]',
    default => sub {[]},
    handles => {
        '_add_child' => 'push',
    },
);
has '_origin_x' => (
    is  => 'rw',
    isa => 'Int',
);
has '_origin_y' => (
    is  => 'rw',
    isa => 'Int',
);
has '_drawer' => (
    is  => 'rw',
    isa => 'Maybe[UAV::Pilot::SDL::WindowEventHandler]',
);
has '_bg_color' => (
    is  => 'ro',
);
has '_bg_rect' => (
    is  => 'ro',
    isa => 'SDL::Rect',
);


sub BUILDARGS
{
    my ($class, $args) = @_;
    my @bg_color_parts = @{ $class->BG_COLOR };
    my $sdl = SDLx::App->new(
        title  => $class->SDL_TITLE,
        width  => $class->SDL_WIDTH,
        height => $class->SDL_HEIGHT,
        depth  => $class->SDL_DEPTH,
        flags  => $class->SDL_FLAGS,
    );

    my $bg_color = SDL::Video::map_RGB( $sdl->format, @bg_color_parts );
    my $bg_rect = SDL::Rect->new( 0, 0, $class->SDL_WIDTH, $class->SDL_HEIGHT );

    $$args{sdl}       = $sdl;
    $$args{_bg_color} = $bg_color;
    $$args{_bg_rect}  = $bg_rect;
    return $args;
}


sub add_child
{
    my ($self, $child, $origin_x, $origin_y) = @_;
    $self->_add_child({
        origin_x => $origin_x,
        origin_y => $origin_y,
        drawer   => $child,
    });
}

sub process_events
{
    my ($self) = @_;
    foreach my $child (@{ $self->children }) {
        my $drawer = $child->{drawer};
        $self->_origin_x( $child->{origin_x} );
        $self->_origin_y( $child->{origin_y} );
        $self->_drawer( $drawer );
        $drawer->draw( $self );
    }

    SDL::Video::update_rects( $self->sdl, $self->_bg_rect );
    # Cleanup
    $self->_origin_x( 0 );
    $self->_origin_y( 0 );
    $self->_drawer( undef );
    return 1;
}

sub clear_screen
{
    my ($self) = @_;
    my $drawer = $self->_drawer;
    my $bg_rect = SDL::Rect->new( $self->_origin_x, $self->_origin_y,
        $drawer->width, $drawer->height );
    SDL::Video::fill_rect(
        $self->sdl,
        $bg_rect,
        $self->_bg_color,
    );
    return 1;
}

sub draw_txt
{
    my ($self, $text, $x, $y, $sdl_text) = @_;
    $x += $self->_origin_x;
    $y += $self->_origin_y;
    $sdl_text->write_xy( $self->sdl, $x, $y, $text );
    return 1;
}

sub draw_line
{
    my ($self, $left_coords, $right_coords, $color) = @_;
    $left_coords->[0]  += $self->_origin_x;
    $left_coords->[1]  += $self->_origin_y;
    $right_coords->[0] += $self->_origin_x;
    $right_coords->[1] += $self->_origin_y;

    $self->sdl->draw_line( $left_coords, $right_coords, $color );
    return 1;
}

sub draw_circle
{
    my ($self, $center_coords, $radius, $color ) = @_;
    $center_coords->[0] += $self->_origin_x;
    $center_coords->[1] += $self->_origin_y;
    $self->sdl->draw_circle( $center_coords, $radius, $color );
    return 1;
}

sub draw_rect
{
    my ($self, $rect_data, $color) = @_;
    $rect_data->[0] += $self->_origin_x;
    $rect_data->[1] += $self->_origin_y;
    $self->sdl->draw_rect( $rect_data, $color);
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

