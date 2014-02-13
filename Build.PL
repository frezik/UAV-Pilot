use v5.14;
use warnings;
use Module::Build;


my $build = Module::Build->new(
    module_name       => 'UAV::Pilot',
    dist_abstract     => 'Control UAVs',
    dist_author       => q{Timm Murray <tmurray@wumpus-cave.net>},
    dist_version_from => 'lib/UAV/Pilot.pm',
    license           => 'bsd',
    requires          => {
        perl                                => '>= 5.14.0',
        'namespace::autoclean'              => 0,
        'Alien::ffmpeg'                     => 0,
        'AnyEvent'                          => 0,
        'AnyEvent::ReadLine::Gnu'           => 0,
        'DateTime'                          => 0,
        'File::HomeDir'                     => 0,
        'File::ShareDir'                    => 0,
        'File::Spec'                        => 0,
        'File::Temp'                        => 0,
        'IO::Socket::Multicast'             => 0,
        'Log::Log4perl'                     => 0,
        'Math::Trig'                        => 0,
        'Moose'                             => 0,
        'MooseX::Event'                     => 0,
        'String::CRC32'                     => 0,
        'Test::More'                        => 0,
        'Tie::IxHash'                       => 0,
        'Throwable'                         => 0,
        'YAML'                              => 0,
    },
    recommends => {
        'Getopt::Long'              => 0,
        'UAV::Pilot::SDL'           => 0,
        'UAV::Pilot::Video::Ffmpeg' => 0,
    },
    share_dir => 'share',

    meta_merge => {
        resources => {
            repository => 'https://github.com/frezik/UAV-Pilot',
        },
    },
);

$build->create_build_script;
