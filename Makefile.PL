use ExtUtils::MakeMaker;
WriteMakefile(
	NAME		=> 'Cz',
	VERSION		=> '0.05',
	EXE_FILES	=> [ 'cstocs' ],
	DISTNAME	=> 'Cstools',
	dist		=> { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
