---
layout: post
title: Install Samba 4 AD DC
author: Galuh D Wijatmiko
categories: [Authentication]
tags: [samba4,centos7,installation]
---


> GOAL : Running Samba 4 AD DC

> RUNNING MODE ROOT

# Install Depedency SAMBA 

```bash
yum install -y attr bind-utils docbook-style-xsl gcc gdb krb5-workstation libsemanage-python libxslt perl perl-ExtUtils-MakeMaker perl-Parse-Yapp perl-Test-Base wget \ 
pkgconfig policycoreutils-python python2-crypto gnutls-devel libattr-devel keyutils-libs-devel libacl-devel libaio-devel libblkid-devel libxml2-devel openldap-devel \
pam-devel popt-devel python-devel readline-devel zlib-devel systemd-devel lmdb-devel jansson-devel gpgme-devel pygpgme libarchive-devel python3 python3-libs python3-pip python3-setuptools \
python36-devel avahi-libs cups-libs python36-dns.noarch

```
# Install Depedency Packaging

```bash
yum install -y rpm-build ruby ruby-devel rubygems ruby-libs
```

# Dowload SAMBA AD DC 

```bash
wget -c https://download.samba.org/pub/samba/stable/samba-4.9.13.tar.gz
tar xvf samba-4.9.13.tar.gz
```

# Install FPM 

```bash
gem install fpm
```

# Compile SAMBA AD DC 

```bash
cd samba-4.9.13
   ./configure \
     --prefix=/usr \
     --localstatedir=/var \
     --with-configdir=/etc/samba \
     --libdir=/usr/lib64 \
     --with-modulesdir=/usr/lib64/samba \
     --with-pammodulesdir=/lib64/security \
     --with-lockdir=/var/lib/samba \
     --with-logfilebase=/var/log/samba \
     --with-piddir=/run/samba \
     --with-privatedir=/etc/samba \
     --enable-cups \
     --with-acl-support \
     --with-ads \
     --with-automount \
     --enable-fhs \
     --with-pam \
     --with-quotas \
     --with-shared-modules=idmap_rid,idmap_ad,idmap_hash,idmap_adex \
     --with-syslog \
     --with-utmp \
    --with-dnsupdate 
  make
  mkdir -p ~/work
  mkdir -p ~/work/usr/lib/systemd/system/
  make install install DESTDIR=~/work
```

# Generate Service Systemd

```bash
  echo "
  [Unit]
  Description=Samba AD Daemon
  Wants=network-online.target
  After=network.target network-online.target rsyslog.service

  [Service]
  Type=forking
  PIDFile=/run/samba/samba.pid
  LimitNOFILE=16384
  ExecStart=/usr/sbin/samba --daemon
  ExecReload=/bin/kill -HUP $MAINPID

  [Install]
  WantedBy=multi-user.target
  "> ~/work/usr/lib/systemd/system/samba.service
```

Reload Daemon

```bash
systemctl daemon-reload
```


# Remove Package All About SAMBA

```bash
rpm -qa| grep samba | xargs rpm -e --nodeps
rpm -qa| grep tdb-tools | xargs rpm -e --nodeps
rpm -qa| grep libwbclient | xargs rpm -e --nodeps
rpm -qa| grep libsmbclient | xargs rpm -e --nodeps
[ -f /etc/samba/smb.conf ] && rm /etc/samba/smb.conf || echo "There is no file";
```

# Generate Package SAMBA AD DC

```bash
/usr/local/bin/fpm  \
    -d "pam" \
    -d "gnutls" \
    -d "cups-libs" \
    -d "acl" \
    -d "attr" \
    -d "python3" \
    -d "lmdb" \
    -d "lmdb-devel" \
    -s dir \
    -t rpm \
    -S "samba4-ad-dc-4.9.13.el7.x86_64.rpm" \
    -m "Dwiyan Galuh W" \
    -n "{{samba_rpm_name}}" \
    --license "Breeware License -  wrote this file. As long as you retain this notice you can do whatever you want with this stuff. If we meet some day, and you think this stuff is worth it, you can buy me a beer in return. Poul-Henning Kamp" \
    --url "https://roomit.tech" \
    --description "This Packages is SAMBA 4 Active Directory Domain Controller, We can manage all activities using samba-tool." \
    -a "x86_64" \
    --vendor "dwiyan@roomit.tech" \
    -v 4.9.13 \
    -C ~/work  \
    -p samba4-ad-dc-4.9.13.el7.x86_64.rpm
```

# Install RPM

```bash
rpm -i samba4-ad-dc-4.9.13.el7.x86_64.rpm
```

# Provisioning SAMBA AD DC

```bash
mv /etc/krb5.conf /etc/krb5.conf.org    
samba-tool domain provision --use-rfc2307 --interactive
```

# Config Global

```bash
cat /etc/samba/smb.conf

[global]
	binddns dir = /etc/samba/bind-dns
	cache directory = /etc/samba/cache
	dns forwarder = 8.8.8.8
	lock directory = /etc/samba
	netbios name = AD
	private dir = /etc/samba/private
	realm = ROOMIT.COM
	server role = active directory domain controller
	state directory = /etc/samba/state
	workgroup = ROOMIT
	idmap_ldb:use rfc2307 = yes
        client ldap sasl wrapping = sign
        ldap server require strong auth = no
        tls enabled  = yes
        tls keyfile  = /etc/samba/private/tls/roomitKey.pem
        tls certfile = /etc/samba/private/tls/roomitCert.pem
        tls cafile   = /etc/samba/private/tls/roomitIntermediate.pem
        winbind use default domain = yes
        template homedir = /home/%U
        template shell   = /bin/bash
        ntlm auth = mschapv2-and-ntlmv2-only



[netlogon]
	path = /etc/samba/state/sysvol/roomit.tech/scripts
	read only = No

[sysvol]
	path = /etc/samba/state/sysvol
	read only = No
```

# Copy Kerberos Config
```bash
cp /etc/samba/krb5.conf /etc/samba
```

content krb5.conf:
```bash
[libdefaults]
	default_realm = ROOMIT.COM
	dns_lookup_realm = false
	dns_lookup_kdc = true

```

checking:
```bash
klist

Ticket cache: FILE:/tmp/krb5cc_0
Default principal: administrator@ROOMIT.COM

Valid starting       Expires              Service principal
03/11/2020 09:18:30  03/11/2020 19:18:30  krbtgt/ROOMIT.COM@ROOMIT.COM
	renew until 03/12/2020 09:18:27

```

# Start Service SAMBA AD DC

```bash
systemctl start samba 
```

# Check Service UP

```bash
ss -tulpn

tcp        0      0 0.0.0.0:636             0.0.0.0:*               LISTEN      736/samba: conn[lda 
tcp        0      0 0.0.0.0:49152           0.0.0.0:*               LISTEN      10784/samba: conn[r 
tcp        0      0 0.0.0.0:49153           0.0.0.0:*               LISTEN      31489/samba: task[d 
tcp        0      0 0.0.0.0:49154           0.0.0.0:*               LISTEN      10784/samba: conn[r 
tcp        0      0 0.0.0.0:3268            0.0.0.0:*               LISTEN      736/samba: conn[lda 
tcp        0      0 0.0.0.0:3269            0.0.0.0:*               LISTEN      736/samba: conn[lda 
tcp        0      0 0.0.0.0:389             0.0.0.0:*               LISTEN      31493/samba: task[l 
tcp        0      0 0.0.0.0:135             0.0.0.0:*               LISTEN      10784/samba: conn[r 
tcp        0      0 0.0.0.0:464             0.0.0.0:*               LISTEN      31495/samba: conn[k 
tcp        0      0 0.0.0.0:53              0.0.0.0:*               LISTEN      31502/samba: conn[d 
tcp        0      0 0.0.0.0:88              0.0.0.0:*               LISTEN      31495/samba: conn[k 
tcp6       0      0 :::636                  :::*                    LISTEN      736/samba: conn[lda 
tcp6       0      0 :::49152                :::*                    LISTEN      10784/samba: conn[r 
tcp6       0      0 :::49153                :::*                    LISTEN      10784/samba: conn[r 
tcp6       0      0 :::49154                :::*                    LISTEN      10784/samba: conn[r 
tcp6       0      0 :::3268                 :::*                    LISTEN      736/samba: conn[lda 
tcp6       0      0 :::3269                 :::*                    LISTEN      736/samba: conn[lda 
tcp6       0      0 :::389                  :::*                    LISTEN      736/samba: conn[lda 
tcp6       0      0 :::135                  :::*                    LISTEN      10784/samba: conn[r 
tcp6       0      0 :::464                  :::*                    LISTEN      31495/samba: conn[k 
tcp6       0      0 :::53                   :::*                    LISTEN      31502/samba: conn[d 
tcp6       0      0 :::88                   :::*                    LISTEN      31495/samba: conn[k 
udp        0      0 0.0.0.0:53              0.0.0.0:*                           31502/samba: conn[d 
udp        0      0 10.69.16.130:88         0.0.0.0:*                           31495/samba: conn[k 
udp        0      0 0.0.0.0:88              0.0.0.0:*                           31495/samba: conn[k 
udp        0      0 10.69.16.130:137        0.0.0.0:*                           31491/samba: task[n 
udp        0      0 10.69.16.255:137        0.0.0.0:*                           31491/samba: task[n 
udp        0      0 0.0.0.0:137             0.0.0.0:*                           31491/samba: task[n 
udp        0      0 10.69.16.130:138        0.0.0.0:*                           31491/samba: task[n 
udp        0      0 10.69.16.255:138        0.0.0.0:*                           31491/samba: task[n 
udp        0      0 0.0.0.0:138             0.0.0.0:*                           31491/samba: task[n 
udp        0      0 10.69.16.130:389        0.0.0.0:*                           31494/samba: task[c 
udp        0      0 0.0.0.0:389             0.0.0.0:*                           31494/samba: task[c 
udp        0      0 10.69.16.130:464        0.0.0.0:*                           31495/samba: conn[k 
udp        0      0 0.0.0.0:464             0.0.0.0:*                           31495/samba: conn[k 
udp6       0      0 :::53                   :::*                                31502/samba: conn[d 
udp6       0      0 :::88                   :::*                                31495/samba: conn[k 
udp6       0      0 :::389                  :::*                                31494/samba: task[c 
udp6       0      0 :::464                  :::*                                31495/samba: conn[k 
```

# Test Query
Check Domain Level
```bash
 samba-tool domain level show 
```
Add User
```bash
 samba-tool user create foo.bar
```
List User
```bash
 samba-tool user list | grep foo.bar
```


# Iptables
add in /etc/sysconfig/iptables
```bash
# you can edit this manually or use system-config-firewall
# please do not ask us to add additional ports/services to this default configuration
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]

##### Allow STATE RELATED AND ESTABLISHED ######
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

##### Allow Income ICMP Only From Vlan Operational #####
-A INPUT -s 10.69.16.0/24 -p icmp -j ACCEPT

##### Allow Income Local Loop ######
-A INPUT -i lo -j ACCEPT

##### Allow Income SSH Only VLAN Admin #########
-A INPUT -s 10.69.5.0/24,10.69.16.0/24 -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT

##### Allow Income MONIT ####
-A INPUT -s 10.69.5.0/24,10.69.16.0/24 -p tcp -m state --state NEW -m tcp --dport 2812 -j ACCEPT

##### Allow Income Rest API Shell ####
#-A INPUT -s 10.69.5.0/24 -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT

#### Allow Income SNMP ####
#-A INPUT -s 10.69.16.91 -d 10.69.16.130 -p udp -m udp --dport 161 -j ACCEPT

#### Allow Income NRPE ####
-A INPUT -s 10.69.16.91 -d 10.69.16.130 -p tcp -m tcp --dport 5666 -j ACCEPT

##### Allow Income LDAP and LDAPS AD TCP/UDP ########
-A INPUT  -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp --dport 389 -j ACCEPT
-A INPUT  -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp --dport 636 -j ACCEPT
-A INPUT  -p udp -m state --state NEW,RELATED,ESTABLISHED -m udp --dport 389 -j ACCEPT

##### Allow Income HTTP ######
-A INPUT  -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp --dport 80 -j ACCEPT

##### Allow Income HTTPS #####
-A INPUT  -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp --dport 443 -j ACCEPT

##### Allow Income DNS TCP/UDP #####
-A INPUT  -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp --dport 53 -j ACCEPT
-A INPUT  -p udp -m state --state NEW,RELATED,ESTABLISHED -m udp --dport 53 -j ACCEPT

##### Allow Income Kerberos TCP/UDP ####
-A INPUT  -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp --dport 88 -j ACCEPT
-A INPUT  -p udp -m state --state NEW,RELATED,ESTABLISHED -m udp --dport 88 -j ACCEPT

##### Allow Income Kerberos KPASSWD ####
-A INPUT  -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp --dport 464 -j ACCEPT
-A INPUT  -p udp -m state --state NEW,RELATED,ESTABLISHED -m udp --dport 464 -j ACCEPT

##### Allow Income NTP #####
-A INPUT  -p udp -m state --state NEW,RELATED,ESTABLISHED -m udp --dport 123 -j ACCEPT

##### Allow Income End Point Mapper (DCE/RPC Locator Service) ######
-A INPUT  -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp --dport 135 -j ACCEPT

##### Allow Income NetBIOS Name Service   ######
-A INPUT  -p udp -m state --state NEW,RELATED,ESTABLISHED -m udp --dport 137 -j ACCEPT

##### Allow Income NetBIOS Datagram ######
-A INPUT  -p udp -m state --state NEW,RELATED,ESTABLISHED -m udp --dport 138 -j ACCEPT

##### Allow Income NetBIOS Session  #####
-A INPUT  -p udp -m state --state NEW,RELATED,ESTABLISHED -m udp --dport 139 -j ACCEPT

##### Allow Income Samba Over TCP ####
-A INPUT  -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp --dport 445 -j ACCEPT

##### Allow Global Catalog / SSL ####
-A INPUT  -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp --dport 3268 -j ACCEPT
-A INPUT  -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp --dport 3269 -j ACCEPT

##### Allow Dynamic RPC Ports #####
-A INPUT  -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp -m multiport --dports 49152:65535  -j ACCEPT

-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT


```


