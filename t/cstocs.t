
###
# Cz::Cstocs.pm

BEGIN { $| = 1; print "1..15\n"; }
END {print "not ok 1\n" unless $loaded_cstocs;}

###

BEGIN { print "Loading module Cz::Cstocs\n"; }

use Cz::Cstocs;
$loaded_cstocs = 1;
print "ok 1\n";

###

print "Creating new Cz::Cstocs object\n";

my $il2_to_ascii = new Cz::Cstocs 'il2', 'ascii';
print "not " unless defined $il2_to_ascii;
print "ok 2\n";

###

print "Converting a string 'je¾eèek nelétá' to plain ascii\n";

my $result1 = &$il2_to_ascii('je¾eèek nelétá');
print "Got '$result1'\n";

print "not " if $result1 ne "jezecek neleta";
print "ok 3\n";

###

print "Now using a method call\n";

my $result2 = $il2_to_ascii->conv('je¾eèek nelétá');
print "Got '$result2'\n";

print "not " if $result2 ne "jezecek neleta";
print "ok 4\n";

###

print "Calling the external cstocs program\n";

use ExtUtils::testlib;
my $libs = join " -I", '', @INC;
my $result3 = `echo "je¾eèek" | $^X $libs blib/script/cstocs il2 ascii`;
print "Got '$result3'\n";

print "not " if $result3 ne "jezecek\n";
print "ok 5\n";

###

print "And once more, for the bug that was fixed in 3.07\n";

my $result4 = `echo "\375" | $^X $libs blib/script/cstocs pc2 il2`;
print "Got '$result4'\n";

print "not " if $result4 ne "ø\n";
print "ok 6\n";

###

print "Converting a list 'je¾eèek', 'nelétá' to plain ascii\n";

my $result5 = join ';', &$il2_to_ascii('je¾eèek', 'nelétá');
print "Got '$result5'\n";

print "not " if $result5 ne "jezecek;neleta";
print "ok 7\n";

###

print "Converting ascii to ascii\n";

my $ascii_to_ascii = new Cz::Cstocs 'ascii', 'ascii';
print "not " if not defined $ascii_to_ascii;
print "ok 8\n";

my $result6 = $ascii_to_ascii->conv("jezecek neleta");
print "Got '$result6'\n";

print "not " if $result6 ne "jezecek neleta";
print "ok 9\n";

###

print "Converting tex to il2\n";

my $tex_to_il2 = new Cz::Cstocs 'tex', 'il2';
print "not " if not defined $tex_to_il2;
print "ok 10\n";

print "Expecting èástka; je¾eèek; píseò; ae\n";
my $result7 = $tex_to_il2->conv("\\v c\\'astka; je\\v{z}e\\v cek; p\\'{\\i}se\\v n; \\ae");
print "Got '$result7'\n";

print "not " if $result7 ne "èástka; je¾eèek; píseò; ae";
print "ok 11\n";

###

print "Converting tex to il2 (use_accent = 0; nochange)\n";

$tex_to_il2 = new Cz::Cstocs 'tex', 'il2', 'use_accent' => 0;
print "not " if not defined $tex_to_il2;
print "ok 12\n";

print "Expecting \\ae -> \\ae\n";
my $result8 = $tex_to_il2->conv("\\ae");
print "Got '$result8'\n";

print "not " if $result8 ne "\\ae";
print "ok 13\n";

###

print "Converting il2 to tex\n";


$il2_to_tex = new Cz::Cstocs 'il2', 'tex';
print "not " if not defined $il2_to_tex;
print "ok 14\n";

print "Expecting \\v z\\'\\i{}\\v zala\n";
my $result9 = $il2_to_tex->conv("¾í¾ala");
print "Got '$result9'\n";

print "not " if $result9 ne "\\v z\\'\\i{}\\v zala";
print "ok 15\n";

