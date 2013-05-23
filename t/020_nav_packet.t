use Test::More tests => 41;
use v5.14;
use warnings;

use UAV::Pilot::Sender::ARDrone::NavPacket;

my $bad_header = make_packet( '55667788' );
eval {
    local $SIG{__WARN__} = sub {}; # Temporarily suppress warnings
    UAV::Pilot::Sender::ARDrone::NavPacket->new({
        packet => $bad_header
    });
};
if( $@ && $@->isa( 'UAV::Pilot::NavPacketException::BadHeader' ) ) {
    pass( 'Caught Bad Header exception' );
    #diag( "Exception message: " . $@->error );
    cmp_ok( $@->got_header, '==', 0x88776655, "BadHeader exception has got_header value" );
}
else {
    fail( 'Did not catch Bad Header exception' );
    fail( 'Fail matching magic number, too [placeholder failure for test count]' );
}


my $packet_data = make_packet( join('',
    # These are in little-endian order
    '88776655',   # Header
    'd004800f',   # Drone state
    '336f0000',   # Sequence number
    '01000000',   # Vision flag
    # No options on this packet besides checksum
    'ffff',       # Checksum ID
    '0800',       # Checksum size
    'c1030000',   # Checksum data
) );
my $packet = UAV::Pilot::Sender::ARDrone::NavPacket->new({
    packet => $packet_data
});
isa_ok( $packet => 'UAV::Pilot::Sender::ARDrone::NavPacket' );

# Header tests
cmp_ok( $packet->header,          '==', 0x55667788, "Header (magic number) parsed" );
cmp_ok( $packet->drone_state,     '==', 0x0f8004d0, "Drone state parsed" );
cmp_ok( $packet->sequence_num,    '==', 0x00006f33, "Sequence number parsed" );
cmp_ok( $packet->vision_flag,     '==', 0x00000001, "Vision flag parsed" );

# Drone state tests.  Numbers before each test are a binary conversion of 0x0f8004d0,
# converted to big endian
#
# 0000
ok(!$packet->state_flying,                        "Flying state" );
ok(!$packet->state_video_enabled,                 "Video Enabled state" );
ok(!$packet->state_vision_enabled,                "Vision Enabled state" );
ok(!$packet->state_control_algorithm,             "Control Algorithm state" );
# 1111
ok( $packet->state_altitude_control_active,       "Altitude Control Active state" );
ok( $packet->state_user_feedback_on,              "User Feedback On state" );
ok( $packet->state_control_received,              "Control Received state" );
ok( $packet->state_trim_received,                 "Trim Received state" );
# 1000
ok( $packet->state_trim_running,                  "Trim Running state" );
ok(!$packet->state_trim_succeeded,                "Trim Succeeded state" );
ok(!$packet->state_nav_data_demo_only,            "Nav Data Demo Only state" );
ok(!$packet->state_nav_data_bootstrap,            "Nav Data Bootstrap state" );
# 0-00 (bit 13 unknown/reserved)
ok(!$packet->state_motors_down,                   "Motors Down state" );
ok(!$packet->state_gyrometers_down,               "Gyrometers Down state" );
ok(!$packet->state_battery_too_low,               "Battery Too Low state" );
# 0000
ok(!$packet->state_battery_too_high,              "Battery Too High state" );
ok(!$packet->state_timer_elapsed,                 "Timer Elapsed state" );
ok(!$packet->state_not_enough_power,              "Not Enough Power state" );
ok(!$packet->state_angles_out_of_range,           "Angles Out of Range state" );
# 0100
ok(!$packet->state_too_much_wind,                 "Too Much Wind state" );
ok( $packet->state_ultrasonic_sensor_deaf,        "Ultrasonic Sensor Deaf state" );
ok(!$packet->state_cutout_system_detected,        "Cutout System Detected state" );
ok(!$packet->state_pic_version_ok,                "PIC Version OK state" );
# 1101
ok( $packet->state_at_coded_thread_on,            "AT Coded Thread On state" );
ok( $packet->state_nav_data_thread_on,            "Nav Data Thread On state" );
ok(!$packet->state_video_thread_on,               "Video Thread On state" );
ok( $packet->state_acquisition_thread_on,         "Acquisition Thread On state" );
# 0000
ok(!$packet->state_control_watchdog_delayed,      "Control Watchdog Delayed state" );
ok(!$packet->state_adc_watchdog_delayed,          "ADC Watchdog Delayed state" );
ok(!$packet->state_communication_problem_occured, "Communication Problem Occured state" );
ok(!$packet->state_emergency,                     "Emergency state" );


# Options test
cmp_ok( $packet->checksum, '==', 0x000003c1, "Checksum parsed" );


# Parsing Demo option
my $demo_packet_data = make_packet( join('',
    '88776655', # Header
    'd004800f', # Drone state
    '346f0000', # Sequence number
    '01000000', # Vision flag
    # Options
    '0000', # Demo ID
    '9400', # Demo Size (148 bytes)
    '00000200', # Control State (landed, flying, hovering, etc.)
    '59000000', # Battery Voltage Filtered (mV? Percentage?)
    'cdcc4cbf', # Pitch (-0.8)
    '00209ec4', # Roll
    '00941a47', # Yaw
    '00000000', # Altitude (cm)
    '00000000', # Estimated linear velocity (x)
    '00000000', # Estimated linear velocity (y)
    '00000000', # Estimated linear velocity (z)
    '00000000', # Streamed Frame Index
    '000000000000000000000000', # Deprecated camera detection params
    '00000000', # Camera Detection, Type of Tag
    '0000000000000000', # Deprecated camera detection params
    # Demo tag is 64 bytes up to here.  The C code for navdata_demo_t struct is done, but 
    # we still have 84 bytes to go . . .
    '0000000000000000',
    '0000000000000000',
    '0000000000000000',
    '0000000003000000',
    '0e4f453fe9fb22bf',
    'e7ffcdbcd111233f',
    '3455453f70f5003c',
    'c67a6b3c9feab4bc',
    '3ee97f3f00000000',
    '0000000000000000',
    '10004801',
    # 148 bytes, end of demo option
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000', '0000',
    '0000', '0000',
    # I guess it really likes sending zeros
    'ffff',     # Checksum ID
    '0800',     # Checksum Length
    '201b0000', # Checksum Data
) );
my $demo_packet = UAV::Pilot::Sender::ARDrone::NavPacket->new({
    packet => $demo_packet_data
});
cmp_ok( $demo_packet->battery_voltage_percentage, '==', 0x59, "Battery volt parsed" );
cmp_ok( $demo_packet->pitch, '==', -0.800000011920929, "Pitch parsed" );



sub make_packet
{
    my ($hex_str) = @_;
    pack 'H*', $hex_str;
}
