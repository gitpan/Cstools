
if (eval 'use Cstocs' eq '')
	{
	print <<EOF;
	You seem to have the module Cstocs installed. Since this
	module Cz::Cstocs is supported now instead, you might want
	to erase the old one (Cstocs), once your scripts are converted
	to use the new names.
EOF
	}

use ExtUtils::MakeMaker;
WriteMakefile(
	NAME		=> 'Cz',
	VERSION		=> '0.08',
	PL_FILES	=> { 'bin/cstocs.PL' => 'bin/cstocs' },
	EXE_FILES	=> [ 'bin/cstocs' ],
	DISTNAME	=> 'Cstools',
	dist		=> { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
