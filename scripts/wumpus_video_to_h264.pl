#!/usr/bin/perl
use v5.14;
use warnings;
use Digest::Adler32::XS;

use constant VIDEO_MAGIC_NUMBER => 0xFB42;

my $IN_FILE = shift || die "Need file to convert\n";


open( my $in, '<', $IN_FILE ) or die "Can't open $IN_FILE: $!\n";
my @buf;
while( read( $in, my $input, 4096 ) ) {
    push @buf, unpack( 'C*', $input );
}
close $in;


my $frame = 0;
while( @buf ) {
    my $magic = ($buf[0] << 8) | $buf[1];
    die "Bad magic number '$magic'\n" if $magic != VIDEO_MAGIC_NUMBER;

    my $version  = ($buf[2] << 8) | $buf[3];
    my $encoding = ($buf[4] << 8) | $buf[5];
    my @reserved = @buf[6,7,8,9];
    my $width    = ($buf[10] << 8) | $buf[11];
    my $height   = ($buf[12] << 8) | $buf[13];
    my $size     = ($buf[14] << 24)
        | ($buf[15] << 16)
        | ($buf[16] << 8)
        | $buf[17];
    my $checksum = ($buf[18] << 24)
        | ($buf[19] << 16)
        | ($buf[20] << 8)
        | $buf[21];

    my $hex_checksum = sprintf( '%x', $checksum );

    my $data_max_range = 22 + $size - 1;
    my $frame_data = pack( 'C*', @buf[22..$data_max_range] );

    my $digest = Digest::Adler32::XS->new;
    $digest->add( $frame_data );
    my $calc_checksum = $digest->hexdigest;

    warn "Frame num $frame, ${width}x${height}, size $size"
        . ", Got checksum $hex_checksum, Calc checksum $calc_checksum"
        . ", going to $data_max_range\n";
    print $frame_data;
    
    splice @buf, 0, $data_max_range + 1;
    $frame++;
}
