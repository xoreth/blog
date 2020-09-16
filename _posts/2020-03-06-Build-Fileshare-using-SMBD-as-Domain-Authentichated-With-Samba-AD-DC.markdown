---
layout: post
title: Build Fileshare using SMBD as Domain Authentichated With Samba AD DC
author: Galuh D Wijatmiko
categories: [StorageAndFilesystem]
tags: [Samba4,Fileshare]
draft: false
published: true
---

# Joining

Install Package
```bash
yum install realmd samba-winbind-modules samba-common samba-common-libs samba-libs samba samba-winbind samba-client \
samba-client-libs samba-common-tools   samba-winbind-clients nss-pam-ldapd pam-devel sssd-proxy sssd sssd-common python-sssdconfig \
sssd-common-pac sssd-ad sssd-ldap sssd-ipa sssd-krb5 sssd-client sssd-krb5-common krb5-workstation
```

Configure PAM,NSS For Winbind
```bash
authconfig-tui
```

or 

```bash
authconfig --enablewinbind --enablewinbindauth --smbsecurity ads --smbworkgroup=ROOMIT --smbrealm  ROOMIT.TECH --smbservers=addc1.roomit.tech --krb5realm=ROOMIT.TECH \
--enablewinbindoffline --enablewinbindkrb5 --winbindtemplateshell=/bin/bash --winbindjoin=administrator --update  --enablelocauthorize  --enablesssdauth --enablemkhomedir --update
```


Joining Domain
```bash
realm join -U Administrator ROOMIT.TECH
```

# Configure SSSD
Stop SSSD Service
```bash
 systemctl stop sssd
```

We want login with simple name without domain and make directory only using name without domain, edit /etc/sssd/sssd.conf
```bash
[sssd]
domains = roomit.tech
config_file_version = 2
services = nss, pam, sudo
reconnection_retries = 3 #add option
sbus_timeout = 30 #add option

[sudo]

[pam]
offline_credentials_expiration = 355 #355 days offline cache


[domain/roomit.tech]
ad_domain = roomit.tech
krb5_realm = ROOMIT.TECH
realmd_tags = manages-system joined-with-samba 
cache_credentials = True
id_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_id_mapping = True
use_fully_qualified_names = False #value change from True become False
fallback_homedir = /home/%u #value change from %u@%d
access_provider = ad
```

Start Service sssd
```bash
 systemctl start sssd
```

# Configure SAMBA
Configure Samba Fileshare and Running Service smbd nmbd winbindd. Create config file share in /etc/samba/smb.conf.
```bash
[global]
  workgroup = ROOMIT
  realm = ROOMIT.TECH
  security = domain
  idmap config * : range = 16777216-33554431
  template shell = /bin/bash
  kerberos method = secrets only
  winbind use default domain = false
  winbind offline logon = false
  idmap config * : range = 16777216-33554431
  idmap config * : range = 16777216-33554431
  encrypt passwords = yes
  passdb backend = tdbsam 
  printing = cups
  printcap name = /dev/null # mute annoying errors
  log level = 3
  log file = /var/log/samba/%m.log
  vfs objects = acl_xattr
  map acl inherit = yes
  store dos attributes = yes

[homes]
   comment = Home Directories
   browseable = yes
   writable = yes
   write list = @"ROOMIT\Domain Users"
   path = /home/%U
   create mode = 0664
   directory mode = 0775
   vfs objects = full_audit
   full_audit:prefix = %u|%I|%m|%S
   full_audit:success = mkdir rename unlink rmdir pwrite pread rm rmdir
   full_audit:failure = none
   full_audit:facility = local7
   full_audit:priority = NOTICE

[public]
   comment = Public Sharing Department
   path = /home/public
   browsable =yes
   writable = yes
   guest ok = yes
   read only = no
   force user = nobody

[reports]
   read only = no
   writable = yes
   write list = @"ROOMIT\Operation"
   read  list = @"ROOMIT\Sales-And-Marketing", @"ROOMIT\Finance-And-Marketing"
   valid users =  @"ROOMIT\Operation", @"ROOMIT\Sales-And-Marketing", @"ROOMIT\Finance-And-Marketing"
   path = /home/reports
   public = no
   browseable = no
   create mode = 0644
   directory mode = 0775
   vfs objects = full_audit
   full_audit:prefix = %u|%I|%m|%S
   full_audit:success = mkdir rename unlink rmdir pwrite pread rm rmdir
   full_audit:failure = none
   full_audit:facility = local7
   full_audit:priority = NOTICE

[designer]
   read only = no
   writable = yes
   valid users =  @"ROOMIT\Project-Management"
   path = /home/designer
   public = no
   browseable = no
   create mode = 0644
   directory mode = 0775
   vfs objects = full_audit
   full_audit:prefix = %u|%I|%m|%S
   full_audit:success = mkdir rename unlink rmdir pwrite pread rm rmdir
   full_audit:failure = none
   full_audit:facility = local7
   full_audit:priority = NOTICE

[share-adm]
   comment = Operation Sharing Department
   path = /home/share-adm
   read only = no
   valid users = @"ROOMIT\share-adm"
   inherit acls = yes         
   inherit permissions = yes 
   browseable = no
   create mode = 0664
   directory mode = 0775
   vfs objects = full_audit
   full_audit:prefix = %u|%I|%m|%S
   full_audit:success = mkdir rename unlink rmdir pwrite pread rm rmdir
   full_audit:failure = none
   full_audit:facility = local7
   full_audit:priority = NOTICE 

[share-tel]
   comment = Telco Sharing Department
   path = /home/share-tel
   read only = no
   valid users = @"ROOMIT\share-tel"
   inherit acls = yes
   inherit permissions = yes
   browseable = no
   create mode = 0664
   directory mode = 0775
   vfs objects = full_audit
   full_audit:prefix = %u|%I|%m|%S
   full_audit:success = mkdir rename unlink rmdir pwrite pread rm rmdir
   full_audit:failure = none
   full_audit:facility = local7
   full_audit:priority = NOTICE

[share-dev]
   comment = Development Sharing Department
   path = /home/share-dev
   read only = no
   valid users = @"ROOMIT\share-dev"
   inherit acls = yes
   inherit permissions = yes
   browseable = no
   create mode = 0664
   directory mode = 0775
   vfs objects = full_audit
   full_audit:prefix = %u|%I|%m|%S
   full_audit:success = mkdir rename unlink rmdir pwrite pread rm rmdir
   full_audit:failure = none
   full_audit:facility = local7
   full_audit:priority = NOTICE

[share-mgt]
   comment = Management  Sharing Department
   path = /home/share-mgt
   read only = no
   valid users = @"ROOMIT\share-mgt"
   inherit acls = yes
   inherit permissions = yes
   browseable = no
   create mode = 0664
   directory mode = 0775
   vfs objects = full_audit
   full_audit:prefix = %u|%I|%m|%S
   full_audit:success = mkdir rename unlink rmdir pwrite pread rm rmdir
   full_audit:failure = none
   full_audit:facility = local7
   full_audit:priority = NOTICE

[share-ga]
   comment = General Affairs Sharing Department
   path = /home/share-ga
   read only = no
   valid users = @"ROOMIT\share-ga"
   inherit acls = yes
   inherit permissions = yes
   browseable = no
   create mode = 0664
   directory mode = 0775
   vfs objects = full_audit
   full_audit:prefix = %u|%I|%m|%S
   full_audit:success = mkdir rename unlink rmdir pwrite pread rm rmdir
   full_audit:failure = none
   full_audit:facility = local7
   full_audit:priority = NOTICE

[share-fin]
   comment = Finance And Accounting Sharing Department
   path = /home/share-fin
   read only = no
   valid users = @"ROOMIT\share-fin"
   inherit acls = yes
   inherit permissions = yes
   browseable = no
   create mode = 0664
   directory mode = 0775
   vfs objects = full_audit
   full_audit:prefix = %u|%I|%m|%S
   full_audit:success = mkdir rename unlink rmdir pwrite pread rm rmdir
   full_audit:failure = none
   full_audit:facility = local7
   full_audit:priority = NOTICE

[share-hrd]
   comment = HRD Sharing Department
   path = /home/share-hrd
   read only = no
   valid users = @"ROOMIT\share-hrd"
   inherit acls = yes
   inherit permissions = yes
   browseable = no
   create mode = 0664
   directory mode = 0775
   vfs objects = full_audit
   full_audit:prefix = %u|%I|%m|%S
   full_audit:success = mkdir rename unlink rmdir pwrite pread rm rmdir
   full_audit:failure = none
   full_audit:facility = local7
   full_audit:priority = NOTICE

[share-mkt]
   comment = Sales And Marketing Sharing Department
   path = /home/share-mkt
   read only = no
   valid users = @"ROOMIT\share-mkt"
   inherit acls = yes
   inherit permissions = yes
   browseable = no
   create mode = 0664
   directory mode = 0775
   vfs objects = full_audit
   full_audit:prefix = %u|%I|%m|%S
   full_audit:success = mkdir rename unlink rmdir pwrite pread rm rmdir
   full_audit:failure = none
   full_audit:facility = local7
   full_audit:priority = NOTICE
```

Start Service smbd (Service For Fileshare and Printer Server), nmbd (Service For Network), Winbindd (Service For Authentication).

```bash
systemctl start smb nmb winbind
```

# TESTING
Check Service Working or Not
Check Domain NT
```bash
wbinfo --ping-dc

#Output :
#checking the NETLOGON for domain[ROOMIT] dc connection to "AD" succeeded
```

Check User using winbind
```bash
wbinfo -u

#Output :
# ......
#ROOMIT\christopher.jagtap
#ROOMIT\zydney
#ROOMIT\rouf
#ROOMIT\pran.kumar
#ROOMIT\handy.chen
#ROOMIT\heri.kuswanto
# .....
```

Check Group using winbind
```bash
wbinfo -g

#Output :
#..........
#ROOMIT\devops
#ROOMIT\top-management
#ROOMIT\ga
#ROOMIT\share-hrd
#ROOMIT\share-adm
#ROOMIT\senior-operation
#............
```

If winbind already fine, winbind can restart same time with smbd service
Check info domain
```bash
net ads info

#Output:
#LDAP server: 10.32.16.130
#LDAP server name: addc1.roomit.tech
#Realm: ROOMIT.TECH
#Bind Path: dc=ROOMIT,dc=TECH
#LDAP port: 389
#Server time: Tue, 12 Nov 2019 16:52:31 WIB
#KDC server: 10.32.16.130
#Server time offset: 406
#Last machine account password change: Wed, 06 Nov 2019 15:37:15 WIB
```

Check Using Posix
```bash
getent passwd ROOMIT\\dwiyan.wijatmiko

#Output:
#dwiyan.wijatmiko:*:545022134:545000513:dwiyan.wijatmiko:/home/dwiyan.wijatmiko:/bin/bash
```

Testing Mounting in Workstation
```bash
 smbclient //share.roomit.tech/dwiyan.wijatmiko -U  dwiyan.wijatmiko -W ROOMIT
#Output :
#Enter ROOMIT\dwiyan.wijatmiko's password: 
#Try "help" to get a list of possible commands.
#smb: \> 
```

How To Leave Domain
```bash
 realm leave ROOMIT.TECH 
```