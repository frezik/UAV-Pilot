package UAV::Pilot::Commands;
use v5.14;
use Moose;
use namespace::autoclean;
use File::Spec;

use constant MOD_EXTENSION => '.uav';

has 'device' => (
    is   => 'ro',
    does => 'UAV::Pilot::Device',
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
sub load ($;$)
{
    my ($mod_name, $args) = @_;
    $s->load_lib( $mod_name, $args );
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
    my ($self, $mod_name, $args) = @_;
    my @search_dirs = @{ $self->lib_dirs };
    my $mod_file = $mod_name . $self->MOD_EXTENSION;

    my $found = 0;
    foreach my $dir (@search_dirs) {
        my $file = File::Spec->catfile( $dir, $mod_file );
        if( -e $file) {
            $found = 1;
            $self->_compile_mod( $file, $args );
        }
    }

    die "Could not find module named '$mod_name' in search paths ("
        . join( ', ', @search_dirs ) . ")\n"
        if ! $found;

    return $found;
}

sub _compile_mod
{
    my ($self, $file, $args) = @_;
    my $pack = delete $$args{namespace};

    my $input = defined($pack)
        ? qq{package $pack;\n}
        : '';
    $input .= qq(# line 1 "$file"\n);
    open( my $in, '<', $file ) or die "Can't open <$file> for reading: $!\n";
    while( <$in> ) {
        $input .= $_;
    }
    close $in;

    my $ret = eval $input;
    die $@ if $@;
    die "Parsing <$file> did not return successfully\n" unless $ret;

    $pack = ref($self) unless defined $pack;
    if( my $call = $pack->can( 'uav_module_init' ) ) {
        $call->( $pack, $args );

        # Clear uav_module_init.  Would prefer a solution without eval( STRING ), 
        # though a symbol table manipulation method may be considered just as evil.
        my $del_str = 'delete $' . $pack . '::{uav_module_init}';
        eval $del_str;
    }

    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME

  UAV::Pilot::Commands

=head1 SYNOPSIS

    my $device; # Some UAV::Pilot::Device instance, defined elsewhere
    my $cmds = UAV::Pilot::Commands->new({
        device => $device,
    });
    
    $cmds->load_lib( 'ARDrone' );
    $cmds->run_cmd( 'takeoff;' );
    $cmds->run_cmd( 'land;' );

=head1 DESCRIPTION

Provides an interface for loading UAV extensions and running them, particularly for 
REPL shells.

=head1 METHODS

=head2 new

    new({
        device => $device
    })

Constructor.  Takes a L<UAV::Pilot::Device> instance.

=head2 load_lib

    load_lib( 'ARDrone', {
        pack => 'AR',
    })

Loads an extension by name.  The C<pack> paramter will load the library into a specific 
namespace.  If you don't specify it, you won't need to qualify commands with a namespace 
prefix.  Example:

    load_lib( 'ARDrone', { pack => 'AR' } );
    run_cmd( 'takeoff;' );     # Error: no subroutine named 'takeoff'
    run_cmd( 'AR::takeoff;' ); # This works
    
    load_lib( 'ARDrone' );
    run_cmd( 'takeoff;' );     # Now this works, too

Any other parmaeters you pass will be passed to the module's C<uav_module_init()> 
subroutine.

=head2 run_cmd

    run_cmd( 'takeoff;' )

Executes a command.  Note that this will execute arbitrary Perl statements.

=head1 COMMANDS

Commands provide an easy interface for writing simple UAV programms in a REPL shell.  
They are usually thin interfaces over a L<UAV::Pilot::Device>.  If you're writing a 
complicated script, it's suggested that you skip this interface and write to the 
L<UAV::Pilot::Device> directly.

=head2 load

    load 'ARDrone', {
        pack => 'AR',
    };

Direct call to C<load_lib>.  The C<pack> paramter will load the library into a specific 
namespace.  If you don't specify it, you won't need to qualify commands with a namespace 
prefix.  Example:

    load 'ARDrone', { pack => 'AR' };
    takeoff;     # Error: no subroutine named 'takeoff'
    AR::takeoff; # This works
    
    load ARDrone;
    takeoff;     # Now this works, too

Any other parmaeters you pass will be passed to the module's C<uav_module_init()> 
subroutine.

=head1 WRITING YOUR OWN EXTENSIONS

Extensions should go under the directory C<UAV/Pilot/Modules/> with a C<.uav> extension. 
You write them much like any Perl module, but don't use a C<package> statement--the package
will be controlled by C<UAV::Pilot::Command> when loaded.  Like a Perl module, it should 
return true as its final statement (put a C<1;> at the end).

Likewise, be careful not to make any assumptions about what package you're in.  Modules 
may or may not get loaded into different, arbitrary packages.

For ease of use, it's recommended to use function prototypes to reduce the need for 
parens.

The method C<uav_module_init()> is called with the package name as the first argument.  
Subsquent arguments will be the hashref passed to C<load()/load_lib()>.  After being called,
this sub will be deleted from the package.
