package Boxer::CLI::Command::Compose;

use 5.010;
use strictures 1;
use utf8;

use Boxer::CLI -command;
use namespace::clean;

use Module::Runtime qw/use_module/;
use Role::Commons -all;

our $AUTHORITY = 'cpan:JONASS';
our $VERSION   = '0.003';

use constant {
	abstract   => q[compose system recipe from reclass node],
	usage_desc => q[%c install %o NODE [NODE...]],
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
		[ "suite=s",    "suite of classes to use (wheezy)" ],
		[ "nodedir=s",  "location of nodes (current dir)" ],
		[ "classdir=s", "location of classes (XDG_DATA_DIRS/suite)" ],
		[ "datadir=s",  "location with nodes and classes/suite below" ],
		[ "skeldir=s",  "location of skeleton files (use builtin)" ],
		[ "format=s", "serialize recipe(s) in this format (preseed script)" ],
		[ "verbose|v", "verbose output" ],
	);
}

sub execute
{
	my $self = shift;
	my ( $opt, $args ) = @_;

	my $data = use_module('Boxer::Task::Classify')->new(
		suite    => $opt->{suite},
		nodedir  => $opt->{nodedir},
		classdir => $opt->{classdir},
		datadir  => $opt->{datadir},
	)->run;
	for my $node (@$args) {
		use_module('Boxer::Task::Serialize')->new(
			skeldir => $opt->{skeldir},
			data    => $data,
			node    => $node,
		)->run;
	}
}

1;
