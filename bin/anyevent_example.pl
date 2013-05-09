#!/usr/bin/perl
use v5.14;
use strict;
use warnings;

use AnyEvent;
use UAV::Pilot;
use UAV::Pilot::Sender::ARDrone;
use UAV::Pilot::Device::ARDrone;

# According to SDK docs, smooth flight needs commands sent every 30ms
use constant INT => 1 / 30;
use constant IP  => '192.168.1.1';


my $cv = AE::cv;

my $ardrone = UAV::Pilot::Sender::ARDrone->new({
    host => IP,
});
$ardrone->connect;
my $ar = UAV::Pilot::Device::ARDrone->new({
    sender => $ardrone,
});

$ar->takeoff;

my $t = AE::timer( 5, INT, sub {
    $ar->yaw( -0.5 );
});

AE::timer( 6, 0, sub {
    undef $t;
    my $t2 = AE::timer( 0, INT, sub {
        $ar->yaw( 0.5 );
    });

    AE::timer( 2, 0, sub {
        undef $t2;
        $ar->flip_front;

        AE::timer( 5, 0, sub {
            $ar->land;
            exit;
        });
    });
});

$cv->recv; # Enter main event loop
