
###
# Cz::Cstocs.pm

BEGIN { $| = 1; print "1..6\n"; }
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
print "not " if $result1 ne "jezecek neleta";
print "ok 3\n";

print "Got '$result1'\n";

###

print "Now using a method call\n";

my $result2 = $il2_to_ascii->conv('je¾eèek nelétá');
print "not " if $result2 ne "jezecek neleta";
print "ok 4\n";

print "Got '$result2'\n";

###

print "Calling the external cstocs program\n";

use ExtUtils::testlib;
my $libs = join " -I", '', @INC;
my $result3 = `echo "je¾eèek" | $^X $libs blib/script/cstocs il2 ascii`;
print "not " if $result3 ne "jezecek\n";
print "ok 5\n";

print "Got '$result3'\n";

###

print "And once more, for the bug that was fixed in 3.07\n";

my $result4 = `perl -e 'print pack("C",253);' | $^X $libs blib/script/cstocs pc2 il2`;
print "not " if $result4 ne "ø";
print "ok 6\n";

print "Got '$result4'\n";
