
# Cz::Sort.pm

BEGIN { $| = 1; print "1..7\n"; }
END {print "not ok 1\n" unless $loaded_czsort;}

my $testnum = 1;
sub test
	{
	my $result = shift;
	print "not " if not defined $result or not $result;
	print "ok $testnum\n";
	$testnum++;
	}

BEGIN { print "Loading module Cz::Sort\n"; }

use Cz::Sort;
$loaded_czsort = 1;
test(1);

print "Testing czcmp\n";

my $sorttab = 'sort.tab';
$sorttab = 't/' . $sorttab if -d 't';

open FILE, $sorttab or die "Error reading $sorttab: $!\n";
my (@in, @goodout);
my $in = 0;
while (<FILE>)
	{
	chomp;
	if (/^---INPUT---$/)	{ @in = (); $in = 1; }
	elsif (/^---OUTPUT---$/)	{ @goodout = (); $in = 0; }
	elsif (/^---DONE---$/)
		{
		my $sorted = join "; ", czsort @in;
		my $expect = join "; ", @goodout;
		print "Expecting $expect\nGot $sorted\n";
		test($sorted eq $expect);
		$in = 1;
		}
	elsif ($in)
		{ push @in, $_; }
	else
		{ push @goodout, $_; }
	}

