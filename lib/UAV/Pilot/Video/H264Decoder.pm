package UAV::Pilot::Video::H264Decoder;
use v5.14;
use Moose;
use namespace::autoclean;

require Exporter;
require DynaLoader;
our @ISA = qw(Exporter DynaLoader);
our @EXPORT = qw();
bootstrap UAV::Pilot::Video::H264Decoder;


with 'UAV::Pilot::Video::H264Handler';


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

