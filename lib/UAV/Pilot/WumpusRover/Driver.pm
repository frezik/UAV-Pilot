package UAV::Pilot::WumpusRover::Driver;
use v5.14;
use Moose;
use namespace::autoclean;
use UAV::Pilot::WumpusRover::PacketFactory;

has 'port' => (
    is      => 'ro',
    isa     => 'Int',
    default => 45000,
);
# Create channel fields and setters, numbered 1 through 8
foreach (1..8) {
    my $field = 'ch' . $_;
    my $set_method = 'set_ch' . $_;
    has $field => (
        is     => 'ro',
        isa    => 'Int',
        writer => $set_method,
    );

    after $set_method => sub {
        my ($self) = @_;
        $self->_send_radio_output_packet;
    };
}

with 'UAV::Pilot::Driver';
with 'UAV::Pilot::Logger';


sub connect
{
    my ($self) = @_;
    $self->_init_connection;

    my $startup_request = UAV::Pilot::WumpusRover::PacketFactory->fresh_packet(
        'RequestStartupMessage' );
    $startup_request->system_type( 0x00 );
    $startup_request->system_id( 0x01 );
    $startup_request->make_checksum_clean;
    $self->_send_packet( $startup_request );

    return 1;
}


sub _init_connection
{
    my ($self) = @_;
    # TODO
    return 1;
}

sub _send_packet
{
    my ($self) = @_;
    # TODO
    return 1;
}

sub _send_radio_output_packet
{
    my ($self) = @_;
    my $radio_packet = UAV::Pilot::WumpusRover::PacketFactory->fresh_packet(
        'RadioOutputs' );

    foreach my $i (1..8) {
        my $field = 'ch' . $i;
        my $packet_field = 'ch' . $i . '_out';
        next unless defined $self->$field;
        $radio_packet->$packet_field( $self->$field );
    }

    $radio_packet->make_checksum_clean;
    $self->_send_packet( $radio_packet );
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

