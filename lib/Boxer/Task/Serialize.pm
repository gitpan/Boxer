package Boxer::Task::Serialize;

use 5.010;
use autodie;
use strictures 1;
use utf8;

use Moo;
extends 'Boxer::Task';

use Types::Standard qw( HashRef Str Undef );
use Types::Path::Tiny qw( Dir File Path );
use Path::Tiny;
use Try::Tiny;
use File::ShareDir::ProjectDistDir;

use Role::Commons -all;

our $AUTHORITY = 'cpan:JONASS';
our $VERSION   = '0.003';

# permit callers to sloppily pass undefined hash values
sub BUILDARGS
{
	my ( $class, %args ) = @_;
	delete @args{ grep !defined( $args{$_} ), keys %args };
	return {%args};
}

has data => (
	is       => 'ro',
	isa      => HashRef,
	required => 1,
);

has skeldir => (
	is       => 'ro',
	isa      => Dir,
	coerce   => Dir->coercion,
	required => 1,
	default  => sub { Path::Tiny->new( dist_dir('Boxer') )->child('skel') },
);

has infile => (
	is       => 'lazy',
	isa      => File,
	coerce   => File->coercion,
	required => 1,
	default  => sub { $_[0]->skeldir->child('preseed.cfg.in') },
);

has altinfile => (
	is       => 'lazy',
	isa      => File,
	coerce   => File->coercion,
	required => 1,
	default  => sub { $_[0]->skeldir->child('script.sh.in') },
);

has outdir => (
	is       => 'ro',
	isa      => Dir,
	coerce   => Dir->coercion,
	required => 1,
	default  => sub {'.'},
);

has outfile => (
	is       => 'lazy',
	isa      => Path,
	coerce   => Path->coercion,
	required => 1,
	default  => sub { $_[0]->outdir->child('preseed.cfg') },
);

has altoutfile => (
	is       => 'lazy',
	isa      => Path,
	coerce   => Path->coercion,
	required => 1,
	default  => sub { $_[0]->outdir->child('script.sh') },
);

has node => (
	is       => 'ro',
	isa      => Str,
	required => 1,
);

sub run
{
	my $self = shift;

	( defined( $self->data->{'nodes'}{ $self->node } ) )
		or die "Undefined node \"" . $self->node . "\".";

	my %params = %{ $self->data->{'nodes'}{ $self->node }{'parameters'} };

	my %desc;

#TODO: sort by explicit list
	foreach my $key ( sort keys %{ $params{doc} } ) {
		my $headline = $params{doc}{$key}{headline}[0] || $key;
		if ( $params{pkg} and $params{doc}{$key}{pkg} ) {
			push @{ $desc{pkg} }, "# $headline";
			foreach ( @{ $params{doc}{$key}{pkg} } ) {
				push @{ $desc{pkg} }, "#  * $_";
			}
		}
		if ( $params{tweak} and $params{doc}{$key}{tweak} ) {
			push @{ $desc{tweak} }, "# $headline";
			foreach ( @{ $params{doc}{$key}{tweak} } ) {
				push @{ $desc{tweak} }, "#  * $_";
			}
		}
	}
	my $pkgdesc
		= defined( $desc{pkg} )
		? join( "\n", @{ $desc{pkg} } )
		: '';
	my $tweakdesc
		= defined( $desc{tweak} )
		? join( "\n", @{ $desc{tweak} } )
		: '';
	my @pkg = try { @{ $params{pkg} } } catch { die "No packages resolved" };
	my @pkgauto = try { @{ $params{'pkg-auto'} } }
	catch { die "No package auto-markings resolved" };
	my @pkgavoid = try { @{ $params{'pkg-avoid'} } }
	catch { die "No package avoidance resolved" };
	my @tweak
		= try { @{ $params{tweak} } } catch { die "No tweaks resolved" };
	my $pkglist = join( ' ', sort @pkg );
	$pkglist .= " \\\n ";
	$pkglist .= join( ' ', sort map { $_ . '-' } @pkgavoid );
	my $pkgautolist = join( ' ', sort @pkgauto );
	grep {chomp} @tweak;
	my $tweaklist = join( ";\\\n ", 'set -e', @tweak );

	$self->outdir->mkpath;
	$_ = $self->altinfile->slurp;
	s,__PKGDESC__,$pkgdesc,;
	s,__PKGLIST__,$pkglist,;
	s,__TWEAKDESC__,$tweakdesc,;
	s,__TWEAKLIST__,$tweaklist,;
	s,__PKGAUTOLIST__,$pkgautolist,;
	s,chroot\s+/target\s+,,g;
	s,/target/,/,g;
	$self->altoutfile->spew($_);
	$_ = $self->infile->slurp;
	s,__PKGDESC__,$pkgdesc,;
	s,__PKGLIST__,$pkglist,;
	s,__TWEAKDESC__,$tweakdesc,;
	s,__TWEAKLIST__,$tweaklist,;
	s,__PKGAUTOLIST__,$pkgautolist,;
	$self->outfile->spew($_);
}

1;
