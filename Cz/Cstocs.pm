
=head1 NAME

Cz::Cstocs - conversions of charset encodings for the Czech language

=head1 SYNOPSIS

	use Cz::Cstocs;
	my $il2_to_ascii = new Cz::Cstocs 'il2', 'ascii';
	while (<>)
		{ print &$il2_to_ascii($_); }

=head1 DESCRIPTION

This module helps in converting texts between various charset
encodings, used for Czech and Slovak languages. The instance of the
object B<Cz::Cstocs>, taking two parameters for input and output encoding,
can be afterwards used as a function reference to convert strings. For
backward compatibility, method I<conv> is supported as well, so the
example above could also read

	while (<>)
		{ print $il2_to_ascii->conv($_); }

The conversion function takes string and returns string.

The encoding files are in the F<Cz/Cstocs/enc> directory but this
location can be changed with the I<CSTOCSDIR> environment variable.

=head1 AUTHOR

Jan Pazdziora, adelton@fi.muni.cz, created the module version.

Jan "Yenya" Kasprzak has done the original Un*x implementation.

=head1 VERSION

3.13

=head1 SEE ALSO

cstocs(1), perl(1).

=cut


package Cz::Cstocs;

no strict;
use vars qw($VERSION $DEBUG $DEFAULTCSTOCSDIR $cstocsdir $fillstring
	$use_accent $one_by_more);

$VERSION = '3.13';

$DEBUG = 0 unless defined $DEBUG;
sub DEBUG ()	{ $DEBUG; }

# Where to get the encoding files from

# Either look at the environment variable
if (defined $ENV{'CSTOCSDIR'})
	{
	$cstocsdir = $ENV{'CSTOCSDIR'};
	print STDERR "Using enc-dir $cstocsdir from the CSTOCSDIR env-var\n"
		if DEBUG;
	}
# Or take the encoding files from the Perl tree
elsif (defined $INC{'Cz/Cstocs.pm'})
	{
	$DEFAULTCSTOCSDIR = $INC{'Cz/Cstocs.pm'};
	$DEFAULTCSTOCSDIR =~ s!\.pm$!/enc!;
	print STDERR "Using enc-dir $DEFAULTCSTOCSDIR from \@INC\n"
		if DEBUG;
	}
# Or fail back to default
else
	{
	$DEFAULTCSTOCSDIR = '/packages/share/cstocs/lib';
	}

$cstocsdir = $DEFAULTCSTOCSDIR unless defined $cstocsdir;

# These options can be changed for different behavior
$fillstring = ' ' unless defined $fillstring;
$use_accent = 1 unless defined $use_accent;
$one_by_more = 1 unless defined $one_by_more;

# Hash that holds the accent file
my %accent = ();

sub load_encoding
	{
	my $enc = shift;
	my $varname = "enc_$enc";
	return if defined @{$varname};

	my $file = "$cstocsdir/$enc.enc";
	open FILE, $file or die "Error reading $file: $!\n";
	print STDERR "Parsing encoding file $file\n" if DEBUG;
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
	print STDERR "Parsing accent file $file\n" if DEBUG;
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
	print STDERR "Loading Cz::Cstocs for $inputenc, $outputenc\n" if DEBUG;

	my (%options) = @_;

	my ($inputname, $outputname) = ('enc_' . $inputenc, 'enc_' .  $outputenc);
	load_encoding($inputenc) unless defined @{$inputname};
	load_encoding($outputenc) unless defined %{$outputname};
	load_accent() if $use_accent and not keys %accent;

	my $one_by_one = 1;
	my $i;
	my ($srcstr, $dststr, @convert) = ('', '', ());

	for ($i = 0; $i <= $#{$inputname}; $i++)
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
		$fn = eval qq!sub { local (\$_) = shift; tr/$srcstr/$dststr/; \$_; };!;
		do {
			chomp $@;
			die "$@, line ", __LINE__, "\n";
			} if $@;
		}
	else
		{
		my $convname = 'conv_' . $inputenc . '_' . $outputenc;
		@{$convname} = @convert;
		$fn = eval qq!sub { local (\$_) = shift; s/[$srcstr]/ \${$convname}[ord \$&] /sge; \$_ };!;
		do {
			chomp $@;
			die "$@, line ", __LINE__, "\n"
			} if $@;
		}
	bless $fn, $class;
	$fn;
	}
sub conv
	{
	my $self = shift;
	return &$self($_[0]);
	}
sub available_enc
	{
	opendir DIR, $cstocsdir or die "Error reading $cstocsdir\n";
	my @list = sort map { s/\.enc$//; $_ } grep { /\.enc$/ } readdir DIR;
	closedir DIR;
	return @list;
	}

1;


