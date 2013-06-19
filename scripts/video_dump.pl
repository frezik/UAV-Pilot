#!/usr/bin/perl
use v5.14;
use warnings;
use IO::Socket::INET;
use Data::Dumper 'Dumper';

local $Data::Dumper::Sortkeys = 1;

my $HOST = '192.168.1.1';
my $PORT = 5555;
my $FILE = shift;


sub parse_header
{
    my ($packet) = @_;
    my %header;
    my @bytes = unpack "C*", $packet;

    $header{signature}               = pack 'c4', @bytes[0..3];
    $header{version}                 = $bytes[4];
    $header{video_codec}             = $bytes[5];
    $header{header_size}             = convert_16bit_LE( @bytes[6,7]);
    $header{payload_size}            = convert_32bit_LE( @bytes[8..11] );
    $header{encoded_stream_width}    = convert_16bit_LE( @bytes[12,13] );
    $header{encoded_stream_height}   = convert_16bit_LE( @bytes[14,15] ); # here
    $header{display_width}           = convert_16bit_LE( @bytes[16,17] );
    $header{display_height}          = convert_16bit_LE( @bytes[18,19] );
    $header{frame_number}            = convert_32bit_LE( @bytes[20..23] );
    $header{timestamp}               = convert_32bit_LE( @bytes[23..26] );
    $header{total_chunks}            = $bytes[27];
    $header{chunk_index}             = $bytes[28];
    $header{frame_type}              = pack 'C', $bytes[29];
    $header{control}                 = $bytes[30];
    $header{stream_byte_position_lw} = convert_32bit_LE( @bytes[31..34] );
    $header{stream_byte_position_uw} = convert_32bit_LE( @bytes[35..38] );
    $header{stream_id}               = convert_16bit_LE( @bytes[39,40] );
    $header{total_slices}            = $bytes[41];
    $header{slice_index}             = $bytes[42];
    $header{header1_size}            = $bytes[43];
    $header{header2_size}            = $bytes[44];
    $header{reserved2}               = pack 'C2', @bytes[45,46];
    $header{advertised_size}         = convert_32bit_LE( @bytes[47..50] );
    $header{reserved3}               = pack 'C12', @bytes[51..62];

    return \%header;
}

sub convert_32bit_LE
{
    my (@bytes) = @_;
    my $val = $bytes[0]
        | ($bytes[1] << 8)
        | ($bytes[2] << 16)
        | ($bytes[3] << 24);
    return $val;
}

sub convert_16bit_LE
{
    my (@bytes) = @_;
    my $val = $bytes[0] | ($bytes[1] << 8);
    return $val;
}


{
    my $input = undef;
    if( defined $FILE) {
        open( $input, '<', $FILE ) 
            or die "Can't open file for reading: $!\n";
    }
    else {
        $input = IO::Socket::INET->new(
            PeerAddr  => $HOST,
            PeerPort  => $PORT,
        ) or die "Can't open socket to $HOST:$PORT: $!\n";
    }

    my $buf = '';
    my $in = $input->read( $buf, 4096 );
    if( $in ) {
        my $header = parse_header( $buf );
        print Dumper( $header );
    }
    else {
        say "Didn't get a packet\n";
    }

    $input->close;
}
