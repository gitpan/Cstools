
# Cstocs.pm

BEGIN { $| = 1; print "1..5\n"; }
END {print "not ok 1\n" unless $loaded_cstocs;}


BEGIN { print "Loading module Cstocs\n"; }

use Cstocs;
$loaded_cstocs = 1;
print "ok 1\n";


print "Creating new Cstocs object\n";

my $il2_to_ascii = new Cstocs 'il2', 'ascii';
print "not " unless defined $il2_to_ascii;
print "ok 2\n";


print "Converting a string 'je¾eèek nelétá' to plain ascii\n";

my $result1 = &$il2_to_ascii('je¾eèek nelétá');
print "not " if $result1 ne "jezecek neleta";
print "ok 3\n";

print "Got '$result1'\n";


print "Now using a method call\n";

my $result2 = $il2_to_ascii->conv('je¾eèek nelétá');
print "not " if $result2 ne "jezecek neleta";
print "ok 4\n";

print "Got '$result2'\n";


print "Calling the external cstocs program\n";

use ExtUtils::testlib;
my $libs = join " -I", '', @INC;
my $result3 = `echo "je¾eèek" | $^X $libs ./cstocs il2 ascii`;
print "not " if $result3 ne "jezecek\n";
print "ok 5\n";

print "Got '$result3'\n";

