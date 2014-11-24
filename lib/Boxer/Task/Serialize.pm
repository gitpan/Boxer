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
use Template::Tiny;
use File::ShareDir::ProjectDistDir;

use Role::Commons -all;

our $AUTHORITY = 'cpan:JONASS';
our $VERSION   = '0.004';

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

my $pos           = 1;
my @section_order = qw(
	Administration
	Service
	Console
	Desktop
	Language
	Framework
	Task
	Hardware
);
my %section_order = map { $_ => $pos++ } @section_order;

sub run
{
	my $self = shift;

	( defined( $self->data->{'nodes'}{ $self->node } ) )
		or die "Undefined node \"" . $self->node . "\".";

	my %params = %{ $self->data->{'nodes'}{ $self->node }{'parameters'} };

	my %desc;

	my @section_keys = sort {
		( $section_order{$a} // 1000 ) <=> ( $section_order{$b} // 1000 )
			|| $a cmp $b
	} keys %{ $params{doc} };

	foreach my $key (@section_keys) {
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
	catch { warn "No package auto-markings resolved" };
	my @pkgavoid = try { @{ $params{'pkg-avoid'} } }
	catch { warn "No package avoidance resolved" };
	my @tweak
		= try { @{ $params{tweak} } } catch { warn "No tweaks resolved" };
	my $pkglist = join( ' ', sort @pkg );
	$pkglist .= " \\\n ";
	$pkglist .= join( ' ', sort map { $_ . '-' } @pkgavoid );
	my $pkgautolist = join( ' ', sort @pkgauto );
	grep {chomp} @tweak;
	my $tweaklist = join( ";\\\n ", @tweak );

	$self->outdir->mkpath;

	my $template = Template::Tiny->new(
		TRIM => 1,
	);

	my %vars = (
		pkgdesc     => $pkgdesc,
		pkglist     => $pkglist,
		tweakdesc   => $tweakdesc,
		tweaklist   => $tweaklist,
		pkgautolist => $pkgautolist,
	);
	# TODO: drop this when fixed boxer-data is in common use
	if ( $vars{tweaklist} =~ s,__PKGAUTOLIST__,$pkgautolist, ) {
		warn "Embedding __PKGAUTOLIST__ in tweaks is deprecated";
		$vars{pkgautolist} = undef;
	}

	my %altvars = %vars;
	$altvars{tweaklist} =~ s,chroot\s+/target\s+,,g;
	$altvars{tweaklist} =~ s,/target/,/,g;

	my $altcontent = '';
	$template->process( \$self->altinfile->slurp, \%altvars, \$altcontent );
	$self->altoutfile->spew( $altcontent . "\n" );

	my $content = '';
	$template->process( \$self->infile->slurp, \%vars, \$content );
	$self->outfile->spew( $content . "\n" );
}

1;
