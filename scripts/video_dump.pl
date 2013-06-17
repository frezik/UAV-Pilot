#!/usr/bin/perl
use v5.14;
use warnings;
use IO::Socket::INET;
use Data::Dumper 'Dumper';

local $Data::Dumper::Sortkeys = 1;

my $HOST = '192.168.1.1';
my $PORT = 5555;


sub parse_header
{
    my ($packet) = @_;
    my %header;
    my @bytes = unpack "C*", $packet;

    $header{signature}               = pack 'c4', @bytes[0..3];
    $header{version}                 = $bytes[4];
    $header{video_codec}             = convert_16bit( @bytes[5,6] );
    $header{payload_size}            = convert_32bit( @bytes[7..10] );
    $header{encoded_stream_width}    = convert_16bit( @bytes[11,12] );
    $header{encoded_stream_height}   = convert_16bit( @bytes[13,14] );
    $header{display_width}           = convert_16bit( @bytes[15,16] );
    $header{display_height}          = convert_16bit( @bytes[17,18] );
    $header{timestamp}               = convert_32bit( @bytes[19..22] );
    $header{total_chunks}            = $bytes[23];
    $header{chunk_index}             = $bytes[24];
    $header{frame_type}              = $bytes[25];
    $header{control}                 = $bytes[26];
    $header{stream_byte_position_lw} = convert_32bit( @bytes[27..30] );
    $header{stream_byte_position_uw} = convert_32bit( @bytes[31..34] );
    $header{stream_id}               = convert_16bit( @bytes[35,36] );
    $header{total_slices}            = $bytes[37];
    $header{slice_index}             = $bytes[38];
    $header{header1_size}            = $bytes[39];
    $header{header2_size}            = $bytes[40];
    $header{reserved2}               = pack 'c2', @bytes[41,42];
    $header{advertised_size}         = convert_32bit( @bytes[43..46] );
    $header{reserved3}               = pack 'c12', @bytes[47..58];

    return \%header;
}

sub convert_32bit
{
    my (@bytes) = @_;
    my $val = $bytes[3]
        | ($bytes[2] << 8)
        | ($bytes[1] << 16)
        | ($bytes[0] << 24);
    return $val;
}

sub convert_16bit
{
    my (@bytes) = @_;
    my $val = $bytes[1] | ($bytes[0] << 8);
    return $val;
}


{
    my $socket = IO::Socket::INET->new(
        PeerAddr  => $HOST,
        PeerPort  => $PORT,
    ) or die "Can't open socket to $HOST:$PORT: $!\n";

    my $buf = '';
    my $in = $socket->read( $buf, 4096 );
    if( $in ) {
        my $header = parse_header( $buf );
        print Dumper( $header );
    }
    else {
        say "Didn't get a packet\n";
    }

    $socket->close;
}
