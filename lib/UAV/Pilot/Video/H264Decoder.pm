package UAV::Pilot::Video::H264Decoder;
use v5.14;
use Moose;
use namespace::autoclean;

require DynaLoader;
our @ISA = qw(DynaLoader);
bootstrap UAV::Pilot::Video::H264Decoder;


with 'UAV::Pilot::Video::H264Handler';


# Helper sub to simplifiy throwing exceptions in the xs code
sub _throw_error
{
    my ($class, $error_str) = @_;
    UAV::Pilot::VideoException->throw(
        error => $error_str,
    );
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


# NOTE: this may need to be under the LGPL
