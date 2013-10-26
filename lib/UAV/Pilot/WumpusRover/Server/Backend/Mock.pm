package UAV::Pilot::WumpusRover::Server::Backend::Mock;
use v5.14;
use Moose;
use namespace::autoclean;
use UAV::Pilot::WumpusRover::Server::Backend;

with 'UAV::Pilot::WumpusRover::Server::Backend';

has 'started' => (
    is     => 'ro',
    isa    => 'Bool',
    writer => '_set_started',
);

foreach (1..8) {
    my $ch_trim_name = 'ch' . $_ . '_trim';
    my $ch_min_name  = 'ch' . $_ . '_min';
    my $ch_max_name  = 'ch' . $_ . '_max';
    my $ch_out_name  = 'ch' . $_ . '_out';

    has $ch_trim_name => (
        is     => 'ro',
        isa    => 'Maybe[Int]',
        writer => '_set_' . $ch_trim_name,
    );
    has $ch_min_name => (
        is     => 'ro',
        isa    => 'Maybe[Int]',
        writer => '_set_' . $ch_min_name,
    );
    has $ch_max_name => (
        is     => 'ro',
        isa    => 'Maybe[Int]',
        writer => '_set_' . $ch_max_name,
    );
    has $ch_out_name => (
        is     => 'ro',
        isa    => 'Maybe[Int]',
        writer => '_set_' . $ch_out_name,
    );
}


sub _packet_request_startup
{
    my ($self, $packet) = @_;
    $self->_set_started( 1 );
    return 1;
}

sub _packet_radio_trims
{
    my ($self, $packet) = @_;
    foreach (1..8) {
        my $fetch_method = 'ch' . $_ . '_trim';
        my $set_method   = '_set_ch' . $_ . '_trim';
        $self->$set_method( $packet->$fetch_method );
    }
    return 1;
}

sub _packet_radio_mins
{
    my ($self, $packet) = @_;
    foreach (1..8) {
        my $fetch_method = 'ch' . $_ . '_min';
        my $set_method   = '_set_ch' . $_ . '_min';
        $self->$set_method( $packet->$fetch_method );
    }
    return 1;
}

sub _packet_radio_maxes
{
    my ($self, $packet) = @_;
    foreach (1..8) {
        my $fetch_method = 'ch' . $_ . '_max';
        my $set_method   = '_set_ch' . $_ . '_max';
        $self->$set_method( $packet->$fetch_method );
    }
    return 1;
}

sub _packet_radio_out
{
    my ($self, $packet) = @_;
    foreach (1..8) {
        my $fetch_method = 'ch' . $_ . '_out';
        my $set_method   = '_set_ch' . $_ . '_out';
        $self->$set_method( $packet->$fetch_method );
    }
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

