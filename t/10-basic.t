# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

use strict;
use vars qw($dummy_file %dummy_config %file_config $module $param_count);

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
        totalabsurd => undef,
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
    create_dummy_config_file;
}

END {
    unlink $dummy_file;
}

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More 'no_plan';
#BEGIN { plan tests => 30 };
use Config::Merge;
ok(1, "$module is loaded successfully"); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $custom = {totalabsurd => 10};
my $conf = merge_config([\%dummy_config, $dummy_file, $custom]);
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


# let's change the order of the sources
$custom->{country} = 'No Man\'s Land';
$custom->{type} = 'custom';
$conf = merge_config({
	order => [qw/default custom file/],
	file => $dummy_file,
	default => \%dummy_config,
	custom => $custom,
});

ok($conf, 'the final configuration returned');
is(ref $conf, 'HASH', 'final configuration data type');
cmp_ok(scalar keys %$conf, '==', $param_count, 'count of parameters');
cmp_ok($conf->{type}, 'eq', $file_config{type}, "param 'type'");
cmp_ok($conf->{country}, 'eq', $custom->{country}, "param 'country'");
cmp_ok($conf->{totalabsurd}, 'eq', $custom->{totalabsurd}, "param 'totalabsurd'");
