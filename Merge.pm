package Config::Merge;

# $Id: Merge.pm,v 1.12 2003/05/24 14:27:21 hasant Exp $

use 5.006;
use strict;
use Carp;
use warnings;
use Sub::Usage;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT = ('merge_config');
our $VERSION = '0.02';

my @default_order = qw(default file custom);


sub merge_config {
	@_ or usage '\@SOURCES | \%OPTIONS';
	my %merge_options = (
		default => {},
		custom  => {},
		parser  => undef,
		order   => [@default_order],
		file    => undef,
	);

	if (ref $_[0] eq 'ARRAY') {
		my($default, $file, $custom) = @{$_[0]};
		$merge_options{default} = $default if defined $default;
		$merge_options{custom}  = $custom  if defined $custom;
		$merge_options{file}    = $file    if defined $file;
	}
	elsif (ref $_[0] eq 'HASH') {
		my $user_options = shift;
		foreach my $opt (keys %merge_options) {
			$merge_options{$opt} = $user_options->{$opt}
				if defined $user_options->{$opt};
		}
	}
	else {
		croak <<EOF;
Please use ARRAY reference to specify configuration sources,
or, HASH reference to specify your options.
EOF
	}

	_merge(\%merge_options);
}

sub _merge {
	my $options = shift;
	my %config_sources = (
		default => $options->{default},
		custom  => $options->{custom},
		file    => {},
	);

	$config_sources{file} = _parse($options->{file}, $options->{parser})
		if defined $options->{file};

	my %final_config;
	my($first, $second, $third) =
		map { $config_sources{$_} || {} } @{$options->{order}};

	# set the base config, if it has nothing in it
	# just return empty hash
	my @params = keys %$first
		or return {};

	foreach my $p (@params) {
		$final_config{$p} = defined $third->{$p}  ? $third->{$p}  :
		                    defined $second->{$p} ? $second->{$p} :
		                    defined $first->{$p}  ? $first->{$p}  :
		                    undef;
	}

	return \%final_config;
}

sub _parse {
	my($file, $parser) = @_;
	$parser = \&_parse_config
		unless defined $parser and ref $parser and ref($parser) eq 'CODE';
	$parser->($file) or croak "Failed to parse file '$file'\n";
}

# Brought from Web::DataWeb::Config::parse_config().
# Continuation line handling has been fixed (it was
# broken)
sub _parse_config {
	@_ or usage 'FILENAME';
	my $file = shift;

	require Text::ParseWords;

	my %conf;
	open CONFIG, $file or croak "Failed to parse $file: $!";
	while (<CONFIG>) {
		chomp;
		next if /^\s*$/; # skip blank line
		next if /^\s*#/; # skip comments

		s/^\s+//; # strip leading spaces
		s/\s+$//; # strip trailing spaces

		# handle continuation lines
		if (s/\\$//) {
			my $next = <CONFIG>;
			$next =~ s/^\s+//; # strip leading whitespaces
			$next =~ s/\s+$//; # strip trailing whitespaces

			$_ .= $next;
			redo;
		}

		# parse the line
		my($var, $value) = split /\s*=\s*/, $_, 2;

		# "directive =" populated @values, so we
		# must make sure that $value ne '' means undef
		if (defined $value and $value ne '') {
			my @values = Text::ParseWords::parse_line(',\s*', 0, $value);
			$conf{$var} = @values == 1 ? $values[0] : \@values;
		} else {
			$conf{$var} = '';
		}
	}
	close CONFIG;

	return \%conf;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Config::Merge - Merge configurations from various sources

=head1 SYNOPSIS

    use Config::Merge;
    $conf = merge_config([$def_config, $config_file_name, $custom_config]);

    # or you may want different order with external
    # config parser provided in CODE reference
    my $conf = merge_config({
        order => [qw/file default custom/],
        parser => sub {
            require Config::General;
            my %conf = Config::General->new($_[0])->getall;
            return \%conf;
        },
        default => $default_config,
        file => $config_file_name,
        custom => $custom_config,
    });



=head1 ABSTRACT

B<Config::Merge> merges configuration from at most three sources.
Your application may allow users to define configuration in a file,
but you also have set predefined (default) configuration. At the
end you want single configuration by merging them with a certain
precedence. This module will do just that.

=head1 DESCRIPTION

There is a plenty of configuration readers/parsers floating around,
B<Config::Merge> is not trying to be another one. It helps you to
merge various configuration sources so you get the final configuration
structure based on predefined order of precedence.

Config::Merge defines three types of configuration source
(in order of precedence from lowest to higest): C<default>, C<file>,
and C<custom>.

=over 8

=item B<default>

Configuration of type C<default> contains predefined values for parameters.
It's meant to be overridden by other source of configuration. Whenever a
parameter exists in other source, then the value in the default one will be
replaced. You should set your complete parameters in C<default> type.

=item B<file>

Configuration of type C<file> comes from a file defined by the user of
the application. In standard operation, each parameter with defined value
will override corresponding parameter in the C<default> type.

=item B<custom>

Custom configuration comes from other sources than C<default> and C<file>.
In standard operation it holds the highest precedence over the others.
It's meant to temporarily set certain parameters in certain condition.

=back


=head2 How to Merge Configuration

In its standard operation, Config::Merge will take C<default> type as the base
configuration to iterate the keys. From there, it will examine other types for
existing keys to override the values of the base.

Let's say your application will read configuration from a file,

    my $conf_file = "$HOME/.myappl.conf";

That's the type of C<file>. And you define a set of default configuration,

    my %default_conf = (
        common_printer => '',
        print_command => 'cat > /tmp/dummy-output.txt',
        paper_type => 'A4',
    );

which is a type of C<default>. Since your application is highly customizable,
you also allow some command line parameters which you parse in some way,

    my $cmdline_opts = parse_cmdline_options(); # defined somewhere else

so you have the last type, C<custom>. In order to get a single configuration
structure, you simply call the B<merge_config()> function and pass in the
configuration sources in ARRAY reference. It will return the final form in HASH
reference. This function is exported by default. If there's something wrong in
the file parsing process, it will simply croak.

    use Config::Merge;
    my $conf = merge_config([\%default, $conf_file, $cmdline_opts]);

Remember that you must pass in your configuration sources in the right order:
default, file, and custom. However, you can specify different order by using
C<order> option.

Config::Merge provides internal file configuration parser. The reason for this
is two folds. First, for convenience reason to avoid dependency on external
parser. Second, historically, I've written this routine long long time ago so
why I don't just reuse it.

Again, you can specify your favourite parser to suite your need using C<parser>
option. This option takes CODE reference as its argement and the coderef will
be passed in the filename. The CODE reference is expected to return a HASH
reference. False value will be regarded as error.

Now that you use options to change Config::Merge's behaviour, you need to specify
your sources via options as well. And you will pass in your options in HASH reference
to C<merge_config>.

    my $conf = merge_config({
        order => [qw(default custom file)], # lowest to highest
        parser => \&Config::Auto::parse, # need require() or use()
        custom => $cmdline_opts,
        file => $conf_file,
        default => \%default,
    });

Well, that's all there is to merge your configuration sources. Now I'm about
to explain the file format expected by the internal parser.

=head2 Internal Parser

The internal parser is very simple and general. The rules are the following.

=over 2

=item o

Empty lines are ignored.

=item o

Lines start with C<#> are comment and ignored as well.

=item o

Whitespaces are generally insignificant. Leading and trailing whitespaces
are removed as well as whitespaces surrounding the equal sign.

=item o

You may use double quotes (C<"">) in the values to preserve whitespaces.

=item o

Each line contains a pair of parameter and value separated by equal sign
(C<=>).  However, multiline for single parameter is supported by adding
a backslash (C<\>) at the end of the continuation lines.

=item o

Multivalue is supported by separating the values with comma (C<,>).
Use double quotes (C<"">) to preserve commas in values.

=item o

Empty value for a parameter will be regarded as empty string, not undefined.
If you want the latter simply don't define the parameter at all.

=back

=head1 DEPENDENCIES

=over 8

=item B<Text::ParseWords>

Internal parser uses C<Text::ParseWords::parse_line()> to parse
configuration file. This module is part of standard distribution.

=item B<Sub::Usage>

It's used to issue insufficient-parameter error from subroutines.
Available at CPAN.

=item B<Test::More>

For testing (with C<make test>) during installation.

=back

=head1 CAVEATS

=over 2

=item o

lack of testing for external configuration parser, only tested
with B<Config::Auto> and B<Config::General>.

=back

=head1 FUTURE PLANS

=over 2

=item o

accepting multiple files and merge them as well in the order they
are defined.

=item o

make C<parser> option to directly take the package or class name
of the external configuration reader/parser.

=item o

(probably) allow more than three (unlimited?), sources of configuration.

=item o

allow preparsed configuration (in HASH ref) as value for C<file> type instead
of merely filename.

=back

=head1 AUTHOR

Hasanuddin Tamir E<lt>hasant@cpan.orgE<gt>

I highly appreciate any feedback, even a single comment,
about this module.

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Hasanuddin Tamir.  All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=head1 SEE ALSO

Various configuration parsers from CPAN.

=cut
