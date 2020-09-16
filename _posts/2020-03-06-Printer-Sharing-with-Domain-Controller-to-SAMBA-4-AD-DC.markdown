---
layout: post
title: Printer Sharing with Domain Controller to SAMBA 4 AD DC
author: Galuh D Wijatmiko
categories: [Authentication]
tags: [samba4,Fileshare]
draft: false
published: true
---

### Install Requierment ###
```bash
yum install realmd samba-winbind-modules samba-common samba-common-libs samba-libs samba samba-winbind samba-client \
samba-client-libs samba-common-tools   samba-winbind-clients nss-pam-ldapd pam-devel sssd-proxy sssd sssd-common python-sssdconfig \
sssd-common-pac sssd-ad sssd-ldap sssd-ipa sssd-krb5 sssd-client sssd-krb5-common krb5-workstation cups
```

### Configure NSS For Winbind ###
```bash
authconfig-tui
```

or via command

```bash
authconfig --enablewinbind --enablewinbindauth --smbsecurity ads --smbworkgroup=ROOMIT --smbrealm  roomit.tech --smbservers=ad.roomit.tech --krb5realm=roomit.tech \
--enablewinbindoffline --enablewinbindkrb5 --winbindtemplateshell=/bin/bash --winbindjoin=administrator --update  --enablelocauthorize  --enablesssdauth --enablemkhomedir --update
```

Change DNS server to Samba4 ipaddr.
```bash
  # change in /etc/resolv.conf
  nameserver 10.32.16.130
```

### Join Share Server to AD DC Samba ###
We just join with realm
```bash
realm join -U Administrator roomit.tech
```


### Configure SSSD ###
Stop sssd service
```bash
  systemctl stop sssd
```
We want login with simple name without domain and make directory only using name without domain, edit /etc/sssd/sssd.conf
```bash
[sssd]
domains = roomit.tech
config_file_version = 2
services = nss, pam
reconnection_retries = 3 #add option
sbus_timeout = 30 #add option

[pam]

[domain/roomit.tech]
ad_domain = roomit.tech
krb5_realm = roomit.tech
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
### Configure Printer File Sharing ###
Create config file share in /etc/samba/smb.conf
```bash
[global]
	load printers = No
	log file = /var/log/samba/%m.log
	map to guest = Bad User
	printcap name = /dev/null # mute annoying errors
	realm = roomit.tech
	security = DOMAIN
	workgroup = ROOMIT
	idmap config * : range = 16777216-33554431
	idmap config * : backend = tdb
	cups options = raw


[printer]
	comment = LaserJet600M602
	guest ok = Yes
	inherit acls = Yes
	inherit permissions = Yes
	path = /var/spool/samba
	printable = Yes
	printer name = printer
	read only = No
       valid users = "@ROOMIT\Domain Users"


[HPOfficeJet7110]
	comment = HPOfficeJet7110
	guest ok = Yes
	path = /var/spool/samba
	printable = Yes
	printer name = HPOfficeJet7110
	read only = No
	valid users = "@ROOMIT\Domain Users"


[lexmarkx656de]
	comment = LexMarkX656DE
	guest ok = Yes
	path = /var/spool/samba
	printable = Yes
	printer name = LexmarkX656DE
	read only = No
	valid users = "@ROOMIT\Domain Users"
```

Start Service smbd (Service For Fileshare and Printer Server), nmbd (Service For Network), Winbindd (Service For Authentication).
```bash
  systemctl start smb nmb winbind
```
### Validate Authetication ###
For testing authentication as valid and truth.
```bash
  smbclient //print-srv.roomit.tech/printer -U  dwiyan.wijatmiko -W ROOMIT
```
**Output**
```bash
Enter ROOMIT\dwiyan.wijatmiko's password: 
Try "help" to get a list of possible commands.
smb: \>
```

### Configure Printer ###
Login to https://print-srv.roomit.tech:631 
Click Administrator -> Add New Printer -> Create Driver with SAMBA -> Testing Printing
