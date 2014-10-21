package Boxer::CLI::Command::Commands;

use 5.010;
use strictures 1;
use utf8;

use Boxer::CLI -command;
use namespace::clean;

use Role::Commons -all;

our $AUTHORITY = 'cpan:JONASS';
our $VERSION   = '0.003';

require App::Cmd::Command::commands;
our @ISA;
unshift @ISA, 'App::Cmd::Command::commands';

use constant {
	abstract => q[list installed boxer commands],
};

sub sort_commands
{
	my ( $self, @commands ) = @_;
	my $float = qr/^(?:help|commands|aliases|about)$/;
	my @head  = sort grep { $_ =~ $float } @commands;
	my @tail  = sort grep { $_ !~ $float } @commands;
	return ( \@head, \@tail );
}
1;
