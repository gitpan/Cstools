use ExtUtils::MakeMaker;
WriteMakefile(
	'NAME'	=> 'Cstools',
	'VERSION' => '0.02_01',
	'PMLIBDIRS' => [ 'Cstocs/enc' ],
	'EXE_FILES' => [ 'cstocs' ],
);
