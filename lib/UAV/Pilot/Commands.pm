package UAV::Pilot::Commands;
use v5.14;
use Moose;
use namespace::autoclean;
use File::Spec;

use constant MOD_EXTENSION => '.uav';

has 'device' => (
    is  => 'ro',
    isa => 'UAV::Pilot::Device',
);
has 'lib_dirs' => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    traits  => [ 'Array' ],
    default => sub {[]},
    handles => {
        add_lib_dir => 'push',
    },
);

our ($dev, $s);

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


sub load ($)
{
    my ($mod_name) = @_;
    my @search_dirs = @{ $s->lib_dirs };
    my $mod_file = $mod_name . $s->MOD_EXTENSION;

    my $found = 0;
    foreach my $dir (@search_dirs) {
        my $file = File::Spec->catfile( $dir, $mod_file );
        if( -e $file) {
            $found = 1;
            $s->_compile_mod( $file );
        }
    }

    die "Could not find module named '$mod_name' in search paths ("
        . join( ', ', @search_dirs ) . ")\n"
        if ! $found;

    return $found;
}


sub run_cmd
{
    my ($self, $cmd) = @_;
    if( (! defined $self) && (! ref($self)) ) {
        # Must be called with a $self, not directly via package
        return 0;
    }
    return 1 unless defined $cmd;

    $s   = $self;
    $dev = $self->device;
    eval $cmd;
    die $@ if $@;

    return 1;
}


sub _compile_mod
{
    my ($self, $file) = @_;

    my $input = qq(# line 1 "$file"\n);
    open( my $in, '<', $file ) or die "Can't open <$file> for reading: $!\n";
    while( <$in> ) {
        $input .= $_;
    }
    close $in;

    my $ret = eval $input;
    die $@ if $@;
    die "Parsing <$file> did not return successfully\n" unless $ret;

    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
