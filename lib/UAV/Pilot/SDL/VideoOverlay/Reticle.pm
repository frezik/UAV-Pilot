package UAV::Pilot::SDL::VideoOverlay::Reticle;
use v5.14;
use Moose;
use namespace::autoclean;

use constant RETICLE_COLOR             => [ 0x00, 0xff, 0x00 ];
use constant RETICLE_HALF_SIZE_PERCENT => 0.1; # Takes up x percent of screen size

with 'UAV::Pilot::SDL::VideoOverlay';

has 'reticle_color' => (
    is     => 'ro',
    writer => '_set_reticle_color',
);


after 'init_video_overlay' => sub {
    my ($self, $video, $window) = @_;
    my $sdl = $window->sdl;
    my @color_parts = @{ $self->RETICLE_COLOR };
    my $reticle_color = SDL::Video::map_RGB( $sdl->format, @color_parts );
    $self->_set_reticle_color( $reticle_color );

    return 1;
};


sub process_video_overlay
{
    my ($self, $window) = @_;
    my $sdl               = $window->sdl;
    my $reticle_color     = $self->reticle_color;
    my $half_size_percent = $self->RETICLE_HALF_SIZE_PERCENT;
    # TODO this needs to be based on the rect that the Video is being drawn on
    my $w                 = $sdl->w;
    my $h                 = $sdl->h;
    my $center_x          = int( $w / 2 );
    my $center_y          = int( $h / 2 );

    my $reticle_half_width  = $w * $half_size_percent;
    my $reticle_half_height = $h * $half_size_percent;
    my $left_x   = $center_x - $reticle_half_width;
    my $right_x  = $center_x + $reticle_half_width;
    my $top_y    = $center_y - $reticle_half_height;
    my $bottom_y = $center_y + $reticle_half_height;

    $sdl->draw_line( [$left_x,   $center_y], [$right_x,  $center_y] );
    $sdl->draw_line( [$center_x, $top_y],    [$center_x, $bottom_y] );
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME

  UAV::Pilot::SDL::VideoOverlay::Reticle

=head1 DESCRIPTION

A C<UAV::Pilot::SDL::Overlay> for drawing a targeting reticle in the middle 
of the screen.

=cut
