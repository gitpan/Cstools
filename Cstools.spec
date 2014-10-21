Summary: Czech laguage tools
Name: cstools
Version: 0.178
Release: 1
Group: Applications/Text
Source: Cstools-0.178.tar.gz
URL: http://www.fi.muni.cz/~adelton/perl/
Copyright: 1997--2000 Jan Pazdziora, adelton@fi.muni.cz.
Buildroot: /tmp/cstools-root
Packager: Milan Kerslager <milan.kerslager@spsselib.hiedu.cz>

%description
This package includes modules that are usefull when dealing with
Czech (and Slovak) texts in Perl.

Program cstocs:
   This version of popular charset reencoding utility uses the above
   mentioned module to convert text between various charsets.

Module Cz::Cstocs:
   Implements object for various charset encodings, used for the Czech
   language -- either as objects, or as direct conversion functions.  One
   of the charsets is tex for things like \v{c}.

Module Cz::Sort:
   Sorts according to Czech sorting conventions, regardless on (usually
   broken) locales. Exports functions czcmp and czsort which can be used
   in similar way as as Perl's internals cmp and sort.

%description -l cs
V tomto bal�ku jsou moduly, kter� mohou b�t u�ite�n� p�i pr�ci s �esk�mi
(a slovensk�mi) texty v Perlu.

Program cstocs:
   Tato verze konverz�ho programu cstocs je zalo�ena na v��e uveden�m
   modulu. Prov�d� p�evody k�dov�n� nad dan�mi soubory nebo nad
   standardn�m vstupem.

Modul Cz::Cstocs:
   Objekt, pomoc� n�ho� je mo�no konvertovat mezi znakov�mi sadami bez
   nutnosti vn�j��ho programu -- bu� formou objektovou, nebo p��m�mi
   konverzn�mi funkcemi.  Jednou ze znakov�ch sad je i sada tex, tedy
   nap�.  \v{c}.

Modul Cz::Sort:
   Implementuje �ty�pr�chodov� �esk� t��d�n�, nez�visl� na pou�it�ch
   locales, proto�e kdo m� spr�vn� locales, �e? Exportuje funkce czcmp
   a czsort, kter� pracuj� podobn� jako perlovsk� vestav�n� cmp a sort.

%prep

%setup -n Cstools-0.178

%build

perl Makefile.PL
make
make test

%install

/bin/rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr

# make install wants to append to perllocal.pod which is politically
# incorrect behaviour; let's disable it: it's RPM that is supposed to
# keep track of installed software

make \
	PREFIX=$RPM_BUILD_ROOT/usr \
	INSTALLMAN1DIR=$RPM_BUILD_ROOT/usr/man/man1 \
	DOC_INSTALL="-#" \
	install

# .packlist is incorrect and useless (see above)

rm `find $RPM_BUILD_ROOT -name .packlist`

%clean

rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/usr/bin/*
/usr/man/man[0-9]/*
/usr/lib/perl5/man/man3/*
/usr/lib/perl5/site_perl/Cz/*
%doc Changes README

%changelog
* Thu Jul 15 1999 Milan Kerslager <milan.kerslager@spsselib.hiedu.cz>
- added descriptions (en, cs)

