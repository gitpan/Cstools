
# Cssort.pm

BEGIN { $| = 1; print "1..5\n"; }
END {print "not ok 1\n" unless $loaded_cssort;}


BEGIN { print "Loading module Cssort\n"; }

use Cssort;
$loaded_cssort = 1;
print "ok 1\n";


print "Testing cscmp\n";

print "not " if cscmp("_x j&á", "_&") != 1;
print "ok 2\n";

print "not " if cscmp("placka x", "plácka g_&") != -1;
print "ok 3\n";


my @in = qw( plachta platno plá¹» platnost Plánièka plánì plagiát
	plánièka plankton plátno plát plat plaòka );
my @good_out = qw( plagiát plachta plánì plánièka Plánièka plaòka plankton
	plá¹» plat plát platno plátno platnost );

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


@in = ('abc frézaøe', 'ABC nástrojáøe', 'ABC', 'a', 'abc', 'abc nástrojáøe');
@good_out = ('a', 'abc', 'ABC', 'abc frézaøe', 'abc nástrojáøe', 'ABC nástrojáøe');

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

