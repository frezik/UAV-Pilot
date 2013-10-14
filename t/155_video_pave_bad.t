use Test::More tests => 1;
use v5.14;
use UAV::Pilot;
use UAV::Pilot::ARDrone::Driver::Mock;
use UAV::Pilot::ARDrone::Video::Mock;
use UAV::Pilot::ARDrone::Control;
use File::Temp ();
use AnyEvent;
use Test::Moose;

use constant VIDEO_DUMP_FILE
    => 't_data/ardrone_video_stream_dump_bad_pave.bin';
use constant MAX_WAIT_TIME           => 2;
use constant EXPECT_FRAMES_PROCESSED => 24;


my $cv = AnyEvent->condvar;
my $ardrone = UAV::Pilot::ARDrone::Driver::Mock->new({
    host => 'localhost',
});
my $driver_video = UAV::Pilot::ARDrone::Video::Mock->new({
    file     => VIDEO_DUMP_FILE,
    condvar  => $cv,
    driver   => $ardrone,
});
my $dev = UAV::Pilot::ARDrone::Control->new({
    driver => $ardrone,
    video  => $driver_video,
});


my $pass_timer; $pass_timer = AnyEvent->timer(
    after    => 1,
    interval => 0.1,
    cb       => sub {
        if( $driver_video->frames_processed == EXPECT_FRAMES_PROCESSED ) {
            pass( 'Expected number of frames processed' );
            $cv->send( 'Pass' );
        }
        $pass_timer;
    },
);
my $timeout_timer; $timeout_timer = AnyEvent->timer(
    after => MAX_WAIT_TIME,
    cb    => sub {
        fail( "Didn't match expected number of frames ["
            . EXPECT_FRAMES_PROCESSED . ']'
            . ' got [' . $driver_video->frames_processed . '] instead' );
        $cv->send( 'Failed' );
        $timeout_timer;
    },
);


$driver_video->init_event_loop;
$cv->recv;
