package UAV::Pilot::SDL::Video;
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
    SDL_TITLE  => 'Video Output',
    SDL_WIDTH  => 640,
    SDL_HEIGHT => 480,
    SDL_DEPTH  => 32,
    SDL_FLAGS  => SDL_HWSURFACE | SDL_HWACCEL | SDL_ANYFORMAT,
    BG_COLOR   => [ 0, 255, 0 ],
};

with 'UAV::Pilot::Video::RawHandler';
with 'UAV::Pilot::SDL::EventHandler';


has '_last_vid_frame' => (
    is  => 'rw',
    isa => 'Maybe[Item]',
);

has '_sdl' => (
    is  => 'ro',
    isa => 'SDLx::App',
);
has '_bg_rect' => (
    is     => 'ro',
    isa    => 'SDL::Rect',
    writer => '_set_bg_rect',
);
has '_bg_color' => (
    is  => 'ro',
);
has '_width' => (
    is     => 'ro',
    isa    => 'Int',
    writer => '_set_width',
);
has '_height' => (
    is     => 'ro',
    isa    => 'Int',
    writer => '_set_height',
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
    $sdl->add_event_handler( sub {
        my ($event, $app) = @_;
        if( $event->type == SDL_QUIT ) {
            $app->stop;
        }
        return 1;
    });
    my $bg_rect = SDL::Rect->new( 0, 0, $class->SDL_WIDTH, $class->SDL_HEIGHT );
    my $bg_color = SDL::Video::map_RGB( $sdl->format, @bg_color_parts );

    $$args{_sdl}        = $sdl;
    $$args{_bg_rect}    = $bg_rect;
    $$args{_bg_color}   = $bg_color;
    $$args{_width}      = $class->SDL_WIDTH;
    $$args{_height}     = $class->SDL_HEIGHT;
    return $args;
}


sub process_raw_frame
{
    my ($self, $pixels, $width, $height) = @_;

    if( ($width != $self->_width) || ($height != $self->_height) ) {
        $self->_set_width_height( $width, $height );
    }

    $self->_last_vid_frame( $pixels );
    return 1;
}

sub process_events
{
    my ($self) = @_;
    SDL::Video::fill_rect(
        $self->_sdl,
        $self->_bg_rect,
        $self->_bg_color,
    );
    my $last_vid_frame = $self->_last_vid_frame;
    #return 1 unless $self->_last_vid_frame;

    my $sdl = $self->_sdl;
    my $bg_rect = $self->_bg_rect;
    SDL::Video::fill_rect(
        $sdl,
        $bg_rect,
        $self->_bg_color,
    );

    #my $pixels = $sdl->get_pixels_ptr;
    #$pixels = pack 'L*', @$last_vid_frame;

    SDL::Video::update_rects( $sdl, $bg_rect );
    return 1;
}


sub _set_width_height
{
    my ($self, $width, $height) = @_;
    my $bg_rect = SDL::Rect->new( 0, 0, $width, $height );

    $self->_set_bg_rect( $bg_rect );
    $self->_set_width( $width );
    $self->_set_height( $height );

    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

