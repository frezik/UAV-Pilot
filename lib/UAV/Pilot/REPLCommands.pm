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
{
    my @NO_ARG_STRAIGHT_COMMANDS = qw(
        takeoff
        land
        calibrate
        phi_m30
        phi_30
        theta_m30
        theta_30
        theta_20deg_yaw_200
        theta_20deg_yaw_m200
        turnaround
        turnaround_godown
        yaw_shake
        yaw_dance
        phi_dance
        theta_dance
        vz_dance
        wave
        phi_theta_mixed
        double_phi_theta_mixed
        flip_ahead
        flip_behind
        flip_left
        flip_right
        emergency
    );
    foreach my $name (@NO_ARG_STRAIGHT_COMMANDS) {
        no strict 'refs';
        *$name = sub () {
            $dev->$name;
        };
    }
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
