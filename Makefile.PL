use ExtUtils::MakeMaker;
WriteMakefile(
	NAME		=> 'Cstools',
	VERSION		=> '0.03',
	PMLIBDIRS	=> [ 'Cstocs/enc' ],
	EXE_FILES	=> [ 'cstocs' ],
	dist		=> { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
