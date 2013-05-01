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

#
# Sole command that can run without loading other libraries
#
sub load ($)
{
    my ($mod_name) = @_;
    $s->load_lib( $mod_name );
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


sub load_lib
{
    my ($self, $mod_name) = @_;
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
