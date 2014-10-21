
# Cssort.pm

BEGIN { $| = 1; print "1..5\n"; }
END {print "not ok 1\n" unless $loaded_cssort;}


BEGIN { print "Loading module Cssort\n"; }

use Cssort;
$loaded_cssort = 1;
print "ok 1\n";


print "Testing cscmp\n";

print "not " if cscmp("_x j&�", "_&") != 1;
print "ok 2\n";

print "not " if cscmp("placka x", "pl�cka g_&") != -1;
print "ok 3\n";


my @in = qw( plachta platno plṻ platnost Pl�ni�ka pl�n� plagi�t
	pl�ni�ka plankton pl�tno pl�t plat pla�ka );
my @good_out = qw( plagi�t plachta pl�n� pl�ni�ka Pl�ni�ka pla�ka plankton
	plṻ plat pl�t platno pl�tno platnost );

print "Sorting the list: @in\n";
print "Expecting: @good_out\n";

my @out = cssort(@in);

print "Got: @out\n";

my $sort_ok = 1;
my $i;
for $i ( 0 .. $#out )
	{
	if ($out[$i] ne $good_out[$i])
		{ $sort_ok = 0; }
	}
print "not " if $sort_ok == 0;
print "ok 4\n";


@in = ('abc fr�za�e', 'ABC n�stroj��e', 'ABC', 'a', 'abc', 'abc n�stroj��e');
@good_out = ('a', 'abc', 'ABC', 'abc fr�za�e', 'abc n�stroj��e', 'ABC n�stroj��e');

print "Sorting the list: @in\n";
print "Expecting: @good_out\n";

@out = cssort(@in);

print "Got: @out\n";

$sort_ok = 1;
for $i ( 0 .. $#out )
	{
	if ($out[$i] ne $good_out[$i])
		{ $sort_ok = 0; }
	}
print "not " if $sort_ok == 0;
print "ok 5\n";

