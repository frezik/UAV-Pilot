package UAV::Pilot::Sender::ARDrone;
use v5.14;
use Moose;
use namespace::autoclean;

extends 'UAV::Pilot::Sender';

has 'port' => (
    is  => 'rw',
    isa => 'Int',
);

has 'seq' => (
    is      => 'ro',
    isa     => 'Int',
    default => 0,
    writer  => '__set_seq',
);


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


sub _send_cmd
{
    # TODO
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

