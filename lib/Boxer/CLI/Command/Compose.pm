package Boxer::CLI::Command::Compose;

use 5.010;
use strictures 1;
use utf8;

use Boxer::CLI -command;
use namespace::clean;

use Module::Runtime qw/use_module/;
use Role::Commons -all;

our $AUTHORITY = 'cpan:JONASS';
our $VERSION   = '0.001';

use constant {
	abstract   => q[compose system recipe from reclass node],
	usage_desc => q[%c install %o NODE [SUITE]],
};

sub description
{
	<<'DESCRIPTION'
Compose a system recipe.

Resolve a recipe to build a system.  Input is one or more reclass nodes
to resolve using a set of reclass classes, and output is one or more
recipies serialized in one or more formats.

DESCRIPTION
}

sub command_names
{
	qw(
		compose
	);
}

sub opt_spec
{
	return (
		[   "datadir=s",
			"directory containing profiles and skeletons (current)"
		],
		[ "format=s", "serialize recipe(s) in this format (preseed script)" ],
		[ "verbose|v", "verbose output" ],
	);
}

sub execute
{
	my $self = shift;
	my ( $opt, $args ) = @_;
	my $datadir = $opt->{datadir};
	my $node    = shift @$args;
	my $suite   = shift @$args;

	my $data = use_module('Boxer::Task::Classify')->new(
		datadir => $datadir,
		suite   => $suite,
	)->run;
	use_module('Boxer::Task::Serialize')->new(
		data    => $data,
		datadir => $datadir,
		node    => $node,
	)->run;
}

1;
