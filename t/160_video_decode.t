use Test::More tests => 2;
use v5.14;
use UAV::Pilot;
use UAV::Pilot::Driver::ARDrone::Mock;
use UAV::Pilot::Driver::ARDrone::Video::Mock;
use UAV::Pilot::Control::ARDrone;
use UAV::Pilot::Video::H264Decoder;
use File::Temp ();
use AnyEvent;
use Test::Moose;

use constant MAX_WAIT_TIME => 5;


package MockH264Handler;
use Moose;
with 'UAV::Pilot::Video::H264Handler';

has 'last_args' => (
    is      => 'ro',
    isa     => 'ArrayRef[Item]',
    default => sub {[]},
);
has 'cv' => (
    is  => 'ro',
    isa => 'AnyEvent::Condvar',
);

sub process_h264_frame
{
    my ($self, @args) = @_;
    $self->last_args( \@args );
    $cv->send( 1 );
    return 1;
}


package MockDisplay;
use Moose;
with 'UAV::Pilot::Video::DisplayHandler';

sub display_frame
{
    my ($self, $frame) = @_;
    pass( "Frame decoded" );
    return 1;
}


package main;

my $display = Mock::Display->new;
my $video = UAV::Pilot::Video::H264Decoder->new({
    display => $display,
});
isa_ok( $video => 'UAV::Pilot::Video::H264Decoder' );
does_ok( $video => 'UAV::Pilot::Video::H264Handler' );

my $cv = AnyEvent->condvar;
my $mock_video = MockH264Handler->new({
    cv => $cv,
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
        $cv->send( 0 );
        $timeout_timer;
    },
);

$driver_video->init_event_loop;
my $recv = $cv->recv;
exit 0 unless $recv;

my $vid_args = $mock_video->last_args;
my $h264_decoder = $mock_video->process_h264_frame( @$vid_args );
