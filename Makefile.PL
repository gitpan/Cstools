
use Config;

eval 'use Cstocs';
if ($@ eq '')
	{
	my $cstocs = $INC{"Cstocs.pm"};
	my $cstocsdir = $cstocs;
	$cstocsdir =~ s!.pm$!!;
	my $cssort = $cstocs;
	$cssort =~ s!Cstocs.pm$!Cssort.pm!;
	if (-f $cstocs or -d $cstocsdir or -f $cssort)
		{
		$cstocs = ( -f $cstocs ? "\nrm $cstocs" : "" );
		$cstocsdir = ( -d $cstocsdir ? "\nrm -rf $cstocsdir" : "" );
		$cssort = ( -f $cssort ? "\nrm $cssort" : "" );
		$mancstocs = "$Config{installman3dir}/Cstocs.3";
		$mancstocs = ( -f $mancstocs ? "\nrm $mancstocs" : "" );
		$mancssort = "$Config{installman3dir}/Cssort.3";
		$mancssort = ( -f $mancssort ? "\nrm $mancssort" : "" );
		print <<EOF;
	You seem to have the old Cstools package installed, using different
	namespace (Cstocs instead of Cz::Cstocs). You might want to delete
	the old modules, once your scripts use the new concept.
### These Unix command(s) should do the job:${cstocs}${cstocsdir}${cssort}${mancstocs}${mancssort}
EOF
		}
	}

use ExtUtils::MakeMaker;

WriteMakefile(
	NAME		=> 'Cz',
	DISTNAME	=> 'Cstools',
	VERSION		=> '0.155',
	PL_FILES	=> { 'bin/cstocs.PL' => 'bin/cstocs',
					'bin/cssort.PL' => 'bin/cssort' },
	EXE_FILES	=> [ 'bin/cstocs', 'bin/cssort' ],
	dist		=> { COMPRESS => 'gzip -9f', SUFFIX => 'gz',
		POSTOP => 'mv $(DISTNAME)-$(VERSION).tar.gz ../' },
	clean		=> { FILES => 'bin/cstocs bin/cssort' },
);

