package Test::MOP;
use v5.14;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw{ does_ok };
our @EXPORT    = @EXPORT_OK;


sub does_ok
{
    my ($obj, $class, @test_args) = @_;
    my $passes = 0;
    my $test = Test::Builder->new;

    $passes = 1 if( ref($obj)
        && $obj->isa( 'mop::object' ) 
        && $obj->does( $class )
    );

    $test->ok( $passes, @test_args );
    return $passes;
}


1;
__END__

