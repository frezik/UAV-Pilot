package UAV::Pilot::WumpusRover::Video;
use v5.14;
use warnings;
use Moose;
use namespace::autoclean;
use Net::RTP::Packet;
use UAV::Pilot::Exceptions;
use UAV::Pilot::Video::H264Handler;

use constant GSTREAMER_END_CMD => [ 'gdpdepay', '!', 'fdsink' ];


with 'UAV::Pilot::Logger';

has 'handlers' => (
    traits  => ['Array'],
    is      => 'rw',
    isa     => 'ArrayRef[UAV::Pilot::Video::H264Handler]',
    default => sub {[]},
    handles => {
        'add_handler' => 'push',
    },
);
has 'condvar' => (
    is  => 'ro',
    isa => 'AnyEvent::CondVar',
);
has 'driver' => (
    is  => 'ro',
    isa => 'UAV::Pilot::WumpusRover::Driver',
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
has '_gstreamer' => (
    is  => 'ro',
    isa => 'ArrayRef[Str]',
);
has '_io' => (
    is     => 'ro',
    isa    => 'Item',
    writer => '_set_io',
);



sub BUILDARGS
{
    my ($class, $args) = @_;
    my $gstreamer = delete $args->{gstreamer};
    my $driver    = $args->{driver};

    my @full_gstreamer_cmd = (
        $gstreamer,
        $class->_make_gstreamer_connection_cmd( $args ),
        '!',
        @{ $class->GSTREAMER_END_CMD },
    );
    $args->{'_gstreamer'} = \@full_gstreamer_cmd;
    my $raw_gstreamer_cmd = join ' ', @full_gstreamer_cmd;
    $class->_logger->info( 'GStreamer command: ' . $raw_gstreamer_cmd );

    open( my $gstreamer_in, '-|', @full_gstreamer_cmd )
        or UAV::Pilot::CommandNotFoundException->throw({
            cmd => $raw_gstreamer_cmd,
        });
    $args->{'_io'} = $gstreamer_in;

    return $args;
}

sub init_event_loop
{
    my ($self) = @_;

    my $io_event; $io_event = AnyEvent->io(
        fh   => $self->_io,
        poll => 'r',
        cb   => sub {
            $self->_process_io;
            $io_event;
        },
    );
    return 1;
}


sub _process_io
{
    my ($self) = @_;
    my $gstreamer_in = $self->_io;
    return 1;
}

sub _make_gstreamer_connection_cmd
{
    my ($class, $args) = @_;
    my $driver = $args->{driver};

    my $cmd = 'tcpclientsrc'
        . ' host=' . $driver->host
        . ' port=' . UAV::Pilot::WumpusRover::DEFAULT_VIDEO_PORT;
    return $cmd,
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

