
use Config;

use ExtUtils::MakeMaker;

my $VERSION = '0.172';

sub MY::dist {
	package MY; # so that "SUPER" works right
	my $inherited = shift->SUPER::dist(@_);
	$inherited =~ s/old text/new text/;
	$inherited;
	}

sub MY::postamble {
	"
specversion: Makefile.PL Cstools.spec.dist
	\@\$(PERL) -pe 's/__VERSION__/$VERSION/' Cstools.spec.dist > Cstools.spec

rpm: dist
	rpm -tb -vv ../\$(DISTNAME)-\$(VERSION).tar.gz
";

	}

WriteMakefile(
	NAME		=> 'Cz',
	DISTNAME	=> 'Cstools',
	VERSION		=> $VERSION,
	PL_FILES	=> { 'bin/cstocs.PL' => 'bin/cstocs',
					'bin/cssort.PL' => 'bin/cssort' },
	EXE_FILES	=> [ 'bin/cstocs', 'bin/cssort' ],
	dist		=> { COMPRESS => 'gzip -9f', SUFFIX => 'gz',
		POSTOP => 'mv $(DISTNAME)-$(VERSION).tar.gz ../' },
	clean		=> { FILES => 'bin/cstocs bin/cssort' },
	macro		=> { DIST_DEFAULT => 'specversion tardist', },
	);

