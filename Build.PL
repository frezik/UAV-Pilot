use v5.12;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    module_name    => 'UAV::Pilot',
    dist_abstract  => 'Control UAVs',
    dist_author    => q{Timm Murray <tmurray@wumpus-cave.net>},
    dist_version   => '0.2',
    license        => 'bsd',
    release_status => 'testing',
    requires       => {
        perl                      => '>= 5.12.0',
        'namespace::autoclean'    => 0,
        'AnyEvent'                => 0,
        'AnyEvent::ReadLine::Gnu' => 0,
        'File::ShareDir'          => 0,
        'File::Spec'              => 0,
        'IO::Socket::Multicast'   => 0,
        'Math::Trig'              => 0,
        'Moose'                   => 0,
        'MooseX::Event'           => 0,
        'Test::More'              => 0,
        'Throwable'               => 0,
    },
    recommends => {
        'SDL' => '>= 2.5',
    },
    share_dir => 'share',
);

$build->create_build_script;
