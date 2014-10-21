package Boxer::Task::Classify;

use 5.010;
use strictures 1;
use utf8;
use autodie qw(:all);
use IPC::System::Simple;

use Moo;
use Types::Standard qw( Str Undef );
use Types::Path::Tiny qw( Dir );
extends 'Boxer::Task';

use File::BaseDir qw(data_dirs);
use Capture::Tiny qw(capture_stdout);
use YAML::XS;

use Role::Commons -all;

our $AUTHORITY = 'cpan:JONASS';
our $VERSION   = '0.003';

# permit callers to sloppily pass undefined values
sub BUILDARGS
{
	my ( $class, %args ) = @_;
	delete @args{ grep !defined( $args{$_} ), keys %args };
	return {%args};
}

has datadir => (
	is       => 'lazy',
	isa      => Dir,
	coerce   => Dir->coercion,
	required => 1,
	default  => sub { scalar( data_dirs( 'boxer', $_[0]->suite ) ) },
);

has suite => (
	is       => 'ro',
	isa      => Str,
	required => 1,
	default  => sub {'wheezy'},
);

has classdir => (
	is       => 'lazy',
	isa      => Dir,
	coerce   => Dir->coercion,
	required => 1,
	default  => sub { $_[0]->datadir->child('classes') },
);

has nodedir => (
	is       => 'lazy',
	isa      => Dir,
	coerce   => Dir->coercion,
	required => 1,
	default  => sub { $_[0]->datadir ? $_[0]->datadir->child('nodes') : '.' },
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
					'',
					'-c',
					$self->classdir,
					'-u',
					$self->nodedir,
					'--inventory',
				);
			}
		)
	);
}

1;
