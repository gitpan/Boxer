package Boxer::CLI::Command::About;

use 5.010;
use strictures 1;
use utf8;

use Boxer::CLI -command;
use namespace::clean;

use Role::Commons -all;

our $AUTHORITY = 'cpan:JONASS';
our $VERSION   = '0.002';

use constant {
	abstract   => q[list which boxer plugins are installed],
	usage_desc => q[%c about],
};

use constant FORMAT_STR => "%-36s%10s %s\n";

sub command_names
{
	qw(
		about
		credits
	);
}

sub opt_spec
{
	return;
}

sub execute
{
	my ( $self, $opt, $args ) = @_;

	my $auth = $self->app->can('AUTHORITY');
	printf(
		FORMAT_STR,
		ref( $self->app ),
		$self->app->VERSION,
		$auth ? $self->app->$auth : '???',
	);

	foreach my $cmd ( sort $self->app->command_plugins ) {
		my $auth = $cmd->can('AUTHORITY');
		printf(
			FORMAT_STR,
			$cmd,
			$cmd->VERSION,
			$auth ? $cmd->$auth : '???',
		);
	}
}

1;
