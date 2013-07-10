package UAV::Pilot::Video::H264Decoder;
use v5.14;
use Moose;
use namespace::autoclean;

require DynaLoader;
our @ISA = qw(DynaLoader);
bootstrap UAV::Pilot::Video::H264Decoder;


with 'UAV::Pilot::Video::H264Handler';


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

