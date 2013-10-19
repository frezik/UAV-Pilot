package UAV::Pilot::WumpusRover::Packet;
use v5.14;
use Moose::Role;


use constant _USE_DEFAULT_BUILDARGS => 1;


has 'preamble' => (
    is      => 'rw',
    isa     => 'Int',
    default => 0x3444,
);
has 'version' => (
    is      => 'rw',
    isa     => 'Int',
    default => 0x00,
);
has 'checksum1' => (
    is     => 'ro',
    isa    => 'Int',
    writer => '_set_checksum1',
);
has 'checksum2' => (
    is     => 'ro',
    isa    => 'Int',
    writer => '_set_checksum2',
);
has '_is_checksum_clean' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);
requires 'payload_length';
requires 'message_id';
requires 'payload_fields';
requires 'payload_fields_length';
requires '_encode_payload_for_write';

with 'UAV::Pilot::Logger';


before 'BUILDARGS' => sub {
    my ($class, $args) = @_;
    return $args if delete $args->{fresh};
    return $args unless $class->_USE_DEFAULT_BUILDARGS;

    my $payload = delete $args->{payload};
    my @payload = @$payload;

    my %payload_fields_length = %{ $class->payload_fields_length };
    foreach my $field (@{ $class->payload_fields }) {
        $class->_logger->warn(
            "No entry for '$field' in $class->payload_fields_length"
        ) unless exists $payload_fields_length{$field};
        my $length = $payload_fields_length{$field} // 1;

        my $value = 0;
        foreach (1 .. $length) {
            $value <<= 8;
            $value |= shift @payload;
        }

        $args->{$field} = $value;
    }

    return $args;
};


sub write
{
    my ($self, $fh) = @_;
    $self->_make_checksum_clean;

    my $packet1 = pack 'n C C C',
        $self->preamble,
        $self->payload_length,
        $self->message_id,
        $self->version;
    my $packet2 = $self->_encode_payload_for_write;
    my $packet3 = pack 'C C',
        $self->checksum1,
        $self->checksum2;

    $fh->print( $packet1 );
    $fh->print( $packet2 );
    $fh->print( $packet3 );

    return 1;
}

sub get_ordered_payload_values
{
    my ($self) = @_;
    return map $self->$_, @{ $self->payload_fields };
}

sub get_ordered_payload_value_bytes
{
    my ($self) = @_;
    my @bytes;
    my %payload_fields_length = %{ $self->payload_fields_length };

    foreach my $field (@{ $self->payload_fields }) {
        $self->_logger->warn(
            "No entry for '$field' in $self->payload_fields_length"
        ) unless exists $payload_fields_length{$field};
        my $length = $payload_fields_length{$field} // 1;

        my $raw_value = $self->$field;
        my @raw_bytes;
        foreach (1 .. $length) {
            my $value = $raw_value & 0xFF;
            push @raw_bytes, $value;
            $raw_value >>= 8;
        }

        push @bytes, reverse @raw_bytes;
    }

    return @bytes;
}

sub _calc_checksum
{
    my ($self) = @_;
    my @data = (
        $self->payload_length,
        $self->message_id,
        $self->version,
        $self->get_ordered_payload_value_bytes,
    );

    my ($check1, $check2) = UAV::Pilot->checksum_fletcher8( @data );
    $self->_set_checksum1( $check1 );
    $self->_set_checksum2( $check2 );
    return 1;
}

sub _make_checksum_clean
{
    my ($self) = @_;
    return 1 if $self->_is_checksum_clean;
    $self->_calc_checksum;
    $self->_is_checksum_clean( 1 );
    return 1;
}


sub _make_checksum_unclean
{
    my ($self) = @_;
    $self->_is_checksum_clean( 0 );
    return 1;
}


1;
__END__
