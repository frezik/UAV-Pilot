use v5.12;
use warnings;
use Module::Build;

# TODO
# Use 'auto_features' option to make FFmpeg optional.  Tests will also need to be optional.


my $build = Module::Build->new(
    module_name    => 'UAV::Pilot',
    dist_abstract  => 'Control UAVs',
    dist_author    => q{Timm Murray <tmurray@wumpus-cave.net>},
    dist_version   => '0.5',
    license        => 'bsd',
    needs_compiler => 1,
    build_requires => {
        'ExtUtils::CBuilder' => 0, # For FFmpeg; make optional with that
    },
    requires       => {
        perl                      => '>= 5.12.0',
        'namespace::autoclean'    => 0,
        'AnyEvent'                => 0,
        'AnyEvent::ReadLine::Gnu' => 0,
        'DateTime'                => 0,
        'File::HomeDir'           => 0,
        'File::ShareDir'          => 0,
        'File::Spec'              => 0,
        'File::Temp'              => 0,
        'IO::Socket::Multicast'   => 0,
        'Math::Trig'              => 0,
        'Moose'                   => 0,
        'MooseX::Event'           => 0,
        'Test::More'              => 0,
        'Throwable'               => 0,
        'YAML'                    => 0,
        'XSLoader'                => 0, # For FFmpeg; make optional with that
    },
    recommends => {
        'SDL'          => '>= 2.5',
        'Getopt::Long' => 0,
    },
    share_dir => 'share',

    # All the below is for FFmpeg; make optional with that
    xs_files             => {
        'src/H264Decoder.xs' => 'lib/UAV/Pilot/Video/H264Decoder.xs',
    },
    dynamic_config       => 1,
    c_source             => 'src',
    allow_pureperl       => 0, # Set to 1 when FFmpeg made optional
    # Not sure how portable this is
    extra_compiler_flags => scalar `pkg-config --cflags libavcodec`,
    extra_linker_flags   => scalar `pkg-config --libs libavcodec`,
);

$build->create_build_script;
