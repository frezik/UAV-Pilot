use Test::More tests => 4;
use v5.14;
use UAV::Pilot;
use UAV::Pilot::Driver::ARDrone::Mock;
use UAV::Pilot::Driver::ARDrone::Video::Mock;
use UAV::Pilot::Control::ARDrone;
use UAV::Pilot::Video::H264Decoder;
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
    $self->real_vid->process_h264_frame( @args );
    exit 0;

    # Never get here
    return 1;
}


package MockDisplay;
use Moose;
with 'UAV::Pilot::Video::RawHandler';

sub process_raw_frame
{
    my ($self, $frame) = @_;
    Test::More::pass( "Frame decoded" );
    return 1;
}


package main;

my $display = MockDisplay->new;
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
        exit 1;

        # Never get here
        $timeout_timer;
    },
);

$driver_video->init_event_loop;
$cv->recv;
