
=head1 NAME

Cstocs -- module for conversions between commonly used charset
	encodings of the Czech and Slovak languages.

=head1 SYNOPSIS

	use Cstocs;
	my $il2_to_ascii = new Cstocs 'il2', 'ascii';
	while (<>)
		{ print &$il2_to_ascii($_); }

=head1 DESCRIPTION

This module helps in converting texts between various charset
encodings, used for Czech and Slovak languages. The instance of the
object C<Cstocs>, taking two parameters for input and output encoding,
can be afterwards used as a function reference to convert strings. For
backward compatibility, also a method C<conv> is supported, so the
example above could also read

	while (<>)
		{ print $il2_to_ascii->conv($_); }


=head1 AUTHOR

Jan Pazdziora, adelton@fi.muni.cz created the module version.

Jan "Yenya" Kasprzak has done the original Un*x implementation.

=head1 VERSION

3.03

=head1 SEE ALSO

cstocs(1), perl(1).

=cut


package Cstocs;

no strict;
use vars qw($VERSION $DEBUG $DEFAULTCSTOCSDIR);

$VERSION = '3.03';

$DEBUG = 0;

# Directory that contains the encoding files
$DEFAULTCSTOCSDIR = '/packages/share/cstocs/lib';

# We will try to use the encoding files in the Perl directory tree
if (defined $INC{'Cstocs.pm'})
	{
	$DEFAULTCSTOCSDIR = $INC{'Cstocs.pm'};
	$DEFAULTCSTOCSDIR =~ s!Cstocs.pm$!Cstocs/enc!;
	print STDERR "Using enc-dir $DEFAULTCSTOCSDIR from \@INC\n"
		if $DEBUG;
	}

my $cstocsdir = $DEFAULTCSTOCSDIR;
if (defined $ENV{'CSTOCSDIR'})
	{
	$cstocsdir = $ENV{'CSTOCSDIR'};
	print STDERR "Using enc-dir $cstocsdir from the CSTOCSDIR env-var\n"
		if $DEBUG;
	}

my %accent = ();
my $fillstring = ' ';
my $use_accent = 1;
my $one_by_more = 1;

sub load_encoding
	{
	my $enc = shift;
	my $varname = "enc_$enc";
	return if defined @{$varname};

	my $file = "$cstocsdir/$enc.enc";
	open FILE, $file or die "Error reading $file: $!\n";
	print STDERR "Parsing encoding file $file\n" if $DEBUG;
	while (<FILE>)
		{
		next if /^#/;
		my ($number, $desc) = /(\d+)\s+(\S+)/;
		if (not defined $desc and /./)
			{ warn "Syntax error in $file at line $.\n"; }
		${$varname}[$number] = $desc;
		${$varname}{$desc} = $number;
		}
	close FILE;
	}
sub load_accent
	{
	my $file = "$cstocsdir/accent";
	open FILE, $file or die "Error reading $file: $!\n";
	print STDERR "Parsing accent file $file\n" if $DEBUG;
	while (<FILE>)
		{
		next if /^#/;
		my ($key, $val) = /(\S+)\s+(\S+)/;
		unless (defined $val)
			{ warn "Syntax error in $file at line $.\n"; }
		$accent{$key} = $val
			if (length $val == 1 or $one_by_more);
		}
	close FILE;
	}
sub new
	{
	my $class = shift;
	my ($inputenc, $outputenc) = (shift, shift);
	print STDERR "Loading Cstocs for $inputenc, $outputenc\n" if $DEBUG;

	my (%options) = @_;

	my ($inputname, $outputname) = ('enc_' . $inputenc, 'enc_' .  $outputenc);
	load_encoding($inputenc) unless defined @{$inputname};
	load_encoding($outputenc) unless defined %{$outputname};
	load_accent() if $use_accent and not keys %accent;

	my $one_by_one = 1;
	my $i;
	my ($srcstr, $dststr, @convert) = ('', '', ());

	for ($i = 0; $i < $#{$inputname}; $i++)
		{
		my $key = ${$inputname}[$i];
		if (not defined $key)	{ next; }

		my $outputkey = ${$outputname}{$key};
		if (defined $outputkey)
			{
			if ($outputkey != $i)
				{
				$srcstr .= chr $i;
				my $outchar = chr $outputkey;
				$dststr .= $outchar;
				$convert[$i] = $outchar;
				}
			next;
			}
		my $accentval = $accent{$key};
		if (defined $accentval)
			{
			if (chr $i ne $accentval)
				{
				$srcstr .= chr $i;
				$dststr .= $accentval;
				$convert[$i] = $accentval;
				$one_by_one = 0 if (length $accentval != 1);
				}
			}
		elsif (chr $i ne $fillstring)
			{
			$srcstr .= chr $i;
			$dststr .= $fillstring;
			$convert[$i] = $fillstring;
			$one_by_one = 0 if (length $fillstring != 1);
			}
		}

	$srcstr = "\Q$srcstr";
	my $fn;
	if ($one_by_one)
		{
		$dststr = "\Q$dststr";
		$fn = eval qq!sub { my \$e = shift; \$e =~ tr/$srcstr/$dststr/; \$e; };!;
		}
	else
		{
		my $convname = 'conv_' . $inputenc . '_' . $outputenc;
		@{$convname} = @convert;
		$fn = eval qq!sub { my \$e = shift; \$e =~ s/[$srcstr]/ \${$convname}[ord \$&] /sge; \$e; };!;
		}
	bless $fn, $class;
	$fn;
	}
sub conv
	{
	my $self = shift;
	return &$self($_[0]);
	}

1;

__END__

