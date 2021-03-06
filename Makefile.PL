use strict;
use ExtUtils::MakeMaker 6.17;

my $EUMM = eval( $ExtUtils::MakeMaker::VERSION );

my $meta = {
  "abstract"           => "boxer command line utils",
  "author"             => ["Jonas Smedegaard (JONASS) <jonass\@cpan.org>"],
  "dynamic_config"     => 0,
  "generated_by"       => "Dist::Inkt::Profile::TOBYINK version 0.023, CPAN::Meta::Converter version 2.142690",
  "keywords"           => ["Debian", "Distribution"],
  "license"            => ["perl_5"],
  "meta-spec"          => {
                            url => "http://search.cpan.org/perldoc?CPAN::Meta::Spec",
                            version => 2,
                          },
  "name"               => "Boxer",
  "no_index"           => { directory => ["eg", "examples", "inc", "t", "xt"] },
  "prereqs"            => {
                            configure => {
                              requires => { "ExtUtils::MakeMaker" => 6.17, "File::ShareDir::Install" => 0.02 },
                            },
                            runtime => {
                              requires => {
                                "App::Cmd"                       => 0,
                                "autodie"                        => 0,
                                "Capture::Tiny"                  => 0,
                                "File::BaseDir"                  => 0,
                                "File::HomeDir"                  => 0,
                                "File::ShareDir::ProjectDistDir" => 0,
                                "IPC::System::Simple"            => 0,
                                "JSON"                           => "2.00",
                                "match::simple"                  => 0,
                                "Module::Runtime"                => 0,
                                "Moo"                            => "1.001000",
                                "MooX::Log::Any"                 => 0,
                                "MooX::Types::MooseLike::Base"   => 0,
                                "namespace::clean"               => 0,
                                "Path::Class"                    => 0,
                                "Path::Tiny"                     => 0,
                                "perl"                           => 5.010001,
                                "Role::Commons"                  => 0,
                                "strictures"                     => 0,
                                "Template::Tiny"                 => 0.11,
                                "Try::Tiny"                      => 0,
                                "Types::Path::Tiny"              => 0,
                                "Types::Standard"                => 0,
                                "YAML::XS"                       => 0,
                              },
                            },
                            test => {
                              requires => {
                                "English"              => 0,
                                "File::Spec"           => 0,
                                "Test::Compile"        => 0,
                                "Test::Fixme"          => 0,
                                "Test::MinimumVersion" => 0,
                                "Test::More"           => 0.61,
                                "Test::Pod"            => "1.00",
                                "Test::Synopsis"       => 0,
                              },
                            },
                          },
  "provides"           => {
                            "Boxer" => { file => "lib/Boxer.pm", version => 0.004 },
                            "Boxer::CLI" => { file => "lib/Boxer/CLI.pm", version => 0.004 },
                            "Boxer::CLI::Command" => { file => "lib/Boxer/CLI/Command.pm", version => 0.004 },
                            "Boxer::CLI::Command::About" => { file => "lib/Boxer/CLI/Command/About.pm", version => 0.004 },
                            "Boxer::CLI::Command::Aliases" => { file => "lib/Boxer/CLI/Command/Aliases.pm", version => 0.004 },
                            "Boxer::CLI::Command::Commands" => { file => "lib/Boxer/CLI/Command/Commands.pm", version => 0.004 },
                            "Boxer::CLI::Command::Compose" => { file => "lib/Boxer/CLI/Command/Compose.pm", version => 0.004 },
                            "Boxer::Role::Interact" => { file => "lib/Boxer/Role/Interact.pm", version => 0.004 },
                            "Boxer::Task" => { file => "lib/Boxer/Task.pm", version => 0.004 },
                            "Boxer::Task::Classify" => { file => "lib/Boxer/Task/Classify.pm", version => 0.004 },
                            "Boxer::Task::Serialize" => { file => "lib/Boxer/Task/Serialize.pm", version => 0.004 },
                          },
  "release_status"     => "stable",
  "resources"          => {
                            bugtracker   => { web => "http://rt.cpan.org/Dist/Display.html?Queue=Boxer" },
                            homepage     => "https://metacpan.org/release/Boxer",
                            license      => ["http://dev.perl.org/licenses/"],
                            repository   => {
                                              type => "git",
                                              web  => "https://anonscm.debian.org/cgit/boxer/Boxer.git",
                                            },
                            x_identifier => "http://purl.org/NET/cpan-uri/dist/Boxer/project",
                          },
  "version"            => 0.004,
  "x_help_wanted"      => ["tester", "documenter"],
  "x_provides_scripts" => { boxer => { file => "bin/boxer" } },
};

my %dynamic_config;

my %WriteMakefileArgs = (
	ABSTRACT   => $meta->{abstract},
	AUTHOR     => ($EUMM >= 6.5702 ? $meta->{author} : $meta->{author}[0]),
	DISTNAME   => $meta->{name},
	VERSION    => $meta->{version},
	EXE_FILES  => [ map $_->{file}, values %{ $meta->{x_provides_scripts} || {} } ],
	NAME       => do { my $n = $meta->{name}; $n =~ s/-/::/g; $n },
	test       => { TESTS => "t/*.t" },
	%dynamic_config,
);

$WriteMakefileArgs{LICENSE} = $meta->{license}[0] if $EUMM >= 6.3001;

sub deps
{
	my %r;
	for my $stage (@_)
	{
		for my $dep (keys %{$meta->{prereqs}{$stage}{requires}})
		{
			next if $dep eq 'perl';
			my $ver = $meta->{prereqs}{$stage}{requires}{$dep};
			$r{$dep} = $ver if !exists($r{$dep}) || $ver >= $r{$dep};
		}
	}
	\%r;
}

my ($build_requires, $configure_requires, $runtime_requires, $test_requires);
if ($EUMM >= 6.6303)
{
	$WriteMakefileArgs{BUILD_REQUIRES}     ||= deps('build');
	$WriteMakefileArgs{CONFIGURE_REQUIRES} ||= deps('configure');
	$WriteMakefileArgs{TEST_REQUIRES}      ||= deps('test');
	$WriteMakefileArgs{PREREQ_PM}          ||= deps('runtime');
}
elsif ($EUMM >= 6.5503)
{
	$WriteMakefileArgs{BUILD_REQUIRES}     ||= deps('build', 'test');
	$WriteMakefileArgs{CONFIGURE_REQUIRES} ||= deps('configure');
	$WriteMakefileArgs{PREREQ_PM}          ||= deps('runtime');	
}
elsif ($EUMM >= 6.52)
{
	$WriteMakefileArgs{CONFIGURE_REQUIRES} ||= deps('configure');
	$WriteMakefileArgs{PREREQ_PM}          ||= deps('runtime', 'build', 'test');	
}
else
{
	$WriteMakefileArgs{PREREQ_PM}          ||= deps('configure', 'build', 'test', 'runtime');	
}

{
	my ($minperl) = reverse sort(
		grep defined && /^[0-9]+(\.[0-9]+)?$/,
		map $meta->{prereqs}{$_}{requires}{perl},
		qw( configure build runtime )
	);
	
	if (defined($minperl))
	{
		die "Installing $meta->{name} requires Perl >= $minperl"
			unless $] >= $minperl;
		
		$WriteMakefileArgs{MIN_PERL_VERSION} ||= $minperl
			if $EUMM >= 6.48;
	}
}

sub FixMakefile
{
	return unless -d 'inc';
	my $file = shift;
	
	local *MAKEFILE;
	open MAKEFILE, "< $file" or die "FixMakefile: Couldn't open $file: $!; bailing out";
	my $makefile = do { local $/; <MAKEFILE> };
	close MAKEFILE or die $!;
	
	$makefile =~ s/\b(test_harness\(\$\(TEST_VERBOSE\), )/$1'inc', /;
	$makefile =~ s/( -I\$\(INST_ARCHLIB\))/ -Iinc$1/g;
	$makefile =~ s/( "-I\$\(INST_LIB\)")/ "-Iinc"$1/g;
	$makefile =~ s/^(FULLPERL = .*)/$1 "-Iinc"/m;
	$makefile =~ s/^(PERL = .*)/$1 "-Iinc"/m;
	
	open  MAKEFILE, "> $file" or die "FixMakefile: Couldn't open $file: $!; bailing out";
	print MAKEFILE $makefile or die $!;
	close MAKEFILE or die $!;
}

use File::ShareDir::Install;
install_share 'share';
{ package MY; use File::ShareDir::Install qw(postamble) };

my $mm = WriteMakefile(%WriteMakefileArgs);
FixMakefile($mm->{FIRST_MAKEFILE} || 'Makefile');
exit(0);

