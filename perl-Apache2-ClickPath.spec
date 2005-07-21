BuildRequires: aaa_base acl attr bash bind-utils bison bzip2 coreutils cpio cpp cracklib cvs cyrus-sasl db devs diffutils e2fsprogs file filesystem fillup findutils flex gawk gdbm-devel glibc glibc-devel glibc-locale gpm grep groff gzip info insserv kbd less libacl libattr libgcc libselinux libstdc++ libxcrypt m4 make man mktemp module-init-tools ncurses ncurses-devel net-tools netcfg openldap2-client openssl pam pam-modules patch permissions popt procinfo procps psmisc pwdutils rcs readline sed strace syslogd sysvinit tar tcpd texinfo timezone unzip util-linux vim zlib zlib-devel autoconf automake binutils gcc gdbm gettext libtool perl rpm

Name:         perl-Apache2-ClickPath
License:      Artistic License
Group:        Development/Libraries/Perl
Provides:     p_Apache2_ClickPath
Obsoletes:    p_Apache2_ClickPath
Requires:     perl = %{perl_version}
Requires:     p_mod_perl >= 1.999022
Autoreqprov:  on
Summary:      Apache2::ClickPath
Version:      1.8
Release:      1
Source:       Apache2-ClickPath-%{version}.tar.gz
BuildRoot:    %{_tmppath}/%{name}-%{version}-build

%description
Apache2::ClickPath



Authors:
--------
    Torsten Foertsch <torsten.foertsch@gmx.net>

%prep
%setup -n Apache2-ClickPath-%{version}
# ---------------------------------------------------------------------------

%build
perl Makefile.PL
make && make test
# ---------------------------------------------------------------------------

%install
[ "$RPM_BUILD_ROOT" != "/" ] && [ -d $RPM_BUILD_ROOT ] && rm -rf $RPM_BUILD_ROOT;
make DESTDIR=$RPM_BUILD_ROOT install_vendor
rm -f $RPM_BUILD_ROOT%{_mandir}/man3/Apache2::decode-session.3pm
%{_gzipbin} -9 $RPM_BUILD_ROOT%{_mandir}/man3/Apache2::ClickPath.3pm || true
%{_gzipbin} -9 $RPM_BUILD_ROOT%{_mandir}/man3/Apache2::ClickPath::Decode.3pm || true
%{_gzipbin} -9 $RPM_BUILD_ROOT%{_mandir}/man3/Apache2::ClickPath::Store.3pm || true
%{_gzipbin} -9 $RPM_BUILD_ROOT%{_mandir}/man3/Apache2::ClickPath::StoreClient.3pm || true
%perl_process_packlist

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && [ -d $RPM_BUILD_ROOT ] && rm -rf $RPM_BUILD_ROOT;

%files
%defattr(-, root, root)
%{perl_vendorlib}/Apache2
%{perl_vendorarch}/auto/Apache2
%doc %{_mandir}/man3/Apache2::ClickPath.3pm.gz
%doc %{_mandir}/man3/Apache2::ClickPath::Decode.3pm.gz
%doc %{_mandir}/man3/Apache2::ClickPath::Store.3pm.gz
%doc %{_mandir}/man3/Apache2::ClickPath::StoreClient.3pm.gz
/var/adm/perl-modules/perl-Apache2-ClickPath
%doc MANIFEST README
