use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name        => 'Config::Merge',
    license            => 'perl',
    dist_author        => q{Clinton Gormley <drtech@cpan.org>},
    dist_version_from  => 'lib/Config/Merge.pm',
    build_requires     => { 'Test::More' => 0, },
    create_makefile_pl => 'traditional',
    requires           => {
        'File::Spec'  => 0,
        'Storable'    => 0,
        'Config::Any' => '0.07',
    },
    recommends => {
        'YAML::Syck'      => 0,
        'YAML'            => 0,
        'JSON::XS'        => 0,
        'JSON'            => 0,
        'Config::Tiny'    => 0,
        'XML::Simple'     => 0,
        'Config::General' => 0
    },
    meta_merge => {
        resources => {
            bugtracker =>
                'http://github.com/clintongormley/ConfigMerge/issues',
            repository => 'http://github.com/clintongormley/ConfigMerge'
        }
    },
);

$builder->create_build_script();

