use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Config::Merge',
    'VERSION_FROM'	=> 'Merge.pm', # finds $VERSION
    'PREREQ_PM'		=> { # e.g., Module::Name => 1.1
		'Sub::Usage' => 0,
		'Test::More' => 0,
	},
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Merge.pm', # retrieve abstract from module
       AUTHOR     => 'Hasanuddin Tamir <hasant@cpan.org>') : ()),
	dist => {
		COMPRESS => 'gzip -9',
		SUFFIX => 'gz',
		POSTOP => 'mv $(DISTVNAME).tar.gz ..',
	},
);
