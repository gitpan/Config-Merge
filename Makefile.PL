use ExtUtils::MakeMaker;

my %prereqs = ( 'Test::More'  => 0,
                'File::Spec'  => 0,
                'Storable'    => 0,
                'Data::Alias' => '1.01',
                'Config::Any' => '0.07',
);

my @optional = ( [ 'YAML::Syck', 'YAML' ],
                 [ 'JSON::Syck', 'JSON' ],
                 ['Config::Tiny'], ['XML::Simple'], ['Config::General']
);

## Optional modules

print "OPTIONAL MODULES:\n" . ( '-' x 17 ) . "\n";
OPTION: foreach my $optional (@optional) {
    foreach my $module (@$optional) {
        printf( "  - %-20s : ", $module );
        eval "require $module";
        if ($@) {
            if ( lc( prompt( "Install : [y/N]", 'n' ) ) eq 'y' ) {
                $prereqs{$module} = 0;
            }
            next OPTION;
        }
        else {
            print "Installed\n";
            next OPTION;
        }
    }
}

WriteMakefile( 'NAME'          => 'Config::Merge',
               'VERSION_FROM'  => 'Merge.pm',
               'ABSTRACT_FROM' => 'Merge.pm',
               'PREREQ_PM'     => \%prereqs,
               'AUTHOR'        => ' Clinton Gormley <clint@traveljury.com>',
               $ExtUtils::MakeMaker::VERSION >= 6.31
               ? ( 'LICENSE' => 'perl' )
               : (),
);

