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
use UAV::Pilot::SDL::VideoOverlay;

require DynaLoader;
our @ISA = qw(DynaLoader);
bootstrap UAV::Pilot::SDL::Video;


use constant {
    SDL_TITLE        => 'Video Output',
    SDL_WIDTH        => 640,
    SDL_HEIGHT       => 360,
    SDL_DEPTH        => 32,
    SDL_FLAGS        => SDL_HWSURFACE | SDL_HWACCEL | SDL_ANYFORMAT,
    SDL_OVERLAY_FLAG => SDL_YV12_OVERLAY,
    #SDL_OVERLAY_FLAG => SDL_IYUV_OVERLAY,
    #SDL_OVERLAY_FLAG => SDL_YUY2_OVERLAY,
    #SDL_OVERLAY_FLAG => SDL_UYVY_OVERLAY,
    #SDL_OVERLAY_FLAG => SDL_YVYU_OVERLAY,
    #SDL_OVERLAY_FLAG => SDL_YVYU_OVERLAY,
    SDL_RESIZEABLE   => 1,
    BG_COLOR         => [ 0, 255, 0 ],
};

with 'UAV::Pilot::Video::RawHandler';
with 'UAV::Pilot::SDL::EventHandler';


has '_last_vid_frame' => (
    is  => 'rw',
    isa => 'Maybe[UAV::Pilot::Video::H264Decoder]',
);

has 'sdl_app' => (
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
has 'video_overlays' => (
    is      => 'ro',
    isa     => 'ArrayRef[UAV::Pilot::SDL::VideoOverlay]',
    default => sub {[]},
    traits  => [ 'Array' ],
    handles => {
        _add_video_overlay => 'push',
    },
);


sub BUILDARGS
{
    my ($class, $args) = @_;
    my @bg_color_parts = @{ $class->BG_COLOR };

    my $sdl = SDLx::App->new(
        title      => $class->SDL_TITLE,
        width      => $class->SDL_WIDTH,
        height     => $class->SDL_HEIGHT,
        depth      => $class->SDL_DEPTH,
        flags      => $class->SDL_FLAGS,
        resizeable => $class->SDL_RESIZEABLE,
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

    $$args{sdl_app}      = $sdl;
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
    my $sdl = $self->sdl_app;
    SDL::Video::fill_rect(
        $sdl,
        $self->_bg_rect,
        $self->_bg_color,
    );
    my $last_vid_frame = $self->_last_vid_frame;
    return 1 unless defined $last_vid_frame;

    my $bg_rect = $self->_bg_rect;
    SDL::Video::fill_rect(
        $sdl,
        $bg_rect,
        $self->_bg_color,
    );

    $self->_draw_last_video_frame(
        $self->_sdl_overlay,
        $bg_rect,
        $last_vid_frame->get_last_frame_c_obj,
    );

    my @overlays = @{ $self->video_overlays };
    if( @overlays ) {
        foreach my $overlay (@overlays) {
            $overlay->process_video_overlay;
        }
        
        SDL::Video::update_rects( $sdl, $bg_rect );
    }

    return 1;
}

sub register_video_overlay
{
    my ($self, $overlay) = @_;
    $overlay->init_video_overlay( $self );
    $self->_add_video_overlay( $overlay );
    return 1;
}


sub _set_width_height
{
    my ($self, $width, $height) = @_;
    my $sdl         = $self->sdl_app;
    $sdl->resize( $width, $height );
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


=head1 NAME

  UAV::Pilot::SDL::Video

=head1 SYNOPSIS

    my $cv = AnyEvent->condvar;
    my $sdl_events = UAV::Pilot::SDL::Events->new({
        condvar => $cv,
    });
    my $display = UAV::Pilot::SDL::Video->new;
    
    my $video   = UAV::Pilot::Video::H264Decoder->new({
        display => $display,
    });
    
    $sdl_events->register( $display );

=head1 DESCRIPTION

Process raw video frames and displays them to an SDL surface.  This does the roles
C<UAV::Pilot::Video::RawHandler> and C<UAV::Pilot::SDL::EventHandler>.

=head1 METHODS

=head1 register_video_overlay

    register_video_overlay( $overlay )

Adds an object that does the C<UAV::Pilot::SDL::VideoOverlay> role.  This allows an 
object to draw things on top of the video, like telemetry information.

Not to be confused with C<SDL::Overlay>.

=cut
