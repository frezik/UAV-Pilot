package UAV::Pilot::REPLCommands;
use v5.14;
use Moose;
use namespace::autoclean;

has 'device' => (
    is  => 'ro',
    isa => 'UAV::Pilot::Device',
);

our $dev;

###
# Commands
###
sub takeoff ()
{
    $dev->takeoff;
}

sub land ()
{
    $dev->land;
}

sub pitch ($)
{
    my ($val) = @_;
    $dev->pitch( $val );
}

sub roll ($)
{
    my ($val) = @_;
    $dev->roll( $val );
}

sub yaw ($)
{
    my ($val) = @_;
    $dev->yaw( $val );
}

sub vert_speed ($)
{
    my ($val) = @_;
    $dev->vert_speed( $val );
}


sub run_cmd
{
    my ($self, $cmd) = @_;
    if( (! defined $self) && (! ref($self)) ) {
        # Must be called with a $self, not directly via package
        return 0;
    }
    return 1 unless defined $cmd;

    $dev = $self->device;
    eval $cmd;
    warn $@ if $@;

    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
