package UAV::Pilot::Sender::ARDrone::NavPacket;
use v5.14;
use Moose;
use namespace::autoclean;

use UAV::Pilot::Sender::ARDrone::NavPacket::Option;
use UAV::Pilot::Exceptions;

use constant { # Values used as Option IDs
    NAVDATA_DEMO           => 0,
    NAVDATA_TIME           => 1,
    NAVDATA_RAW_MEASURES   => 2,
    NAVDATA_PHYS_MEASURES  => 3,
    NAVDATA_GYROS_OFFSETS  => 4,
    NAVDATA_EULER_ANGLES   => 5,
    NAVDATA_REFERNCES      => 6,
    NAVDATA_TRIMS          => 7,
    NAVDATA_RC_REFERENCES  => 8,
    NAVDATA_PWM            => 9,
    NAVDATA_ALTITUDE       => 10,
    NAVDATA_VISION_RAW     => 11,
    NAVDATA_VISION_OF      => 12,
    NAVDATA_VISION         => 13,
    NAVDATA_VISION_PERF    => 14,
    NAVDATA_TRACKERS_SEND  => 15,
    NAVDATA_VISION_DETECT  => 16,
    NAVDATA_WATCHDOG       => 17,
    NAVDATA_ADC_DATA_FRAME => 18,
    NAVDATA_VIDEO_STREAM   => 19,
    NAVDATA_CKS            => 0xffff,
};
use constant { # Bits for the drone state field
    NAVDATA_STATE_FLYING                        => 0,
    NAVDATA_STATE_VIDEO_ENABLED                 => 1,
    NAVDATA_STATE_VISION_ENABLED                => 2,
    NAVDATA_STATE_CONTROL_ALGORITHM             => 3,
    NAVDATA_STATE_ALTITUDE_CONTROL_ACTIVE       => 4,
    NAVDATA_STATE_USER_FEEDBACK_ON              => 5,
    NAVDATA_STATE_CONTROL_RECEIVED              => 6,
    NAVDATA_STATE_TRIM_RECEIVED                 => 7,
    NAVDATA_STATE_TRIM_RUNNING                  => 8,
    NAVDATA_STATE_TRIM_SUCCEEDED                => 9,
    NAVDATA_STATE_NAV_DATA_DEMO_ONLY            => 10,
    NAVDATA_STATE_NAV_DATA_BOOTSTRAP            => 11,
    NAVDATA_STATE_MOTORS_DOWN                   => 12,
    # 13 unknown (reserved for future use?)
    NAVDATA_STATE_GYROMETERS_DOWN               => 14,
    NAVDATA_STATE_BATTERY_TOO_LOW               => 15,
    NAVDATA_STATE_BATTERY_TOO_HIGH              => 16,
    NAVDATA_STATE_TIMER_ELAPSED                 => 17,
    NAVDATA_STATE_NOT_ENOUGH_POWER              => 18,
    NAVDATA_STATE_ANGELS_OUT_OF_RANGE           => 19,
    NAVDATA_STATE_TOO_MUCH_WIND                 => 20,
    NAVDATA_STATE_ULTRASONIC_SENSOR_DEAF        => 21,
    NAVDATA_STATE_CUTOUT_SYSTEM_DETECTED        => 22,
    NAVDATA_STATE_PIC_VERSION_OK                => 23,
    NAVDATA_STATE_AT_CODED_THREAD_ON            => 24,
    NAVDATA_STATE_NAV_DATA_THREAD_ON            => 25,
    NAVDATA_STATE_VIDEO_THREAD_ON               => 26,
    NAVDATA_STATE_ACQUISITION_THREAD_ON         => 27,
    NAVDATA_STATE_CONTROL_WATCHDOG_DELAYED      => 28,
    NAVDATA_STATE_ADC_WATCHDOG_DELAYED          => 29,
    NAVDATA_STATE_COMMUNICATION_PROBLEM_OCURRED => 30,
    NAVDATA_STATE_EMERGENCY                     => 31,
};
use constant EXPECT_HEADER_MAGIC_NUM => 0x55667788;

has 'header' => (
    is  => 'ro',
    isa => 'Int',
);
has 'drone_state' => (
    is  => 'ro',
    isa => 'Int',
);
has 'sequence_num' => (
    is  => 'ro',
    isa => 'Int',
);
has 'vision_flag' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'checksum_id' => (
    is  => 'ro',
    isa => 'Int',
);
has 'checksum_length' => (
    is  => 'ro',
    isa => 'Int',
);
has 'options' => (
    is  => 'ro',
    isa => 'ArrayRef[UAV::Pilot::Sender::ARDrone::NavPacket::Option]',
    default => sub {
        [UAV::Pilot::Sender::ARDrone::NavPacket::Option->new],
    },
);
has 'state_flying' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_video_enabled' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_vision_enabled' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_control_algorithm' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_altitude_control_active' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_user_feedback_on' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_control_received' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_trim_received' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_trim_running' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_trim_succeeded' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_nav_data_demo_only' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_nav_data_bootstrap' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_motors_down' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_gyrometers_down' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_battery_too_low' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_battery_too_high' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_timer_elapsed' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_not_enough_power' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_angles_out_of_range' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_too_much_wind' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_ultrasonic_sensor_deaf' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_cutout_system_detected' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_pic_version_ok' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_at_coded_thread_on' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_nav_data_thread_on' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_video_thread_on' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_acquisition_thread_on' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_control_watchdog_delayed' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_adc_watchdog_delayed' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_communication_problem_occured' => (
    is  => 'ro',
    isa => 'Bool',
);
has 'state_emergency' => (
    is  => 'ro',
    isa => 'Bool',
);


sub BUILDARGS
{
    my ($class, $args) = @_;
    my $packet = $args->{packet};

    my ($header, $state, $seq, $vision_flag) = unpack 'VVVV', $packet;
    UAV::Pilot::NavPacketException::BadHeader->throw(
        error      => "Header '$header' did not match " . $class->EXPECT_HEADER_MAGIC_NUM,
        got_header => $header,
    ) if $class->EXPECT_HEADER_MAGIC_NUM != $header;

    $vision_flag = 1 if $vision_flag;

    my %new_args = (
        header       => $header,
        state        => $state,
        sequence_num => $seq,
        vision_flag  => $vision_flag,
    );
    return \%new_args;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

