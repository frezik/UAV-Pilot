use v5.14;
use warnings;
use Module::Build;

# TODO
# Use 'auto_features' option to make FFmpeg optional.  Tests will also need to be optional.


my @build_flags = (
    '-Wall',
    scalar( `pkg-config --cflags libavcodec libswscale` ),
    scalar( `sdl-config --cflags` ),
);
my @link_flags = (
    scalar( `pkg-config --libs libavcodec libswscale` ),
    scalar( `sdl-config --libs` ),
);


my $build = Module::Build->new(
    module_name       => 'UAV::Pilot',
    dist_abstract     => 'Control UAVs',
    dist_author       => q{Timm Murray <tmurray@wumpus-cave.net>},
    dist_version_from => 'lib/UAV/Pilot.pm',
    license           => 'bsd',
    needs_compiler    => 1,
    build_requires    => {
        'ExtUtils::CBuilder' => 0, # For FFmpeg; make optional with that
    },
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
        # For FFmpeg; make optional with that
        'XSLoader'                          => 0,
    },
    recommends => {
        'SDL'          => '>= 2.5',
        'Getopt::Long' => 0,
    },
    share_dir => 'share',

    # Much of the below is for FFmpeg; make optional with that
    include_dirs         => ['.'],
    dynamic_config       => 1,
    allow_pureperl       => 0, # Set to 1 when FFmpeg made optional
    # Not sure how portable this is
    extra_compiler_flags => join( ' ', @build_flags ),
    extra_linker_flags   => join( ' ', @link_flags ),
    meta_merge => {
        resources => {
            repository => 'https://github.com/frezik/UAV-Pilot',
        },
    },
);

$build->create_build_script;
