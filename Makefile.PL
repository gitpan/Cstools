use ExtUtils::MakeMaker;
WriteMakefile(
	NAME		=> 'Cz',
	VERSION		=> '0.05_02',
	PL_FILES	=> { 'bin/cstocs.PL' => 'bin/cstocs' },
	EXE_FILES	=> [ 'bin/cstocs' ],
	DISTNAME	=> 'Cstools',
	dist		=> { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
