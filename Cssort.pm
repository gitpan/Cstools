
=head1 NAME

Cssort -- Czech sort

=head1 DESCRIPTION

Implements czech sorting conventions, indepentent on locales, which
are often corrupt. Strings are converted to internal 7-bit form and then
normal Perl's B<sort> routine is called. This should work regardless on
locales in effect.

The only function provided by this module is B<cssort>. It works on list
of strings and returns that list, hmm, sorted.

=head1 VERSION

0.6

=head1 SEE ALSO

perl(1).

=head1 DESCRIPTION

(c) 1997 Jan Pazdziora, adelton@fi.muni.cz

at Faculty of Informatics, Masaryk University, Brno

=cut

package Cssort;
use Exporter;
@ISA = qw( Exporter );
@EXPORT = qw( cssort );

$VERSION = '0.6';
sub Version     { $VERSION; }

$DEBUG = 0;

my @def_table = (
	'aA áÁ äÄ',	'bB',		'cC',		'èÈ',
	'dD ïÏ',	'eE éÉ ìÌ',	'fF',		'gG',
	'hH',		'<ch><Ch><CH>',	'iI íÍ',	'jJ',
	'kK',		'lL åÅ µ¥',	'mM',		'nN òÒ',
	'oO óÓ ôÔ öÖ',	'pP',		'qQ',		'rR àÀ',
	'øØ',		'sS',		'¹©',		'tT »«',
	'uU úÚ ùÙ üÜ',	'vV',		'wW',		'xX',
	'yY ýÝ',	'zZ',		'¾®',
	'0_',		'1',		'2',		'3',
	'4',		'5',		'6',		'7',
	'8',		'9',
	' .,;?!:"`\'',
	' /|\\()[]<>{}',
	' @&%#^',
	' =+*',
	);

my @multiple = ( {}, {}, {}, {} );
my @table = ( );
my @regexp = ( '', '', '', '' );

sub make_table
	{
	my $level = shift;
	@{$table[$level]} = ( '' ) x 256;

	my ($leader, $index) = ('', 0);
	my $irow = 0;
	while (defined $def_table[$irow])
		{
		my $row = $def_table[$irow];
		next if ($row =~ s/^ // and $level < 3);
		my $newleader = substr $row, 0, 1;
		next unless defined $newleader;
		if ($newleader ne $leader and $newleader ne '<' and $newleader =~ /^[\040-\177]$/)
			{
			if ($index == 1)
				{
				for (@just_done)
					{
					if (length $_ > 1)
						{ ${$multiple[$level]}{$_} = $leader; }
					else
						{ $table[$level][ ord $_ ] = $leader; }
					}
				}
			@just_done = ();
			if ($newleader !~ /^[a-z]$/)
				{
				if ($leader =~ /^[A-Z]$/)
					{ $leader++; }
				else
					{ $leader = 'a'; }
				}
			else
				{ $leader = "\U$newleader"; }
			$index = 0;
			$value = $leader . $index;
			}
		while ($row ne '')
			{
			my $key;
			if ($row =~ s/^<([cC].*?)>//s)
				{ $key = $+; }
			else
				{ $row =~ s/^.//s; $key = $&; }
			if (length $key > 1)
				{
				${$multiple[$level]}{$key} = $value;
				$regexp[$level] .= '|' . $key;
				push @just_done, $key;
				}
			else
				{
				$table[$level][ ord $key ] = $value;
				push @just_done, $key;
				}
			
			if (($row =~ s/^\s+// and $level >= 1) or $level >= 2)
				{
				$index++;
				$value = $leader . $index;
				}
			}
		$index++;
		$value = $leader . $index;
		}
	continue
		{
		$irow++;
		}
	if ($regexp[$level] ne '')
		{ $regexp[$level] =~ s/^\|/(/; $regexp[$level] .= '|.)'; }
	else
		{ $regexp[$level] = '.'; }

	return;
	do
		{
		print "regexp[$level]: $regexp[$level]\n";
		for (sort keys %{$multiple[$level]})
			{ print "MULT: $_:${$multiple[$level]}{$_}\t"; }
		print "\n";
		for ( 0 .. 255 )
			{ print chr $_, ":$table[$level][$_]\t" if $table[$level][$_] ne ''; }
		print "\n";
		} if $DEBUG;
	}

sub prepare_data
	{
	my ($word, $level) = (shift, shift);
	if (not defined $table[$level])
		{ make_table($level); }
	if ($level <= 1)
		{
		my $list = [];
		for (split /\s+/, $word)
			{
			s/$regexp[$level]/(defined ${$multiple[$level]}{$&} and ${$multiple[$level]}{$&}) or $table[$level][ord $&]/ges;
			push @$list, $_;
			}
		return $list;
		}
	else
		{
		$word =~ s/$regexp[$level]/defined ${$multiple[$level]}{$&} and ${$multiple[$level]}{$&} or $table[$level][ord $&]/ges;
		return $word;
		}
	}
sub compare
	{
	my ($x, $y, $level) = @_;
	if ($level <= 1)
		{
		my $i = 0;
		my $result = 0;
		while (1)
			{
			if (not defined $x->[$i])
				{
				return 0 if not defined $y->[$i];
				return -1;
				}
			else
				{
				return 1 if not defined $y->[$i];
				$result = $x->[$i] cmp $y->[$i];
				return $result if $result;
				}
			$i++;
			}

		}
	else
		{ return $x cmp $y; }
	}
sub cssort
	{
	map { $_->[0] }
		sort {
			my $level;
			for $level (0 .. 3)
				{
				$a->[$level + 1] = prepare_data($a->[0], $level)
					unless defined $a->[$level + 1];
				$b->[$level + 1] = prepare_data($b->[0], $level)
					unless defined $b->[$level + 1];
				my $result = compare($a->[$level + 1],
					$b->[$level + 1], $level);
				return $result if $result;
				}
			return 0;
				}
				map { [ $_ ] } @_;
	}

1;

__END__

