use Test::More tests => 5;
use v5.14;
use UAV::Pilot::Video::FileDump;
use File::Temp ();
use Test::Moose;

my ($OUTPUT_FH, $OUTPUT_FILE) = File::Temp::tempfile( 'uav_pilot_file_dump.XXXXXX',
    UNLINK => 1,
);

my $dump = UAV::Pilot::Video::FileDump->new({
    fh => $OUTPUT_FH,
});
isa_ok( $dump => 'UAV::Pilot::Video::FileDump' );
does_ok( $dump => 'UAV::Pilot::Video::H264Handler' );
cmp_ok( $dump->_frame_count, '==', 0, "Frame count is zero" );


$dump->process_h264_frame([ 0x12, 0x34, 0x56, 0x78 ]);
close $OUTPUT_FH;
cmp_ok( (-s $OUTPUT_FILE), '==', 4, "Wrote to output file" );
cmp_ok( $dump->_frame_count, '==', 1, "Frame count incremented" );
