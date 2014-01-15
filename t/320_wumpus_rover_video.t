use Test::More; # Set test plan below
use v5.14;
use UAV::Pilot;
use UAV::Pilot::WumpusRover::Driver::Mock;
use UAV::Pilot::WumpusRover::Video::Mock;
use UAV::Pilot::Video::FileDump;
use File::Temp ();
use AnyEvent;
use Test::Moose;

use constant VIDEO_DUMP_FILE         => 't_data/wumpus_video_stream_dump.gdp';
use constant MAX_WAIT_TIME           => 5;
use constant EXPECT_FRAMES_PROCESSED => 25;
use constant EXPECT_SIZE             => 98_304;

my $GSTREAMER = $ENV{GST_LAUNCH_PATH} // `which gst-launch-1.0`;
if( $GSTREAMER ) {
    plan tests => 4;
}
else {
    plan skip_all => "Need GStreamer installed with gst-launch-1.0."
        . "  (Can set path to gst-launch-1.0 in GST_LAUNCH_PATH environment"
        . " variable.)";
}

my ($OUTPUT_FH, $OUTPUT_FILE) = File::Temp::tempfile( 'wumpus_video_stream.h264.XXXXXX',
    UNLINK => 1,
);


my $control_video = UAV::Pilot::Video::FileDump->new({
    fh => $OUTPUT_FH,
});
does_ok( $control_video => 'UAV::Pilot::Video::H264Handler' );

my $cv = AnyEvent->condvar;
my $wumpus = UAV::Pilot::WumpusRover::Driver::Mock->new({
    host => 'localhost',
});
my $driver_video = UAV::Pilot::WumpusRover::Video::Mock->new({
    file       => VIDEO_DUMP_FILE,
    handlers   => [ $control_video ],
    condvar    => $cv,
    driver     => $wumpus,
    gstreammer => 
});
isa_ok( $driver_video => 'UAV::Pilot::WumpusRover::Video' );



my $pass_timer; $pass_timer = AnyEvent->timer(
    after    => 1,
    interval => 0.1,
    cb       => sub {
        my $pass = (EXPECT_SIZE == -s $OUTPUT_FILE);
        if( EXPECT_SIZE == -s $OUTPUT_FILE ) {
            pass( 'File '
                . $OUTPUT_FILE
                . ' matches expected size '
                . EXPECT_SIZE );
            $cv->send( 'Pass' );
        }
        $pass_timer;
    },
);
my $timeout_timer; $timeout_timer = AnyEvent->timer(
    after => MAX_WAIT_TIME,
    cb    => sub {
        fail( 'File '
            . $OUTPUT_FILE
            . ' did not match expected size '
            . EXPECT_SIZE
            . ' after '
            . MAX_WAIT_TIME
            . ' seconds.'
            . '  Actual size is '
            . (-s $OUTPUT_FILE)
            . '.' );
        $cv->send( 'Failed' );
        $timeout_timer;
    },
);


$driver_video->init_event_loop;
$cv->recv;

cmp_ok( $driver_video->frames_processed, '==', EXPECT_FRAMES_PROCESSED,
    'Expected number of frames processed' );


close $OUTPUT_FH;
