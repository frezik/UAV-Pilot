use 5.12;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'UAV::Pilot',
    AUTHOR              => q{Timm Murray <tmurray@wumpus-cave.net.com>},
    VERSION_FROM        => 'lib/UAV/Pilot.pm',
    ABSTRACT_FROM       => 'lib/UAV/Pilot.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'           => 0,
        'Moose'                => 0,
        'autoclean::namespace' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'UAV-Pilot-*' },
);
