#
# This extraction code was taken from the libwww modules.
#
use Config;
my $filename = $0;

$filename =~ s/\.PL$//;
open OUT,">$filename" or die "Can't create $filename: $!";
chmod(0755, $filename);
print "Extracting $filename (with #! and variable substitution)\n";

use Cz::Cstocs;
print "Cz::Cstocs' version is $Cz::Cstocs::VERSION\n";
print "Available encodings: ", join(" ", Cz::Cstocs::available_enc()), "\n";

print OUT <<"EOHEADER";
$Config{'startperl'} -w
	eval 'exec perl -S \$0 "\$@"'
		if 0;

EOHEADER

print OUT <<'EOBODY';

use vars qw( $running_under_some_shell );

=head1 NAME

cstocs -- charset encoding convertor for the Czech and Slovak languages.

=head1 FORMAT

	cstocs [options] src_encoding dst_encoding [files ...]

=head1 SYNOPSIS

	cstocs il2 ascii < file | more

Please see the

	cstocs --help

for short usage info.

=head1 DESCRIPTION

Cstocs is a simple conversion utility to change charset encoding of
a text. It reads either specified files or (if none specified) the
standard input, assumes that the input is encoded in C<src_encoding>
and ties to reencode it into C<dst_encoding>. The result is written to
the standard output.

Encodings currently supported are

EOBODY

print OUT "\t", join(" ", Cz::Cstocs::available_enc()), "\n";

print OUT <<'EOBODY';

Characters that are not defined in C<src_encoding> are passed to the
output unchanged.

If source text contains character, that is defined in C<src_encoding>
but not in C<dst_encoding>, it can be handled several ways. For
example, character "e with caron" (symbol ecaron), and "d with caron"
(symbol dcaron)  are included in the iso-8859-2 encoding, but not in
the iso-8859-1. If you will do reencoding of 8859-2 text to 8859-1,
you may want to do one of the following actions:

=over 3

=item 1.

Do not produce any output instead of "ecaron" symbol, option C<--null>.

=item 2.

Substitute some string (possibly a space) instead of both ecaron and
dcaron, options C<--fillstring>.

=item 3.

Substitute a letter "d" instead of dcaron, and "e" instead of ecaron.
It is even possible to substitute string instead of symbol, so you can
replace the "AE" Latin character with string "AE" (letter "A", and
letter "E").  Or you can replace a "plusminus sign" with a string
"+/-".  These substitutions are described in the F<accent> file.

=back

=head1 OPTIONS

=over 4

=item --dir directory

Encoding files are taken from F<directory> instead of the default,
which is F<Cz/Cstocs/enc> in the Perl lib tree. The location of encoding
files can also be changed using the I<CSTOCSDIR> environment variable,
but the --dir option has the highest priority.

=item --fillstring string

If source text contains character, that is defined in the
C<src_encoding> but not in the C<dst_encoding> nor in the F<accent>
file (or F<accent> file is not used), it is replaced by C<string>.
The default is single space.

=item --null

Completely equivalent to --fillstring "".

=item --nochange or --noaccent

Do not use the F<accent> file at all.

=item --onebyone

Use only those rules from the F<accent> file, which rewrite one
character to one character. If this option is specified, character
"ecaron" will be rewritten to "e", but "AE" character will not be
rewritten to "AE" string.

=item --onebymore

Use all rules from accent file. This is the default option.

=head1 VERSION

EOBODY

print OUT "$Cz::Cstocs::VERSION\n";

print OUT <<'EOBODY';

=head1 SEE ALSO

Cz::Cstocs(3).

=head1 AUTHOR

Jan "Yenya" Kasprzak has done the original Un*x implementation.

Jan Pazdziora, adelton@fi.muni.cz, created the Perl module version.

=cut

use strict;
use Cz::Cstocs;

sub usage {
	print STDERR <<"EOF";
Usage: cstocs [options] inputencoding outputencoding [ files ... ]
  where [options] can be
    --dir=string	Alternate directory with encoding and accent files.
    --fillstring=str	String that will replace unconvertable characters.
    --null		Equivalent to --fillstring=""
    --nochange, --noaccent	Do not use accent file at all.
    --onebyone		Use only one-by-one character rules from accent file.
    --onebymore		Use all entries from the accent file.
    --version		Print out the version information.
    --debug		Print out debugging info while processing.
Input and output encodings can also be specified using --inputencoding
and --outputencoding options. See man page for detailed description.
EOF
exit;
}

sub print_version
	{
	print STDERR "This is cstocs version $Cz::Cstocs::VERSION.\n";
	exit 0;
	}

# Out defaults are
my %options = ();

if (grep { /--/ } @ARGV)
	{
	require Getopt::Long;
	Getopt::Long::GetOptions(

		'null' =>	sub { $options{'fillstring'} = ''; },
		'fillstring=s' =>	\$options{'fillstring'},
		'nofillstring' =>	sub { $options{'nofillstring'} = 1 },
		'usefillstring' =>	sub { $options{'nofillstring'} = 0 },

		'onebyone' =>	sub { $options{'one_by_one'} = 1; },
		'onebymore' =>	sub { $options{'one_by_one'} = 0; },

		'noaccent',	sub { $options{'use_accent'} = 0; },
		'nochange',	sub { $options{'use_accent'} = 0; },

		'dir=s' =>	\$options{'cstocsdir'},

		'inputencoding=s' =>	\$options{'inputenc'},
		'outputencoding=s' =>	\$options{'outputenc'},

		'help'	=>	\&usage,
		'version' =>	\&print_version,
		'debug' =>	sub { $Cz::Cstocs::DEBUG = 1; },

		);
	}

elsif (@ARGV < 2)
	{ usage(); }

my ($inputenc, $outputenc);
if (defined $options{'inputenc'})
	{ $inputenc = $options{'inputenc'}; delete $options{'inputenc'}; }
else
	{ $inputenc = shift; }

if (defined $options{'outputenc'})
	{ $outputenc = $options{'outputenc'}; delete $options{'outputenc'}; }
else
	{ $outputenc = shift; }

my $tag;
for $tag (keys %options)
	{ delete $options{$tag} unless defined $options{$tag}; }

print STDERR "Calling Cz::Cstocs $inputenc, $outputenc\n" if Cz::Cstocs::DEBUG;
my $convert = new Cz::Cstocs $inputenc, $outputenc, %options;

exit (1) unless defined $convert;

while (<>)
	{ print &$convert($_); }

EOBODY
