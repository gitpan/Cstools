#!/usr/bin/perl -w
#
# This extraction code was taken from the libwww modules.
#
use Config;
use File::Basename qw(basename dirname);
chdir(dirname($0));
($file = basename($0)) =~ s/\.PL$//;
open OUT,">$file" or die "Can't create $file: $!";
chmod(0755, $file);
print "Extracting $file (with #! substitution)\n";

print OUT <<"EOHEADER";
$Config{'startperl'} -w
	eval 'exec perl -S \$0 "\$@"'
		if 0;
EOHEADER

print OUT <<'EOBODY';

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

Do not produce any output instead of "ecaron" symbol.

=item 2.

Substitute some string (possibly a space) instead of both ecaron and
dcaron.

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
which is F<Cstocs/enc> in the Perl lib tree. The location of encoding
files can also be changed using the I<CSTOCSDIR> environment variable,
but the --dir option has the highest priority.

=item --fillstring string

If source text contains character, that is defined in the
C<src_encoding> but not in the C<dst_encoding> nor in the F<accent>
file, it is replaced by C<string>. The default is single space.

=item --null

Completely equivalent to --fillstring "".

=item --nochange

Do not use the F<accent> file at all.

=item --onebyone

Use only those rules from the F<accent> file, which rewrite one
character to one character. If this option is specified, character
"ecaron" will be rewritten to "e", but "AE" character will not be
rewritten to "AE" string. This is the default option.

=item --onebymore

Use all rules from accent file.

=head1 VERSION

3.07

=head1 SEE ALSO

Cstocs(3).

=head1 AUTHOR

Jan "Yenya" Kasprzak has done the original Un*x implementation.

Jan Pazdziora, adelton@fi.muni.cz created the Perl module version.

=cut

use Cstocs;
use strict;

0 if defined $main::running_under_some_shell;

my ($inputenc, $outputenc);
my ($fillstring, $cstocsdir, $one_by_more, $use_accent, $debug)
	= (undef, undef, 1, 1, 0);

if (grep { /--/ } @ARGV)
	{
	## print STDERR "Using Getopt::Long\n";
	require Getopt::Long;
	Getopt::Long::GetOptions(
		'null' =>	sub { $fillstring = ''; },
		'fillstring=s' =>	\$fillstring,
		'onebyone' =>	sub { $one_by_more = 0; },
		'onebymore' =>	\$one_by_more,
		'nochange',	sub { $use_accent = 0; },
		'dir=s' =>	\$cstocsdir,
		'inputencoding=s' =>	\$inputenc,
		'outputencoding=s' =>	\$outputenc,
		'help'	=>	\&usage,
		'version' =>	sub {print STDERR "This is cstocs version $Cstocs::VERSION.\n"; exit 0; },
		'debug' =>	\$debug,
		);
	if ($debug)
		{ $Cstocs::DEBUG = 1; }
	if (defined $fillstring)
		{
		$Cstocs::fillstring = $fillstring;
		print STDERR "Setting fillstring to '$Cstocs::fillstring' from command line\n" if Cstocs::DEBUG;
		}
	if (defined $cstocsdir)
		{
		$Cstocs::cstocsdir = $cstocsdir;
		print STDERR "Setting enc-dir $Cstocs::cstocsdir from command line\n" if Cstocs::DEBUG;
		}
	if ($one_by_more != 1)
		{
		$Cstocs::one_by_more = $one_by_more;
		print STDERR "Setting one_by_more to $Cstocs::one_by_more from command line\n" if Cstocs::DEBUG;
		}
	if ($use_accent != 1)
		{
		$Cstocs::use_accent = $use_accent;
		print STDERR "Setting use_accent to $Cstocs::use_accent from command line\n" if Cstocs::DEBUG;
		}
	}
elsif (@ARGV < 2)
	{ usage(); }

$inputenc = shift unless defined $inputenc;
$outputenc = shift unless defined $outputenc;

my $convert = new Cstocs $inputenc, $outputenc;
while (<>)
	{ print &$convert($_); }

sub usage {
	print STDERR <<"EOF";
Usage: cstocs [options] inputencoding outputencoding [ files ... ]
    or cstocs [options] --inputencoding=inputencoding \\
		--outputencoding=outputencoding [ files ... ]
    where [options] is zero or more of:
    --dir=string	Directory where to search for encoding and accent
	files, can also be changed via the CSTOCSDIR environment variable.
	Default is $Cstocs::DEFAULTCSTOCSDIR.
    --debug	Print out debugging info while processing.
    --fillstring=string		Characters from the input encoding not
	defined in the output encoding nor in the accent file will be
	replaced by this string (default is single space).
    --help	Prints out this message.
    --nochange	Do not use accent file at all.
    --null	Equivalent to --fillstring=""
    --onebyone	Use only those entries from the accent file, which will
	cause replacing of one character by exactly one character (this is
	the default behavior).
    --onebymore	Use all entries from the accent file.
    --version	Prints out the version information.
EOF
exit;
}

EOBODY
