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
use SDL::Overlay;

require DynaLoader;
our @ISA = qw(DynaLoader);
bootstrap UAV::Pilot::SDL::Video;


use constant {
    SDL_TITLE        => 'Video Output',
    SDL_WIDTH        => 640,
    SDL_HEIGHT       => 480,
    SDL_DEPTH        => 32,
    SDL_FLAGS        => SDL_HWSURFACE | SDL_HWACCEL | SDL_ANYFORMAT,
    SDL_OVERLAY_FLAG => SDL_YV12_OVERLAY,
    BG_COLOR         => [ 0, 255, 0 ],
};

with 'UAV::Pilot::Video::RawHandler';
with 'UAV::Pilot::SDL::EventHandler';


has '_last_vid_frame' => (
    is  => 'rw',
    isa => 'Maybe[UAV::Pilot::Video::H264Decoder]',
);

has '_sdl' => (
    is  => 'ro',
    isa => 'SDLx::App',
);
has '_sdl_overlay' => (
    is     => 'ro',
    isa    => 'SDL::Overlay',
    writer => '_set_sdl_overlay',
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

    my $sdl_overlay = SDL::Overlay->new( $class->SDL_WIDTH, $class->SDL_HEIGHT,
        $class->SDL_OVERLAY_FLAG, $sdl );
    my $bg_rect = SDL::Rect->new( 0, 0, $class->SDL_WIDTH, $class->SDL_HEIGHT );
    my $bg_color = SDL::Video::map_RGB( $sdl->format, @bg_color_parts );

    $$args{_sdl}         = $sdl;
    $$args{_sdl_overlay} = $sdl_overlay;
    $$args{_bg_rect}     = $bg_rect;
    $$args{_bg_color}    = $bg_color;
    $$args{_width}       = $class->SDL_WIDTH;
    $$args{_height}      = $class->SDL_HEIGHT;
    return $args;
}


sub process_raw_frame
{
    my ($self, $width, $height, $decoder) = @_;

    if( ($width != $self->_width) || ($height != $self->_height) ) {
        $self->_set_width_height( $width, $height );
    }

    $self->_last_vid_frame( $decoder );
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
    return 1 unless defined $last_vid_frame;

    my $sdl = $self->_sdl;
    my $bg_rect = $self->_bg_rect;
    SDL::Video::fill_rect(
        $sdl,
        $bg_rect,
        $self->_bg_color,
    );

    # Not sure if we need to do this.  SDL_DisplayYUVOverlay() might do it for us.
    #SDL::Video::update_rects( $sdl, $bg_rect );

    $self->_draw_video_frame(
        $self->_sdl_overlay,
        $bg_rect,
        $last_vid_frame->get_last_frame_c_obj,
    );
#    my $overlay = $self->_sdl_overlay;
#    SDL::Video::lock_YUV_overlay( $overlay );
#    # The order of array indexen is correct, according to:
#    # http://dranger.com/ffmpeg/tutorial02.html
#    my $pitches = $overlay->pitches;
#    $$pitches[0] = scalar @{ $last_vid_frame[0] };
#    $$pitches[2] = scalar @{ $last_vid_frame[1] };
#    $$pitches[1] = scalar @{ $last_vid_frame[2] };
#    my $pixels  = $overlay->pixels;
#    $$pixels[0] = $last_vid_frame[0];
#    $$pixels[2] = $last_vid_frame[1];
#    $$pixels[1] = $last_vid_frame[2];
#    SDL::Video::unlock_YUV_overlay( $overlay );

#    SDL::Video::display_YUV_overlay( $sdl, $bg_rect );
    return 1;
}


sub _set_width_height
{
    my ($self, $width, $height) = @_;
    my $sdl         = $self->_sdl;
    my $bg_rect     = SDL::Rect->new( 0, 0, $width, $height );
    my $sdl_overlay = SDL::Overlay->new( $width, $height, $self->SDL_OVERLAY_FLAG, $sdl );

    $self->_set_bg_rect( $bg_rect );
    $self->_set_sdl_overlay( $sdl_overlay );
    $self->_set_width( $width );
    $self->_set_height( $height );

    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

