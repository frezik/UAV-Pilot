package UAV::Pilot::Control::ARDrone::SDLNavOutput;
use v5.14;
use Moose;
use namespace::autoclean;
use SDL;
use SDLx::App;
use SDL::Video qw{ :surface :video };

use constant {
    SDL_TITLE  => 'Nav Output',
    SDL_WIDTH  => 480,
    SDL_HEIGHT => 640,
    SDL_DEPTH  => 32,
    SDL_FLAGS  => SDL_HWSURFACE | SDL_HWACCEL | SDL_ANYFORMAT,
    BG_COLOR   => [ 255, 255, 255 ],
};


has 'sdl' => (
    is  => 'ro',
    isa => 'SDLx::App',
);
has '_bg_color' => (
    is  => 'ro',
    isa => 'SDL::Color',
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
    my $bg_color = SDL::Color->new( @bg_color_parts );
    my $bg_rect = SDL::Rect->new( 0, 0, $class->SDL_WIDTH, $class->SDL_HEIGHT );

    $$args{sdl}       = $sdl;
    $$args{_bg_color} = $bg_color;
    $$args{_bg_rect}  = $bg_rect;
    return $args;
}


sub clear_screen
{
    my ($self) = @_;
    SDL::Video::fill_rect(
        $self->sdl,
        $self->_bg_rect,
        $self->_bg_color,
    );
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

