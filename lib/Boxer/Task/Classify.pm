package Boxer::Task::Classify;

use 5.010;
use autodie;
use strictures 1;
use utf8;
use autodie qw(:all);

use Moo;
use Types::Standard qw( Str Undef );
use Types::Path::Tiny qw( Dir );
extends 'Boxer::Task';

use Capture::Tiny qw(capture_stdout);
use YAML::XS;

use Role::Commons -all;

our $AUTHORITY = 'cpan:JONASS';
our $VERSION   = '0.002';

my $workdir = Dir->plus_coercions(
	Str,   q{ 'Path::Tiny'->new($_) },
	Undef, q{ 'Path::Tiny'->cwd },
);

has datadir => (
	is       => 'ro',
	isa      => $workdir,
	coerce   => $workdir->coercion,
	required => 1,
);

has suite => (
	is       => 'ro',
	isa      => Str,
	required => 1,
	default  => sub {'wheezy'},
);

has profiledir => (
	is       => 'lazy',
	isa      => Dir,
	coerce   => Dir->coercion,
	required => 1,
	default  => sub { $_[0]->datadir->child( 'profiles', $_[0]->suite ) },
);

sub run
{
	my $self = shift;

	Load(
		scalar(
			capture_stdout {
				system(
					'reclass',
					'-b',
					$self->profiledir,
					'--inventory',
				);
			}
		)
	);
}

1;
