Summary: Czech laguage tools
Name: cstools
Version: 0.161
Release: 1
Group: Utilities/Text
Source: Cstools-0.161.tar.gz
URL: http://www.fi.muni.cz/~adelton/perl/
Copyright: 1997--1998 Jan Pazdziora, adelton@fi.muni.cz.
Buildroot: /tmp/cstools-root
Packager: peak

%description

%prep

%setup -n Cstools-0.161

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

