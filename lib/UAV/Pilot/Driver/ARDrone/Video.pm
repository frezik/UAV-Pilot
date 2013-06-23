package UAV::Pilot::Driver::ARDrone::Video;
use v5.14;
use Moose;
use namespace::autoclean;
use IO::Socket::INET;
use UAV::Pilot::Driver::ARDrone::VideoHandler;


use constant READ_INTERVAL        => 1 / 15;
use constant BUF_READ_SIZE        => 4096;
use constant BUF_READ_SIZE_HEADER => 128;
use constant PAVE_SIGNATURE       => 'PaVE';

has '_io' => (
    is  => 'ro',
    isa => 'Item',
);
has 'handler' => (
    is  => 'ro',
    isa => 'UAV::Pilot::Driver::ARDrone::VideoHandler',
);
has 'condvar' => (
    is  => 'ro',
    isa => 'AnyEvent::CondVar',
);
has 'driver' => (
    is  => 'ro',
    isa => 'UAV::Pilot::Driver::ARDrone',
);
has 'frames_processed' => (
    traits  => ['Number'],
    is      => 'ro',
    isa     => 'Int',
    default => 0,
    handles => {
        '_add_frames_processed' => 'add',
    },
);


sub BUILDARGS
{
    my ($class, $args) = @_;
    my $io = $class->_build_io( $args );

    $$args{'_io'} = $io;
    delete $$args{'host'};
    delete $$args{'port'};
    return $args;
}


sub init_event_loop
{
    my ($self) = @_;

    my $timer; $timer = AnyEvent->timer(
        after    => 0.1,
        interval => $self->READ_INTERVAL,
        cb       => sub {
            my $packet = $self->_read_frame;
            $self->handler->process_video_frame( $packet ) if %$packet;
            $timer;
        },
    );
    return 1;
}


sub _build_io
{
    my ($class, $args) = @_;
    my $driver = $$args{driver};
    my $host   = $driver->host;
    my $port   = $driver->ARDRONE_PORT_VIDEO_H264;

    my $io = IO::Socket::INET->new(
        PeerAddr  => $host,
        PeerPort  => $port,
        ReuseAddr => 1,
        #Blocking  => 0,
    ) or UAV::Pilot::IOException->throw(
        error => "Could not connect to $host:$port for video: $@",
    );
    return $io;
}

sub _read_frame
{
    my ($self) = @_;
    my $input = $self->_io;
    my $buf;
    $input->blocking( 0 );
    my $got_input = $input->read( $buf, $self->BUF_READ_SIZE_HEADER );
    $input->blocking( 1 );
    return {} if ! $got_input;

    my @bytes = unpack "C*", $buf;

    my %packet;
    $packet{signature}               = pack 'c4', @bytes[0..3];
    $packet{version}                 = $bytes[4];
    $packet{video_codec}             = $bytes[5];
    $packet{packet_size}             = UAV::Pilot->convert_16bit_LE( @bytes[6,7]);
    $packet{payload_size}            = UAV::Pilot->convert_32bit_LE( @bytes[8..11] );
    $packet{encoded_stream_width}    = UAV::Pilot->convert_16bit_LE( @bytes[12,13] );
    $packet{encoded_stream_height}   = UAV::Pilot->convert_16bit_LE( @bytes[14,15] );
    $packet{display_width}           = UAV::Pilot->convert_16bit_LE( @bytes[16,17] );
    $packet{display_height}          = UAV::Pilot->convert_16bit_LE( @bytes[18,19] );
    $packet{frame_number}            = UAV::Pilot->convert_32bit_LE( @bytes[20..23] );
    $packet{timestamp}               = UAV::Pilot->convert_32bit_LE( @bytes[23..26] );
    $packet{total_chunks}            = $bytes[27];
    $packet{chunk_index}             = $bytes[28];
    $packet{frame_type}              = pack 'C', $bytes[29];
    $packet{control}                 = $bytes[30];
    $packet{stream_byte_position_lw} = UAV::Pilot->convert_32bit_LE( @bytes[31..34] );
    $packet{stream_byte_position_uw} = UAV::Pilot->convert_32bit_LE( @bytes[35..38] );
    $packet{stream_id}               = UAV::Pilot->convert_16bit_LE( @bytes[39,40] );
    $packet{total_slices}            = $bytes[41];
    $packet{slice_index}             = $bytes[42];
    $packet{packet1_size}            = $bytes[43];
    $packet{packet2_size}            = $bytes[44];
    $packet{reserved2}               = pack 'C2', @bytes[45,46];
    $packet{advertised_size}         = UAV::Pilot->convert_32bit_LE( @bytes[47..50] );
    $packet{reserved3}               = pack 'C12', @bytes[51..62];
    warn "Bad PaVE signature, got: '$packet{signature}'\n"
        if $self->PAVE_SIGNATURE ne $packet{signature};

    # Might need to reimplement in a non-blocking IO way
    my $payload = $self->_read_frame_payload(
        [@bytes[$packet{packet_size}..$#bytes]] ,
        $input,
        $packet{payload_size}
    );
    $packet{payload} = $payload;
    $self->_add_frames_processed( 1 );
    return \%packet;
}

sub _read_frame_payload
{
    my ($self, $leftover_bytes, $input, $total_size) = @_;
    my @bytes = @$leftover_bytes;
    my $current_size = scalar @bytes;

    my $continue = 1;
    while( ($current_size < $total_size) && $continue ) {
        my $buf;
        my $size_left = $total_size - scalar(@bytes);
        my $buf_size = ($size_left > $self->BUF_READ_SIZE)
            ? $self->BUF_READ_SIZE
            : $size_left;
        my $bytes_recv = $input->read( $buf, $buf_size );
        $continue = 0 if ! $bytes_recv;

        push @bytes, unpack( 'C*', $buf );
        $current_size = scalar @bytes;
    }

    return \@bytes;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

