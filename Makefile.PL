use 5.006;
use ExtUtils::MakeMaker;

print STDERR <<EOF;

====================================================================

You are going to need Text::ParseWords module if
you plan to use the internal parser. This module
is part of Perl standard distribution so you
probably do not have to worry about that.

====================================================================

EOF
sleep 1;

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
