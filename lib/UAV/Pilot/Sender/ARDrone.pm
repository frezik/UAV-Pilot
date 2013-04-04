package UAV::Pilot::Sender::ARDrone;
use v5.14;
use Moose;
use namespace::autoclean;
use IO::Socket;

use UAV::Pilot::Exceptions;


extends 'UAV::Pilot::Sender';

has 'port' => (
    is  => 'rw',
    isa => 'Int',
);

has 'host' => (
    is  => 'rw',
    isa => 'Str',
);

has 'seq' => (
    is      => 'ro',
    isa     => 'Int',
    default => 0,
    writer  => '__set_seq',
);

has '_socket' => (
    is => 'rw',
);


sub connect
{
    my ($self) = @_;
    my $socket = IO::Socket::INET->new(
        Proto    => 'udp',
        PeerPort => $self->port,
        PeerAddr => $self->host,
    ) or UAV::Pilot::->throw(
        error => 'Could not open socket: ' . $!,
    );
    $self->_socket( $socket );
    return 1;
}

sub at_ref
{
    my ($self, $takeoff, $emergency) = @_;

    # According to the ARDrone developer docs, bits 18, 20, 22, 24, and 28 should be 
    # init'd to one, and all others to zero.  Bit 9 is takeoff, 8 is emergency shutoff.
    my $cmd_number = (1 << 18) 
        | (1 << 20)
        | (1 << 22)
        | (1 << 24)
        | (1 << 28)
        | ($takeoff << 9)
        | ($emergency << 8);

    my $cmd = 'AT*REF=' . $self->_next_seq . ',' . $cmd_number . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}

sub at_pcmd
{
    my ($self, $do_progressive, $do_combined_yaw,
        $roll, $pitch, $vert_speed, $angular_speed) = @_;

    if( ($roll >= 1) || ($roll <= -1) ) {
        UAV::Pilot::NumberOutOfRangeException->throw(
            error => 'Roll should be between 1.0 and -1.0',
        );
    }
    if( ($pitch >= 1) || ($pitch <= -1) ) {
        UAV::Pilot::NumberOutOfRangeException->throw(
            error => 'Pitch should be between 1.0 and -1.0',
        );       
    }
    if( ($vert_speed >= 1) || ($vert_speed <= -1) ) {
        UAV::Pilot::NumberOutOfRangeException->throw(
            error => 'Vertical speed should be between 1.0 and -1.0',
        );       
    }
    if( ($angular_speed >= 1) || ($angular_speed <= -1) ) {
        UAV::Pilot::NumberOutOfRangeException->throw(
            error => 'Angular speed should be between 1.0 and -1.0',
        );       
    }

    my $cmd_number = ($do_progressive << 0)
        | ($do_combined_yaw << 1);

    my $cmd = 'AT*PCMD='
        . join( ',', 
            $self->_next_seq,
            $cmd_number,
            $roll,
            $pitch,
            $vert_speed,
            $angular_speed,
        )
        . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}

sub at_ftrim
{
    my ($self) = @_;

    my $cmd = 'AT*FTRIM=' . $self->_next_seq . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}

sub at_config
{
    my ($self, $name, $value) = @_;

    my $cmd = 'AT*CONFIG=' . $self->_next_seq
        . ',' . qq{"$name"}
        . ',' . qq{"$value"}
        . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}

sub at_config_ids
{
    my ($self, $session_id, $user_id, $app_id) = @_;

    my $cmd = 'AT*CONFIG_IDS=' . $self->_next_seq . ','
        . join( ',',
            $session_id,
            $user_id,
            $app_id,
        )
        . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}

sub at_comwdg
{
    my ($self) = @_;

    my $cmd = 'AT*COMWDG=' . $self->_next_seq . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}

sub at_led
{
    my ($self, $anim_id, $freq, $duration) = @_;

    my $cmd = 'AT*LED=' . $self->_next_seq . ','
        . join(',',
            $anim_id,
            $freq,
            $duration,
        )
        . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}

sub at_anim
{
    my ($self, $anim_id, $duration) = @_;

    my $cmd = 'AT*ANIM=' . $self->_next_seq . ','
        . join(',',
            $anim_id,
            $duration,
        )
        . "\r";
    $self->_send_cmd( $cmd );

    return 1;
}


sub _send_cmd
{
    my ($self, $cmd) = @_;
    $self->_socket->send( $cmd );
    return 1;
}

sub _next_seq
{
    my ($self) = @_;
    my $next_seq = $self->seq + 1;
    $self->__set_seq( $next_seq );
    return $next_seq;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

