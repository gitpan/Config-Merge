#!/usr/bin/perl -w

use strict;
use vars qw($dummy_file %dummy_config %file_config $module $param_count);

my %parser = (
	'Config::Auto' => [0, 10],
	'Config::General' => [0, 10],
);
foreach (keys %parser) {
$parser{$_}[0] = eval qq{
    require $_;
    $_->VERSION;
};
}

BEGIN {
    $module = 'Config::Merge';
    $dummy_file = 'dummy.cfg';
    %dummy_config = (
        module => $module,
        author => 'hasant',
        config_value => 4,
        country => 'Indonesia',
        fullname => 'Hasanuddin Tamir',
        type => 'default',
        totalabsurd => 'ac', # will not show unless exists in config file
    );
	$param_count = scalar keys %dummy_config;

    sub create_dummy_config_file {
    %file_config = (
        fullname => '',
        config_value => 14,
        type => 'file',
    );

    open CFG, ">$dummy_file" or die "can not create '$dummy_file': $!\n";
    foreach (keys %file_config) {
        print CFG "$_ =";
        print CFG " $file_config{$_}"
            if defined $file_config{$_} and length $file_config{$_};
        print CFG "\n";
    }
    close CFG;
    }
    create_dummy_config_file();
}

END {
    unlink $dummy_file;
}

use Test::More 'no_plan';
#BEGIN { plan tests => 30 };
use Config::Merge;
ok(1, "$module is loaded successfully"); # If we made it this far, we're ok.

my $custom = {totalabsurd => 10};
my $conf;

# Config::Auto
SKIP: {
    skip "Config::Auto is not installed", $parser{'Config::Auto'}[1]
        unless $parser{'Config::Auto'}[0];

	$conf = merge_config({
		parser => \&Config::Auto::parse,
		file => $dummy_file,
		default => \%dummy_config,
		custom => $custom,
	});

	ok($conf, 'the final configuration returned');
	is(ref $conf, 'HASH', 'final configuration data type');

	cmp_ok(scalar keys %$conf, '==', $param_count, 'count of parameters');
	cmp_ok($conf->{module}, 'eq', $module, "param 'module'");
	cmp_ok($conf->{author}, 'eq', $dummy_config{author}, "param 'author'");
	cmp_ok($conf->{config_value}, '==', $file_config{config_value}, "param 'config_value'");

	cmp_ok($conf->{country}, 'eq', $dummy_config{country}, "param 'country'");
	cmp_ok($conf->{fullname}, 'eq', $file_config{fullname}, "param 'fullname'");
	cmp_ok($conf->{type}, 'eq', $file_config{type}, "param 'type'");
	cmp_ok($conf->{totalabsurd}, 'eq', $custom->{totalabsurd}, "param 'totalabsurd'");
}

# Config::General
SKIP: {
    skip "Config::General is not installed", $parser{'Config::General'}[1]
        unless $parser{'Config::General'}[0];
	#require Data::Dumper;
	#print STDERR Data::Dumper::Dumper($conf);
	#print STDERR Data::Dumper::Dumper(\%file_config);

	$conf = merge_config({
		parser => sub {
		use Config::General;
		my %conf = ParseConfig($_[0]);
		return \%conf;
		},
		file => $dummy_file,
		default => \%dummy_config,
		custom => $custom,
	});

	ok($conf, 'the final configuration returned');
	is(ref $conf, 'HASH', 'final configuration data type');

	cmp_ok(scalar keys %$conf, '==', $param_count, 'count of parameters');
	cmp_ok($conf->{module}, 'eq', $module, "param 'module'");
	cmp_ok($conf->{author}, 'eq', $dummy_config{author}, "param 'author'");
	cmp_ok($conf->{config_value}, '==', $file_config{config_value}, "param 'config_value'");

	cmp_ok($conf->{country}, 'eq', $dummy_config{country}, "param 'country'");
	cmp_ok($conf->{fullname}, 'eq', $file_config{fullname}, "param 'fullname'");
	cmp_ok($conf->{type}, 'eq', $file_config{type}, "param 'type'");
	cmp_ok($conf->{totalabsurd}, 'eq', $custom->{totalabsurd}, "param 'totalabsurd'");
}
