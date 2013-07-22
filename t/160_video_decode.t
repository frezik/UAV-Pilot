use Test::More tests => 8;
use v5.14;
use UAV::Pilot;
use UAV::Pilot::Driver::ARDrone::Mock;
use UAV::Pilot::Driver::ARDrone::Video::Mock;
use UAV::Pilot::Control::ARDrone;
use UAV::Pilot::Video::H264Decoder;
use UAV::Pilot::Video::Mock::RawHandler;
use File::Temp ();
use AnyEvent;
use Test::Moose;

use constant VIDEO_DUMP_FILE => 't_data/ardrone_video_stream_dump.bin';
use constant MAX_WAIT_TIME   => 5;


package MockH264Handler;
use Moose;
with 'UAV::Pilot::Video::H264Handler';

has 'real_vid' => (
    is  => 'ro',
    isa => 'UAV::Pilot::Video::H264Decoder',
);

sub process_h264_frame
{
    my ($self, @args) = @_;
    my $real_vid = $self->real_vid;
    $real_vid->process_h264_frame( @args );
    exit 0;

    # Never get here
    return 1;
}


package main;

my $display = UAV::Pilot::Video::Mock::RawHandler->new({
    cb => sub {
        my ($self, $width, $height, $decoder) = @_;
        cmp_ok( $width,  '==', 640, "Width passed" );
        cmp_ok( $height, '==', 360, "Height passed" );

        isa_ok( $decoder => 'UAV::Pilot::Video::H264Decoder' );

        my $pixels = $decoder->get_last_frame_pixels_arrayref;
        cmp_ok( ref($pixels), 'eq', 'ARRAY', "Got array ref of pixels" );
        my $expect_pixels = $width * $height;
        cmp_ok( scalar(@$pixels), '==', $expect_pixels, 
            "Expect ($width * $height) pixels in RGBA format" );
    },
});
my $video = UAV::Pilot::Video::H264Decoder->new({
    display => $display,
});
isa_ok( $video => 'UAV::Pilot::Video::H264Decoder' );
does_ok( $video => 'UAV::Pilot::Video::H264Handler' );

my $cv = AnyEvent->condvar;
my $mock_video = MockH264Handler->new({
    real_vid => $video,
});
my $ardrone = UAV::Pilot::Driver::ARDrone::Mock->new({
    host => 'localhost',
});
my $driver_video = UAV::Pilot::Driver::ARDrone::Video::Mock->new({
    file    => VIDEO_DUMP_FILE,
    handler => $mock_video,
    condvar => $cv,
    driver  => $ardrone,
});
isa_ok( $driver_video => 'UAV::Pilot::Driver::ARDrone::Video' );

my $dev = UAV::Pilot::Control::ARDrone->new({
    sender => $ardrone,
    video  => $driver_video,
});

my $timeout_timer; $timeout_timer = AnyEvent->timer(
    after => MAX_WAIT_TIME,
    cb    => sub {
        fail( 'Did not get a frame after ' . MAX_WAIT_TIME . ' seconds' );
        fail( 'Stub failure for test count matching' ) for 1 .. 4;
        exit 1;

        # Never get here
        $timeout_timer;
    },
);

$driver_video->init_event_loop;
$cv->recv;
