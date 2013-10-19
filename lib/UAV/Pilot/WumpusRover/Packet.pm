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
    is  => 'ro',
    isa => 'Int',
);
has 'checksum2' => (
    is  => 'ro',
    isa => 'Int',
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
        my $length = $payload_fields_length{$field} // 0;

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
    return 1;
}

sub get_ordered_payload_values
{
    my ($self) = @_;
    return map $self->$_, @{ $self->payload_fields };
}

sub _calc_checksum
{
    my ($self) = @_;
    my @data = (
        $self->payload_length,
        $self->message_id,
        $self->get_ordered_payload_values,
    );

    return UAV::Pilot->checksum_fletcher8( @data );
}


sub _make_checksum_unclean
{
    my ($self) = @_;
    $self->_is_checksum_clean( 0 );
    return 1;
}


1;
__END__
