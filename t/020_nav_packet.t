use Test::More tests => 43;
use v5.14;
use warnings;

use UAV::Pilot::Sender::ARDrone::NavPacket;

my $bad_header = make_packet( '55667788' );
eval {
    UAV::Pilot::Sender::ARDrone::NavPacket->new({
        packet => $bad_header
    });
};
if( $@ && $@->isa( 'UAV::Pilot::NavPacketException::BadHeader' ) ) {
    pass( 'Caught Bad Header exception' );
    diag( "Exception message: " . $@->error );
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
my ($checksum, @options) = @{ $packet->options };
isa_ok( $checksum => 'UAV::Pilot::Sender::ARDrone::NavPacket::Option' );
cmp_ok( scalar(@options), '==', 0, "Only one option found" );
cmp_ok( $checksum->id,   '==', 0xffff,     "First option ID parsed" );
cmp_ok( $checksum->size, '==', 0x0008,     "First option size parsed" );
cmp_ok( $checksum->data, '==', 0x000003c1, "First option data parsed" );


sub make_packet
{
    my ($hex_str) = @_;
    pack 'H*', $hex_str;
}
