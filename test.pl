
BEGIN { $| = 1; print "1..7\n"; }

END {print "not ok 5\n" unless $loaded_cssort;}
END {print "not ok 1\n" unless $loaded_cstocs;}

#
# Cstocs.pm
#
# loading the module Cstocs.pm

use Cstocs;
$loaded_cstocs = 1;
print "ok 1\n";

# creating the object

my $il2_to_ascii = new Cstocs 'il2', 'ascii';
print "not " unless defined $il2_to_ascii;
print "ok 2\n";

# converting a string

my $result1 = &$il2_to_ascii('je¾eèek nelétá');
print "not " if $result1 ne "jezecek neleta";
print "ok 3\n";

# calling the external cstocs program

use ExtUtils::testlib;
my $libs = join " -I", '', @INC;
my $result2 = `echo "je¾eèek" | $^X $libs ./cstocs il2 ascii`;
print "not " if $result2 ne "jezecek\n";
print "ok 4\n";

#
# Cssort.pm
#
# loading the module Cssort.pm

use Cssort;
$loaded_cssort = 1;
print "ok 5\n";

# sort the list

my @in = qw( plachta platno plá¹» platnost Plánièka plánì plagiát
	plánièka plankton plátno plát plat plaòka );
my @good_out = qw( plagiát plachta plánì plánièka Plánièka plaòka plankton
	plá¹» plat plát platno plátno platnost );
my @out = cssort(@in);
my $sort_ok = 1;
my $i;
for $i ( 0 .. $#out )
	{
	if ($out[$i] ne $good_out[$i])
		{ $sort_ok = 0; }
	}
print "not " if $sort_ok == 0;
print "ok 6\n";

@in = ('abc frézaøe', 'ABC nástrojáøe', 'ABC', 'a', 'abc', 'abc nástrojáøe');
@good_out = ('a', 'abc', 'ABC', 'abc frézaøe', 'abc nástrojáøe', 'ABC nástrojáøe');
my @out = cssort(@in);
$sort_ok = 1;
$i;
for $i ( 0 .. $#out )
	{
	if ($out[$i] ne $good_out[$i])
		{ $sort_ok = 0; }
	}
print "not " if $sort_ok == 0;
print "ok 7\n";



