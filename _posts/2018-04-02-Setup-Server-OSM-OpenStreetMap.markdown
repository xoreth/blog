---
layout: post
title: Install MAP Server Centos 7
author: Galuh D Wijatmiko
categories: [Server]
tags: [MapServer,Centos7,Installation]
---

#### Install Packages ####

Make Sure Upgrade Centos to 7.3

- Install All Depedencies


```bash
yum install CGAL.x86_64 CharLS.x86_64 NetworkManager.x86_64 NetworkManager-libnm.x86_64 NetworkManager-team.x86_64 NetworkManager-tui.x86_64 SFCGAL.x86_64 SFCGAL-libs.x86_64 acl.x86_64 aic94xx-firmware.noarch alsa-firmware.noarch apr.x86_64 apr-devel.x86_64 apr-util.x86_64 apr-util-devel.x86_64 armadillo.x86_64 arpack.x86_64 atlas.x86_64 attr.x86_64 audit.x86_64 audit-libs.x86_64 augeas-libs.x86_64 autoconf.noarch automake.noarch bash.x86_64 bash-completion.noarch bc.x86_64 bind-libs.x86_64 bind-libs-lite.x86_64 bind-license.noarch bind-utils.x86_64 bison.x86_64 blas.x86_64 boost.x86_64 boost-atomic.x86_64 boost-chrono.x86_64 boost-context.x86_64 boost-date-time.x86_64 boost-devel.x86_64 boost-filesystem.x86_64 boost-graph.x86_64 boost-iostreams.x86_64 boost-locale.x86_64 boost-math.x86_64 boost-program-options.x86_64 boost-python.x86_64 boost-random.x86_64 boost-regex.x86_64 boost-serialization.x86_64 boost-signals.x86_64 boost-test.x86_64 boost-timer.x86_64 boost-wave.x86_64 bridge-utils.x86_64 byacc.x86_64 bzip2.x86_64 bzip2-devel.x86_64 bzip2-libs.x86_64 ca-certificates.noarch cairo.x86_64 cairo-devel.x86_64 cairomm.x86_64 cairomm-devel.x86_64 centos-indexhtml.noarch centos-logos.noarch cfitsio.x86_64 chrony.x86_64 cmake.x86_64 cpio.x86_64 cpp.x86_64 cracklib.x86_64 cracklib-dicts.x86_64 cronie.x86_64 cronie-anacron.x86_64 crontabs.noarch crypto-utils.x86_64 cscope.x86_64 ctags.x86_64 cyrus-sasl.x86_64 cyrus-sasl-devel.x86_64 cyrus-sasl-lib.x86_64 cyrus-sasl-plain.x86_64 dbus-glib.x86_64 dbus-python.x86_64 desktop-file-utils.x86_64 device-mapper.x86_64 device-mapper-event.x86_64 device-mapper-event-libs.x86_64 device-mapper-libs.x86_64 diffstat.x86_64 diffutils.x86_64 dmidecode.x86_64 dosfstools.x86_64 doxygen.x86_64 dracut.x86_64 dracut-config-rescue.x86_64 dracut-network.x86_64 dwz.x86_64 dyninst.x86_64 ed.x86_64 emacs-filesystem.noarch expat.x86_64 expat-devel.x86_64 findutils.x86_64 fipscheck.x86_64 fipscheck-lib.x86_64 firewalld.noarch firewalld-filesystem.noarch flex.x86_64 fontconfig.x86_64 fontconfig-devel.x86_64 fontpackages-filesystem.noarch fprintd.x86_64 fprintd-pam.x86_64 freetype-devel.x86_64 freexl.x86_64 fxload.x86_64 gawk.x86_64 gcc.x86_64 gcc-c++.x86_64 gcc-gfortran.x86_64 gd.x86_64 gdal-devel.x86_64 gdal-java.x86_64 gdal-libs.x86_64 gdbm.x86_64 gdbm-devel.x86_64 gdk-pixbuf2.x86_64 geos.x86_64 geos-devel.x86_64 gettext.x86_64 gettext-common-devel.noarch gettext-devel.x86_64 gettext-libs.x86_64 giflib.x86_64 git.x86_64 gl-manpages.noarch glib-networking.x86_64 glib2-devel.x86_64 glibc.x86_64 glibc-common.x86_64 glibc-devel.x86_64 glibc-headers.x86_64 gmp.x86_64 gobject-introspection.x86_64 gpgme.x86_64 gpm-libs.x86_64 grep.x86_64 grubby.x86_64 gsettings-desktop-schemas.x86_64 gzip.x86_64 hardlink.x86_64 hdf5.x86_64 hostname.x86_64 httpd.x86_64 httpd-devel.x86_64 httpd-manual.noarch httpd-tools.x86_64 hunspell-en.noarch hunspell-en-GB.noarch hunspell-en-US.noarch indent.x86_64 info.x86_64 initscripts.x86_64 intltool.noarch irqbalance.x86_64 ivtv-firmware.noarch jansson.x86_64 jasper-libs.x86_64 javapackages-tools.noarch jbigkit-libs.x86_64 json-c.x86_64 kernel.x86_64 kernel.x86_64 kernel.x86_64 kernel-devel.x86_64 kernel-headers.x86_64 kernel-tools.x86_64 kernel-tools-libs.x86_64 keyutils-libs.x86_64 kpartx.x86_64 krb5-libs.x86_64 langtable.noarch langtable-data.noarch langtable-python.noarch lapack.x86_64 lcms2.x86_64 ledmon.x86_64 less.x86_64 libICE.x86_64 libSM.x86_64 libX11-devel.x86_64 libXau.x86_64 libXau-devel.x86_64 libXdamage.x86_64 libXdamage-devel.x86_64 libXext.x86_64 libXext-devel.x86_64 libXfixes.x86_64 libXfixes-devel.x86_64 libXpm.x86_64 libXrender.x86_64 libXrender-devel.x86_64 libXxf86vm.x86_64 libXxf86vm-devel.x86_64 libacl.x86_64 libaio.x86_64 libarchive.x86_64 libassuan.x86_64 libattr.x86_64 libblkid.x86_64 libcap.x86_64 libcap-ng.x86_64 libconfig.x86_64 libcroco.x86_64 libcurl-devel.x86_64 libdaemon.x86_64 libdap.x86_64 libdb.x86_64 libdb-devel.x86_64 libdb-utils.x86_64 libdrm-devel.x86_64 libdwarf.x86_64 libedit.x86_64 libestr.x86_64 libgcrypt.x86_64 libgeotiff.x86_64 libgfortran.x86_64 libgnome-keyring.x86_64 libgpg-error.x86_64 libgta.x86_64 libgudev1.x86_64 libicu.x86_64 libicu-devel.x86_64 libidn.x86_64 libjpeg-turbo.x86_64 libjpeg-turbo-devel.x86_64 libmnl.x86_64 libmodman.x86_64 libmount.x86_64 libmpc.x86_64 libnetfilter_conntrack.x86_64 libnfnetlink.x86_64 libnl.x86_64 libnl3.x86_64 libnl3-cli.x86_64 libpcap.x86_64 libpciaccess.x86_64 libpipeline.x86_64 libpng.x86_64 libpng-devel.x86_64 libpwquality.x86_64 libquadmath.x86_64 libquadmath-devel.x86_64 libsemanage.x86_64 libsigc++20.x86_64 libsigc++20-devel.x86_64 libspatialite.x86_64 libssh2.x86_64 libsss_idmap.x86_64 libsss_nss_idmap.x86_64 libstdc++-devel.x86_64 libsysfs.x86_64 libtar.x86_64 libtiff.x86_64 libtiff-devel.x86_64 libtirpc.x86_64 libtool.x86_64 libtool-ltdl.x86_64 libtool-ltdl-devel.x86_64 libunistring.x86_64 libusb.x86_64 libuser.x86_64 libutempter.x86_64 libuuid.x86_64 libverto.x86_64 libwebp.x86_64 libxcb.x86_64 libxcb-devel.x86_64 libxml2.x86_64 libxml2-devel.x86_64 libxml2-python.x86_64 libxshmfence.x86_64 libxslt.x86_64 lsof.x86_64 lua-devel.x86_64 lvm2.x86_64 lvm2-libs.x86_64 lzo.x86_64 m4.x86_64 mailcap.noarch mailx.x86_64 man-db.x86_64 man-pages.noarch mdadm.x86_64 mesa-libEGL.x86_64 mesa-libEGL-devel.x86_64 mesa-libGL.x86_64 mesa-libGL-devel.x86_64 mesa-libGLU.x86_64 mesa-libgbm.x86_64 mesa-libglapi.x86_64 microcode_ctl.x86_64 mod_fcgid.x86_64 mod_perl.x86_64 mod_ssl.x86_64 mokutil.x86_64 mpfr.x86_64 mtr.x86_64 nano.x86_64 ncurses.x86_64 ncurses-libs.x86_64 neon.x86_64 net-tools.x86_64 netcdf.x86_64 newt.x86_64 newt-python.x86_64 nspr.x86_64 nss.x86_64 nss-sysinit.x86_64 nss-tools.x86_64 nss-util.x86_64 ntpdate.x86_64 numactl-libs.x86_64 ogdi.x86_64 openjpeg-libs.x86_64 openjpeg2.x86_64 openldap-devel.x86_64 openssh.x86_64 openssh-clients.x86_64 openssh-server.x86_64 openssl.x86_64 openssl-libs.x86_64 p11-kit.x86_64 p11-kit-trust.x86_64 pakchois.x86_64 passwd.x86_64 patch.x86_64 patchutils.x86_64 pcre.x86_64 perl-Apache-LogFormat-Compiler.noarch perl-Archive-Extract.noarch perl-Archive-Tar.noarch perl-B-Lint.noarch perl-BSD-Resource.x86_64 perl-Business-ISBN.noarch perl-Business-ISBN-Data.noarch perl-CGI.noarch perl-CGI-Compile.noarch perl-CGI-Emulate-PSGI.noarch perl-CPAN.noarch perl-CPAN-Meta.noarch perl-CPAN-Meta-Requirements.noarch perl-CPAN-Meta-YAML.noarch perl-CPANPLUS.noarch perl-CPANPLUS-Dist-Build.noarch perl-Carp.noarch perl-Compress-Raw-Bzip2.x86_64 perl-Compress-Raw-Zlib.x86_64 perl-Config-General.noarch perl-DBD-Pg.x86_64 perl-DBD-SQLite.x86_64 perl-DBI.x86_64 perl-DBIx-Simple.noarch perl-DB_File.x86_64 perl-Data-Dumper.x86_64 perl-Devel-StackTrace.noarch perl-Devel-StackTrace-AsHTML.noarch perl-Digest.noarch perl-Digest-MD5.x86_64 perl-Digest-SHA.x86_64 perl-Encode.x86_64 perl-Encode-Locale.noarch perl-Env.noarch perl-Error.noarch perl-Exporter.noarch perl-ExtUtils-CBuilder.noarch perl-ExtUtils-Embed.noarch perl-ExtUtils-Install.noarch perl-ExtUtils-MakeMaker.noarch perl-ExtUtils-Manifest.noarch perl-ExtUtils-ParseXS.noarch perl-FCGI.x86_64 perl-File-CheckTree.noarch perl-File-Fetch.noarch perl-File-Listing.noarch perl-File-Path.noarch perl-File-Temp.noarch perl-File-pushd.noarch perl-Filter.x86_64 perl-GD.x86_64 perl-GSSAPI.x86_64 perl-Getopt-Long.noarch perl-Git.noarch perl-Guard.x86_64 perl-HTML-Parser.x86_64 perl-HTML-Tagset.noarch perl-HTTP-Body.noarch perl-HTTP-Cookies.noarch perl-HTTP-Daemon.noarch perl-HTTP-Date.noarch perl-HTTP-Message.noarch perl-HTTP-Negotiate.noarch perl-HTTP-Tiny.noarch perl-Hash-MultiValue.noarch perl-IO-Compress.noarch perl-IO-HTML.noarch perl-IO-Socket-IP.noarch perl-IO-Socket-SSL.noarch perl-IO-Zlib.noarch perl-IPC-Cmd.noarch perl-IPC-ShareLite.x86_64 perl-JSON.noarch perl-JSON-PP.noarch perl-LWP-Authen-Negotiate.noarch perl-LWP-MediaTypes.noarch perl-LWP-Protocol-PSGI.noarch perl-LWP-Protocol-http10.noarch perl-LWP-Protocol-https.noarch perl-LWP-UserAgent-DNS-Hosts.noarch perl-LWP-UserAgent-Determined.noarch perl-Linux-Pid.x86_64 perl-Locale-Codes.noarch perl-Locale-Maketext.noarch perl-Locale-Maketext-Simple.noarch perl-Log-Message.noarch perl-Log-Message-Simple.noarch perl-Module-Build.noarch perl-Module-CoreList.noarch perl-Module-Load.noarch perl-Module-Load-Conditional.noarch perl-Module-Loaded.noarch perl-Module-Metadata.noarch perl-Module-Pluggable.noarch perl-Module-Refresh.noarch perl-Mozilla-CA.noarch perl-Net-Daemon.noarch perl-Net-HTTP.noarch perl-Net-LibIDN.x86_64 perl-Net-SSLeay.x86_64 perl-Newt.x86_64 perl-Object-Accessor.noarch perl-Package-Constants.noarch perl-Params-Check.noarch perl-Parse-CPAN-Meta.noarch perl-PathTools.x86_64 perl-Perl-OSType.noarch perl-PlRPC.noarch perl-Plack.noarch perl-Pod-Checker.noarch perl-Pod-LaTeX.noarch perl-Pod-Parser.noarch perl-Pod-Perldoc.noarch perl-Pod-Simple.noarch perl-Pod-Usage.noarch perl-Scalar-List-Utils.x86_64 perl-Scope-Guard.noarch perl-Storable.x86_64 perl-Stream-Buffered.noarch perl-Sys-Mmap.x86_64 perl-Sys-Syslog.x86_64 perl-Term-UI.noarch perl-TermReadKey.x86_64 perl-Test-Harness.noarch perl-Test-Simple.noarch perl-Text-ParseWords.noarch perl-Text-Soundex.x86_64 perl-Text-Unidecode.noarch perl-Thread-Queue.noarch perl-Time-HiRes.x86_64 perl-Time-Local.noarch perl-Time-Piece.x86_64 perl-TimeDate.noarch perl-Try-Tiny.noarch perl-URI.noarch perl-Version-Requirements.noarch perl-WWW-RobotRules.noarch perl-XML-Parser.x86_64 perl-autodie.noarch perl-constant.noarch perl-core.x86_64 perl-devel.x86_64 perl-libwww-perl.noarch perl-local-lib.noarch perl-parent.noarch perl-podlators.noarch perl-srpm-macros.noarch perl-threads.x86_64 perl-threads-shared.x86_64 perl-version.x86_64 pinfo.x86_64 pixman.x86_64 pixman-devel.x86_64 pkgconfig.x86_64 pm-utils.x86_64 policycoreutils.x86_64 polkit.x86_64 polkit-pkla-compat.x86_64 poppler.x86_64 poppler-data.noarch popt.x86_64 postfix.x86_64 postgis22_94.x86_64 postgis22_94-devel.x86_64 postgis22_94-utils.x86_64 postgresql-libs.x86_64 postgresql94.x86_64 postgresql94-contrib.x86_64 postgresql94-devel.x86_64 postgresql94-libs.x86_64 postgresql94-odbc.x86_64 postgresql94-server.x86_64 ppp.x86_64 proj.x86_64 proj-devel.x86_64 proj-epsg.x86_64 protobuf.x86_64 protobuf-c.x86_64 protobuf-c-compiler.x86_64 protobuf-c-devel.x86_64 protobuf-compiler.x86_64 protobuf-devel.x86_64 pth.x86_64 pycairo.x86_64 pycairo-devel.x86_64 pygobject2.x86_64 pygpgme.x86_64 pyliblzma.x86_64 pyparsing.noarch python-augeas.noarch python-chardet.noarch python-configobj.noarch python-decorator.noarch python-devel.x86_64 python-dmidecode.x86_64 python-firewall.noarch python-iniparse.noarch python-javapackages.noarch python-kitchen.noarch python-lxml.x86_64 python-perf.x86_64 python-pyudev.noarch python-six.noarch python-slip.noarch python-slip-dbus.noarch pyxattr.x86_64 qrencode-libs.x86_64 rcs.x86_64 rdate.x86_64 rdma.noarch readline.x86_64 redhat-rpm-config.noarch rfkill.x86_64 rootfiles.noarch rpcbind.x86_64 rpm-build.x86_64 rpm-sign.x86_64 rsync.x86_64 scl-utils.x86_64 screen.x86_64 @updates sed.x86_64 selinux-policy.noarch selinux-policy-targeted.noarch setserial.x86_64 setuptool.x86_64 sgpio.x86_64 shared-mime-info.x86_64 slang.x86_64 snappy.x86_64 sos.noarch sqlite.x86_64 sqlite-devel.x86_64 sssd-client.x86_64 strace.x86_64 subversion.x86_64 subversion-libs.x86_64 sudo.x86_64 swig.x86_64 systemd.x86_64 systemd-libs.x86_64 systemd-python.x86_64 systemd-sysv.x86_64 systemtap.x86_64 systemtap-client.x86_64 systemtap-devel.x86_64 systemtap-sdt-devel.x86_64 sysvinit-tools.x86_64 tcp_wrappers.x86_64 tcp_wrappers-libs.x86_64 tcpdump.x86_64 tcsh.x86_64 time.x86_64 trousers.x86_64 tuned.noarch tzdata.noarch unixODBC.x86_64 usbutils.x86_64 usermode.x86_64 ustr.x86_64 util-linux.x86_64 vim-common.x86_64 vim-enhanced.x86_64 vim-filesystem.x86_64 vim-minimal.x86_64 which.x86_64 words.noarch wpa_supplicant.x86_64 xerces-c.x86_64 xfsdump.x86_64 xfsprogs.x86_64 xmlrpc-c.x86_64 xmlrpc-c-client.x86_64 xorg-x11-proto-devel.noarch xz-devel.x86_64 yajl.x86_64 yum-metadata-parser.x86_64 zlib-devel.x86_64 


yum groupinstall "Development Tools"
```


- Disable Selinux
  vi /etc/selinux/config
  > SELINUX=disabled 

- Restart Server

  `reboot`


#### Config PGDATA Postgresql ####
change variable PGDATA in /etc/sysconfig/pgsql/postgresql-9.4, also in systemd init /usr/lib/systemd/system/postgresql-9.4.service

  `PGDATA=/data/postgresql`

reload systemd init

   `systemctl daemon-reload`


#### Setup Database ####
  ```bash
  mkdir -p /data/postgresql
  chown postgres:postgres -R /data/postgresql
  /usr/pgsql-9.4/bin/postgresql94-setup initdb
  ```



#### Setup Global Environment ####
Add postgress executable binary path into .bash_profile 

  ```bash
  PATH=$PATH:$HOME/bin:/usr/pgsql-9.4/bin
  export PATH
  ```

or add file /etc/profile.d/postgresql.sh and add file with following line

 `export PATH=$PATH:$HOME/bin:/usr/pgsql-9.4/bin`

Reload All parameter

 `source /etc/profile.d/postgresql.sh`

Start Postgresql

 `systemctl start postgresql-9.4`


#### Configure and Import DB Postgis ####

  ```bash 
  sudo -u postgres -i
  createuser gisadmin
  createdb -E UTF8 -O gisadmin gis
  createlang plpgsql gis
  ```


output :

`createlang: language "plpgsql" is already installed in database "gis"`


  ```bash
   psql -d gis -f /usr/pgsql-9.4/share/contrib/postgis-2.2/postgis.sql`
   echo "ALTER TABLE geometry_columns OWNER TO gisadmin; ALTER TABLE spatial_ref_sys OWNER TO gisadmin;" | psql -d gis
   psql -d gis -f /usr/pgsql-9.4/share/contrib/postgis-2.2/spatial_ref_sys.sql
   ```



####  INSTALL OSM2PGSQL ####
  ```bash
  cd /usr/src
  https://github.com/openstreetmap/osm2pgsql/tree/0.92.x
  cd osm2pgsql-master
  mkdir build
  cd build
  cmake ..
  make
  make install
  ```


#### FONTS INSTALL ####
```bash
cp ToolsImportant/truetype.tar.gz /usr/src
cd /usr/src
git clone https://github.com/wajatmaka/WebOpenLayers
cd WebOpenLayers
tar xvf truetype.tar.gz -C /usr/share/fonts/
```


fonts directory both place
1. /usr/local/lib/mapnik/fonts/
2. /usr/share/fonts/
choose one between two path


#### INSTALL MAPNIK ###
  
  ```bash
  cp mapnik.tar.gz /usr/src
  unzip mapnik.tar.gz
  cd mapnik-2.2.0
  ./configure
  ```
  
make sure output configure avaialable output
> "
> All Required dependencies found!
> 
> Overwriting and re-saving file 'config.py'...
> Will hold custom path variables from commandline and python config file(s)...
> Checking for C header file Python.h... yes
> Bindings Python version... 2.7
> Python 2.7 prefix... /usr
> Python bindings will install in... /usr/lib64/python2.7/site-packages
> 
> Configure completed: run `make` to build or `make install`
> "

  ```bash
  make
  make install
  echo "/usr/local/lib/" >>/etc/ld.so.conf.d/local-libs.conf
  ldconfig
  ```


#### Import and Generate image ####
```bash
mkdir /usr/src/pbf
cd /usr/src/pbf
wget -c http://download.geofabrik.de/europe/monaco-latest.osm.pbf
chown postgres:postgres -R /usr/src/pbf
sudo -u postgres -i
/usr/local/bin/osm2pgsql --create --database gis /usr/src/pbf/monaco-latest.osm.pbf
```
>Noted : import small map monaco for load component in database.

#### Download Style OSM ###

```bash
cd /usr/src
git clone https://github.com/giggls/mapnik-stylesheets-polar
chown postgres:postgres -R  /usr/src/mapnik-stylesheets-polar
cd mapnik-style
sudo -u postgres -i
./generate_xml.py --accept-none --dbname gis --symbols ./symbols/ --world_boundaries ./world_boundaries/
./generate_image.py
````


#### Install mod_tile ####

```bash 
cd /usr/src
git clone git@github.com:openstreetmap/mod_tile.git
cd mod_tile
./autogen.sh
./configure
```

change variable MakeFile

  >STORE_LDFLAGS = $(LIBMEMCACHED_LDFLAGS) $(LIBRADOS_LDFLAGS) $(LIBCURL) $(CAIRO_LIBS) -lpthread


```bash
make
make install
make install-mod_tile
```



#### Install Tirex ####

```bash
cd /usr/src
git@github.com:openstreetmap/tirex.git
cd tirex
make
make install 
make install-example-map
rm -rf /etc/tirex/renderer/
mkdir -p /etc/tirex/renderer/osm
```

#### Configure Tirex ####
```bash
cat > /etc/tirex/renderer/osm.conf <<EOF
name=osm
path=/usr/lib/tirex/backends/mapnik
port=9331
procs=5
debug=1
plugindir=/usr/local/lib/mapnik/input/
fontdir=/usr/share/fonts/truetype
fontdir_recurse=1
EOF
```

```bash
cat > /etc/tirex/renderer/osm/osm.conf <<EOF
name=osm
tiledir=/var/lib/mod_tile/osm
maxz=20
fontdir=/usr/share/fonts/truetype
font_dir_recurse=1
mapfile=/usr/src/mapnik-style/osm.xml
EOF
```

#### Configure Database ####
```bash
useradd osm
sudo -u postgres -i
createuser -S -D -R osm

echo "GRANT ALL ON SCHEMA PUBLIC TO osm;" | psql gis
echo "grant all on geometry_columns to osm;" | psql gis
echo "grant all on spatial_ref_sys to osm;" | psql gis
echo "GRANT USAGE ON SCHEMA public to osm;" | psql -d gis
echo "GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO osm;" | psql -d gis
echo "GRANT SELECT ON ALL TABLES IN SCHEMA public TO osm;" | psql -d gis
```

login using root :
```bash
mkdir /var/run/tirex
mkdir /var/log/tirex
mkdir /var/lib/tirex
mkdir -p /var/lib/mod_tile
chown -R osm:osm /var/run/tirex
chown -R osm:osm /var/log/tirex
chown -R osm:osm /var/lib/tirex
chown -R osm:osm /var/lib/mod_tile
```

#### HTTPD Configure ####
```bash
cat > /etc/httpd/conf.d/osm_tirex.conf  <<EOF
LoadModule tile_module modules/mod_tile.so
ModTileRenderdSocketName /var/lib/tirex/modtile.sock
ModTileTileDir           /var/lib/mod_tile
AddTileConfig            /osm/ osm
ModTileRequestTimeout 120
ModTileMissingRequestTimeout 90
EOF
```

```bash
cat > /etc/httpd/conf/httpd.conf<<EOF
ServerRoot "/etc/httpd"
Listen 80
Include conf.modules.d/*.conf
User apache
Group apache
ServerAdmin root@localhost
<Directory />
    AllowOverride none
    Require all denied
</Directory>
DocumentRoot "/www/html"
<Directory "/www">
    AllowOverride None
    Require all granted
</Directory>
<Directory "/www/html">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>
<Files ".ht*">
    Require all denied
</Files>
ErrorLog "logs/error_log"
LogLevel warn
<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    CustomLog "logs/access_log" combined
</IfModule>
<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/www/cgi-bin/"
</IfModule>
<Directory "/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>
<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>
AddDefaultCharset UTF-8
<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>
EnableSendfile on
IncludeOptional conf.d/*.conf
EOF
```



Test configure :
  ```bash
  httpd -t 
  ```

Running tirex with user OSM
```bash
  cat > /usr/lib/systemd/system/tirex-backend.service <<EOF
  [Unit]
  Description=Tirex-backend-manager service
  After=network.target

  [Service]
  Type=forking
  User=osm
  Group=osm
  ExecStart=/bin/tirex-backend-manager
  PIDFile=/var/run/tirex/tirex-backend-manager.pid

  [Install]
  WantedBy=multi-user.target
  EOF
  ```
  
  ```bash
  cat > /usr/lib/systemd/system/tirex-master.service <<EOF
  [Unit]
  Description=Tirex-master service
  After=network.target

  [Service]
  Type=forking
  User=osm
  Group=osm
  ExecStart=/bin/tirex-master
  PIDFile=/var/run/tirex/tirex-master.pid


  [Install]
  WantedBy=multi-user.target
  EOF
  ```
  
  ```bash
  systemctl daemon-reload
  sudo -u osm -i
  systemctl start tirex-backend
  systemctl start tirex-master
  ```


Monitoring Tirex using
```bash
  sudo -u osm -i
  journalctl -f -u tirex-backend
  journalctl -f -u tirex-master
```



Import Database from PBF

```bash
   su - postgres
   cd /usr/src
   wget -c https://planet.osm.org/pbf/planet-180319.osm.pbf
   /usr/local/bin/osm2pgsql -v --slim -S /usr/src/osm2pgsql-master/default.style -d gis -C 16000 --number-processes 24 /usr/src/planet-180319.osm.pbf
```


Grant privileges
```bash
sudo -u postgres -i
echo "GRANT USAGE ON SCHEMA public to osm;" | psql -d gis
echo "GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO osm;" | psql -d gis
echo "GRANT SELECT ON ALL TABLES IN SCHEMA public TO osm;" | psql -d gis
```



####Configuration Web Interface####

Download [openlayer2 ](https://github.com/openlayers/ol2/releases/download/release-2.13.1/OpenLayers-2.13.1.tar.gz) or clone from

```bash
git clone https://github.com/wajatmaka/WebOpenLayers
```

Copy all www in hardisk external www to server /www
change owner /www/html/osm
```bash
mkdir /www/html/osm
chown osm:osm -R /www/html/osm
ln -s /www/html/osm /var/lib/mod_tile
```

Extract web in /www/html
  ```bash
   mkdir -p /www/html
   cp www.tar.gz /www/html
   tar xvf www.tar.gz
   ```

Restart httpd
   
`systemctl restart httpd`





Render MAP Indonesia
```bash
su - osm
screen
tirex-batch -p 50 map=osm bbox=32.212,10.142,62.358,34.016 z=0,20
```

Tweak CPU

`echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null`
