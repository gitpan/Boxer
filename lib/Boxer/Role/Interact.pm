package Boxer::Role::Interact;

use 5.010;
use strictures 1;

use Moo::Role;
use MooX::Types::MooseLike::Base qw< Bool >;
use Role::Commons -all;

our $AUTHORITY = 'cpan:JONASS';
our $VERSION   = '0.002';

has verbose => (
	is       => 'rw',
	isa      => Bool,
	required => 1,
	default  => sub {0},
);

has debug => (
	is       => 'rw',
	isa      => Bool,
	required => 1,
	default  => sub {0},
);

has dryrun => (
	is       => 'ro',
	isa      => Bool,
	required => 1,
	default  => sub {0},
);

1;
