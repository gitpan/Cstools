
=head1 NAME

Cz::Cstocs - conversions of charset encodings for the Czech language

=head1 SYNOPSIS

	use Cz::Cstocs;
	my $il2_to_ascii = new Cz::Cstocs 'il2', 'ascii';
	while (<>)
		{ print &$il2_to_ascii($_); }


	use Cz::Cstocs 'il2_ascii';
	while (<>)
		{ print il2_ascii($_); }

=head1 DESCRIPTION

This module helps in converting texts between various charset
encodings, used for Czech and Slovak languages. The instance of the
object B<Cz::Cstocs> is created using method B<new>. It takes at
least two parameters for input and output encoding and can be
afterwards used as a function reference to convert strings/lists.
For backward compatibility, method I<conv> is supported as well,
so the example above could also read

	while (<>)
		{ print $il2_to_ascii->conv($_); }

The conversion function takes a list and returns list of converted
strings (in the list context) or one string consisting of concatenated
results (in the scalar context).

You can modify the behaviour of the conversion function by specifying
hash of other options after the encoding names in call to B<new>.

=over 4

=item fillstring

Gives alternate string that will replace characters from input
encoding that are not present in the output encoding. Default is
space.

=item use_accent

Defines whether the accent file should be used. Default is 1 (true).

=item nofillstring

When 1 (true), will keep characters that do not have friends in
accent nor output encoding, will no replace them with fillstring.
Default is 0 except for tex, because you probably rather want to keep
backslashed symbols than loose them.

=item cstocsdir

Alternate location for encoding and accent files. The default is the
F<Cz/Cstocs/enc> directory in Perl library tree. This location can
also be changed with the I<CSTOCSDIR> environment variable.

=back

There is an alternate way to define the conversion function: any
arguments after use Cz::Cstocs that have form encoding_encoding or
encoding_to_encoding are processed and the appropriate functions are
imported. So,

	use Cz::Cstocs qw(pc2_to_il2 il2_ascii);

define two functions, that are loaded into caller's namespace and
can be used directly. In this case, you cannot specify additional
options, you only have default behaviour.

=head1 AUTHOR

Jan Pazdziora, adelton@fi.muni.cz, created the module version.

Jan "Yenya" Kasprzak has done the original Un*x implementation.

=head1 VERSION

3.162

=head1 SEE ALSO

cstocs(1), perl(1).

=cut



# ##################################
# Here begins the Cz::Cstocs package

package Cz::Cstocs;

use strict;
use Exporter;

use vars qw( $VERSION $DEBUG $cstocsdir @ISA @EXPORT_OK %EXPORT );

@ISA = qw(Exporter);
@EXPORT_OK = ();
%EXPORT = ();

sub import
	{
	my $class = shift;
	my @data = @_;
	if (@data)
		{
		my @avail = Cz::Cstocs->available_enc();
		my $fn;
		for $fn (@data)
			{
			next if grep { $_ eq $fn } @EXPORT_OK;
			my ($in, $out) = $fn =~ /^(.*?)_(?:to_)?(.*)$/;
			next unless defined $out;
			my $fnref = new Cz::Cstocs $in, $out;
			die "Definition of $fn failed\n"
						unless defined $fnref;;
			eval "sub $fn { \$fnref->conv(\@_); }; ";
			if ($@) { die $@; }
			push @EXPORT_OK, $fn;
			$EXPORT{$fn} = 1;
			}
		}
	Cz::Cstocs->export_to_level(1, $class, @data);
	} 

$VERSION = '3.162';

# Debugging option
$DEBUG = 0 unless defined $DEBUG;
sub DEBUG ()	{ $DEBUG; }


# Where to get the encoding files from
# Start with some default
my $defaultcstocsdir = '/packages/share/cstocs/lib';

# Look at the environment variable
if (defined $ENV{'CSTOCSDIR'})
	{
	$defaultcstocsdir = $ENV{'CSTOCSDIR'};
	print STDERR "Using enc-dir $defaultcstocsdir from the CSTOCSDIR env-var\n"
		if DEBUG;
	}
# Or take the encoding files from the Perl tree
elsif (defined $INC{'Cz/Cstocs.pm'})
	{
	$defaultcstocsdir = $INC{'Cz/Cstocs.pm'};
	$defaultcstocsdir =~ s!\.pm$!/enc!;
	print STDERR "Using enc-dir $defaultcstocsdir from \@INC\n"
		if DEBUG;
	}

# We have unless hare because you could have overriden $cstocsdir
$cstocsdir = $defaultcstocsdir unless defined $cstocsdir;


# Hash that holds the accent file and a tag saying if the accent
# file has already been read
my %accent = ();
my $accent_read = 0;

# Input and output hashes
my %input_hashes = ();
my %output_hashes = ();

# Array of regexp parts
my %regexp_matches = ();

# Table of conversion functions, so that we do not need to create them twice
my %functions = ();

# List of diacritics
my @diacritics = qw( abovedot acute breve caron cedilla circumflex
	diaeresis doubleacute ogonek ring );



# ######################################################
# Now, the function -- loading encoding and accent files

# Filling input and output_hashes tables for given encoding
sub load_encoding
	{
	my $enc = shift;
	return if defined $input_hashes{$enc};	# has already been loaded

	my $file = "$cstocsdir/$enc.enc";
	open FILE, $file or die "Error reading $file: $!\n";
	print STDERR "Parsing encoding file $file\n" if DEBUG;

	my ($input, $output) = ({}, {});	# just speedup thing
	local $_;
	while (<FILE>)
		{
		next if /^(#|\s*$)/;
		my ($tag, $desc) = /^\s*(\S+)\s+(\S+)\s*$/;
		unless (defined $tag and defined $desc)
			{
			chomp;
			warn "Syntax error in $file at line $: `$_'.\n";
			next;
			}
		if ($tag =~ /^\d+|0x\d+$/)
			{
			$tag = oct $tag if $tag =~ /^0/;
			$tag = pack "C", $tag;
			}
		$input->{$tag} = $desc;
		$output->{$desc} = $tag
				unless defined $output_hashes{$enc}{$desc};
		}
	close FILE;

	$input_hashes{$enc} = $input;
	$output_hashes{$enc} = $output;

	if ($enc eq "tex")
		{ fixup_tex_encoding(); }
	}

sub fixup_tex_encoding
	{
	my $tag;
	
	print STDERR "Doing tex fixup\n" if DEBUG;
	
	my $input = $input_hashes{"tex"};
	my $output = $output_hashes{"tex"};

	# we need this to fill the defaults
	load_encoding('ascii');
	my $asciiref = $output_hashes{'ascii'};
	for $tag (keys %$asciiref)
		{ $output->{$tag} = $asciiref->{$tag}
			unless defined $output->{$tag}; }

	my %processed = ();

	my (@dialetters, @dianonletters, @nondialetters, @nondianonletters);
	my (@inputs) = keys %$input;
	for $tag (@inputs)
		{
		my $value = $input->{$tag};

		my $az = 0;
		$az = 1 if $tag =~ /[a-zA-Z]$/;

		if ($az and $output->{$value} eq $tag)
			{ $output->{$value} = $tag . '{}'; }
		$input->{$tag . ' '} = $value;

		if (grep { $_ eq $value } @diacritics)
			{
			my $e;
			if ($az)
				{
				push @dialetters, $tag;
				for $e ('a'..'h', 'k'..'z', 'A'..'Z')
					{ $output->{$e.$value} = $tag.' '.$e }
				}
			else
				{
				push @dianonletters, $tag;
				for $e ('a'..'h', 'k'..'z', 'A'..'Z')
					{ $output->{$e.$value} = $tag.$e }
				for $e ('a'..'z', 'A'..'Z')
					{ $input->{$tag.$e} = $e.$value; }
				}
			for $e ('i', 'j')
				{ $output->{$e.$value} = $tag.'\\'.$e.'{}' }
			for $e ('a'..'z', 'A'..'Z')
				{ $input->{$tag.' '.$e} = $e.$value; }
			for $e ('i', 'j')
				{
				$input->{$tag.'\\'.$e} = $e.$value;
				$input->{$tag.' \\'.$e} = $e.$value;
				}
			}
		elsif ($az)		{ push @nondialetters, $tag; }
		else			{ push @nondianonletters, $tag; }
		}

	my $regexp = '';

	if (@dialetters)
		{
		$regexp .= join '', '(',
			join('|', map { "\Q$_"; } @dialetters),
				")([ \\t]+[a-zA-Z]|[ \\t]*(\\\\[ij]([ \\t]+(\{\})?|[ \\t]*(\$|\{\}))|{([a-zA-Z]|\\\\[ij][ \\t]*(\{\})?)}))";
		}
	if (@dianonletters)
		{
		$regexp .= '|' if $regexp ne '';
		$regexp .= '(' . join '',
			join('|', map { "\Q$_"; } @dianonletters),
				")[ \\t]*([a-zA-Z]|\\\\[ij]([ \\t]+(\{\})?|[ \\t]*(\$|\{\}))|{([a-zA-Z]|\\\\[ij][ \\t]*(\{\})?)})";
		}
	if (@nondialetters)
		{
		$regexp .= '|' if $regexp ne '';
		$regexp .= '(' . join '',
			join('|', map { "\Q$_"; } @nondialetters),
				")([ \\t]+(\{\})?|[ \\t]*\$)"
		}
	if (@nondianonletters)
		{
		$regexp .= '|' if $regexp ne '';
		$regexp .= '(' . join '',
			join('|', map { "\Q$_"; } @nondianonletters),
				")[ \\t]*(\{\})?"
		}

	$regexp_matches{'tex'} = $regexp;
	1;
	}

# Loading accent file
sub load_accent
	{
	return if $accent_read;
	$accent_read = 1;
	
	my $file = "$cstocsdir/accent";
	open FILE, $file or die "Error reading $file: $!\n";
	print STDERR "Parsing accent file $file\n" if DEBUG;

	local $_;
	while (<FILE>)
		{
		next if /^(#|\s*$)/;
		my ($key, $val) = /^\s*(\S+)\s+(\S+)\s*$/;
		unless (defined $key and defined $val)
			{
			chomp;
			warn "Syntax error in $file at line $: `$_'.\n";
			next;
			}
		$accent{$key} = $val;
		}
	close FILE;
	}


# Constructor -- takes two arguments, input and output encodings,
# a optionally hash of options. Returns reference to code that will
# do the conversion, or undef
sub new
	{
	my $class = shift;
	my ($inputenc, $outputenc) = (shift, shift);

	local $/ = "\n";

	# check input values
	unless (defined $inputenc and defined $outputenc)
		{
		print STDERR "Both input and output encodings must be specified in call to ", __PACKAGE__, "::new\n";
		return;
		}

	# Defaults of options
	my $fillstring = ' ';
	my $use_fillstring = 1;
	my $use_accent = 1;
	my $one_by_one = 0;

	# this is exception for TeX
	$use_fillstring = 0 if $inputenc eq "tex";

	# process additional options
	if (@_)
		{
		print STDERR "Other options: '@_'\n" if DEBUG;
		my $tag;
		while (defined($tag = shift))
			{
			my $value = shift;
			$tag eq 'fillstring' and $fillstring = $value;
			$tag eq 'use_accent' and
				$use_accent = (defined $value ? $value : 0);
			$tag eq 'nofillstring' and
				$use_fillstring = (defined $value ?
					( $value ? 0 : 1) : 0);
			$tag eq 'cstocsdir' and $cstocsdir = $value;	
			}
		}

	# encode settings into the function name
	if (defined $functions{"${inputenc}_${outputenc}_${fillstring}_${use_fillstring}_${use_accent}_${one_by_one}"})
		{ return $functions{"${inputenc}_${outputenc}_${fillstring}_${use_fillstring}_${use_accent}_${one_by_one}"}; }
	
	load_encoding($inputenc);
	load_encoding($outputenc);
	load_accent() if $use_accent;

	my $conv = {};

	my ($is_one_by_one, $has_space) = (1, 0);
	my $key;
	for $key (keys %{$input_hashes{$inputenc}})
		{
		my $desc = $input_hashes{$inputenc}{$key};
		my $output = $output_hashes{$outputenc}{$desc};
		
		if (not defined $output and $use_accent)
			{	# Doesn't have friend in output encoding
			$output = $accent{$desc};
			$output = undef if $one_by_one and
				(length $key == 1 and length $output != 1);
			}
		if (not defined $output and $use_fillstring)
			{
			$output = $fillstring;
			}
		
		next if (not defined $output or $key eq $output);
		if (length $key != 1 or length $output != 1)
			{ $is_one_by_one = 0; }
		$conv->{$key} = $output;
		}

	my $fntext = ' sub { my @converted = map { my $e = $_; ';

	if (not keys %$conv)
		{
		# do nothing;
		}
	elsif ($is_one_by_one)
		{
		my $src = join "", keys %$conv;
		$src = "\Q$src";
		my $dst = join "", values %$conv;
		$dst = "\Q$dst";
		$fntext .= qq! \$e =~ tr/$src/$dst/; !;
		}
	elsif ($inputenc eq 'tex')
		{
		my $src = $regexp_matches{'tex'};
		$fntext .= qq! \$e =~ s/$src/ my \$e = \$&; my \$orig = \$e; \$e =~ s#[{}]# #sog; \$e =~ s#[ \\t]+# #sog; \$e =~ s# \$##o; (defined \$conv->{\$e} ? \$conv->{\$e} : \$orig); /esog; !;
		}
	else
		{
		my $singles = join "", grep { length $_ == 1 } keys %$conv;
		$singles = "[". "\Q$singles" . "]";
		
		my $src = join "|",
			( map { my $e = "\Q$_"; $e; }
				sort { length $b <=> length $a }
					grep { length $_ != 1 } keys %$conv);
		if ($singles ne "[]")
			{ $src .= "|" unless $src eq ''; $src .= $singles; }
			
		$fntext .= qq! \$e =~ s/$src/\$conv->{\$&}/sog; !;
		}
	
	$fntext .= ' $e; } @_; if (wantarray) { return @converted; } else { return  join "", @converted; } }';

	print STDERR "Conversion function for $inputenc to $outputenc:\n$fntext\n" if DEBUG;

	my $fn = eval $fntext;
	do {	chomp $@;
		die "$@, line ", __LINE__, "\n";
		} if $@;
	bless $fn, $class;
	
	$functions{"${inputenc}_${outputenc}_${fillstring}_${use_fillstring}_${use_accent}_${one_by_one}"} = $fn;
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


