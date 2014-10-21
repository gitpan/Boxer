package Boxer::CLI::Command::Aliases;

use 5.010;
use strictures 1;
use utf8;
use match::simple qw(match);

use Boxer::CLI -command;
use namespace::clean;

use Role::Commons -all;

our $AUTHORITY = 'cpan:JONASS';
our $VERSION   = '0.003';

use constant {
	abstract   => q[show aliases for boxer commands],
	usage_desc => q[%c aliases],
};

sub description
{
	<<'DESCRIPTION'
Most boxer commands can be invoked with shorter aliases.

	boxer translate -s rdfxml input.ttl
	boxer tr -s rdfxml input.ttl          # same thing

The aliases command (which, ironically, has no shorter alias) shows existing
aliases.
DESCRIPTION
}

sub command_names
{
	qw(
		aliases
	);
}

sub opt_spec
{
	return;
}

sub execute
{
	my ( $self, $opt, $args ) = @_;

	my $filter
		= scalar(@$args)
		? $args
		: sub { not( match( shift, [qw(aliases commands help)] ) ) };

	foreach my $cmd ( sort $self->app->command_plugins ) {
		my ( $preferred, @aliases ) = $cmd->command_names;
		printf( "%-16s: %s\n", $preferred, "@aliases" )
			if match( $preferred, $filter );
	}
}

1;
