package UAV::Pilot::Control::ARDrone::SDLNavOutput;
use v5.14;
use Moose;
use namespace::autoclean;
use SDL;
use SDLx::App;
use SDLx::Text;
use SDL::Event;
use SDL::Events;
use SDL::Video qw{ :surface :video };

use constant {
    SDL_TITLE  => 'Nav Output',
    SDL_WIDTH  => 600,
    SDL_HEIGHT => 200,
    SDL_DEPTH  => 24,
    SDL_FLAGS  => SDL_HWSURFACE | SDL_HWACCEL | SDL_ANYFORMAT,
    BG_COLOR   => [ 255, 255, 255 ],
    TEXT_COLOR => [ 0,   0,   255 ],
    TEXT_SIZE  => 20,
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
has '_label' => (
    is  => 'ro',
    isa => 'SDLx::Text',
);


sub BUILDARGS
{
    my ($class, $args) = @_;
    my @bg_color_parts = @{ $class->BG_COLOR };
    my @txt_color_parts = @{ $class->TEXT_COLOR };

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

    my $bg_color = SDL::Color->new( @bg_color_parts );
    my $bg_rect = SDL::Rect->new( 0, 0, $class->SDL_WIDTH, $class->SDL_HEIGHT );

    my $label = SDLx::Text->new(
        color   => [ @txt_color_parts ],
        size    => $class->TEXT_SIZE,
        h_align => 'center',
    );

    $$args{sdl}       = $sdl;
    $$args{_bg_color} = $bg_color;
    $$args{_bg_rect}  = $bg_rect;
    $$args{_label}    = $label;
    return $args;
}


sub render
{
    my ($self, $nav) = @_;
    $self->_clear_screen;

    $self->_write_label( 'ROLL',     50,  150  );
    $self->_write_label( 'PITCH',    150, 150 );
    $self->_write_label( 'YAW',      250, 150 );
    $self->_write_label( 'ALTITUDE', 350, 150 );
    $self->_write_label( 'BATTERY',  450, 150 );

    SDL::Video::update_rects( $self->sdl, $self->_bg_rect );
    return 1;
}
sub draw_new_frame
{
    my ($self, $callback) = @_;
    $self->_clear_screen;
    $callback->($self);
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
    my $label = $self->_label;
    my $app   = $self->sdl;

    $label->write_xy( $app, $x, $y, $text );

    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

