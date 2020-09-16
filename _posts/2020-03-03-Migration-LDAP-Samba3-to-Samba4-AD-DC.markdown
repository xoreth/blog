---
layout: post
title: Migration LDAP-Samba3 to Samba4 AD DC
author: Galuh D Wijatmiko
categories: [Authentication]
tags: [samba4,samba3,ldap,migrationldap,centos7]
---

# Preparing Upgrade Samba3 to Samba 4 AD DC

Create Directory For Database Samba3

```bash
mkdir -p /var/lib/samba.PDC/
mkdir -p /etc/samba.PDC/
mkdir /var/lib/samba.PDC/dbdir/
```

Copy All Config Data to New Directory

```bash
mv /etc/samba.PDC/smb.conf /etc/samba.PDC/smb.PDC.conf
cp -p /var/lib/samba.PDC/private/secrets.tdb /var/lib/samba.PDC/dbdir/
cp -p /var/lib/samba.PDC/private/schannel_store.tdb /var/lib/samba.PDC/dbdir/
cp -p /var/lib/samba.PDC/private/passdb.tdb /var/lib/samba.PDC/dbdir/
cp -p /var/lib/samba.PDC/var/lock/gencache_notrans.tdb /var/lib/samba.PDC/dbdir/
cp -p /var/lib/samba.PDC/var/locks/group_mapping.tdb /var/lib/samba.PDC/dbdir/
cp -p /var/lib/samba.PDC/var/locks/account_policy.tdb /var/lib/samba.PDC/dbdir/
```

> Make Sure LDAP Service Still Running
```bash
ps -ef | grep  slapd
```

# Process Upgrade Samba3 to Samba 4 AD DC
Start migration
```bash
samba-tool domain classicupgrade --dbdir=/var/lib/samba.PDC/dbdir/ --realm=addc1.roomit.tech --dns-backend=SAMBA_INTERNAL /etc/samba.PDC/smb.PDC.conf 
```
Output:
```bash
Reading smb.conf
Provisioning
Exporting account policy
Exporting groups
Exporting users
Next rid = 1007
Exporting posix attributes
Reading WINS database
Cannot open wins database, Ignoring: [Errno 2] No such file or directory: '/var/lib/samba.PDC/dbdir/wins.dat'
Looking up IPv4 addresses
Looking up IPv6 addresses
No IPv6 address will be assigned
Setting up share.ldb
Setting up secrets.ldb
Setting up the registry
Setting up the privileges database
Setting up idmap db
Setting up SAM db
Setting up sam.ldb partitions and settings
Setting up sam.ldb rootDSE
Pre-loading the Samba 4 and AD schema
Adding DomainDN: DC=addc1,DC=roomit,DC=tech
Adding configuration container
Setting up sam.ldb schema
Setting up sam.ldb configuration data
Setting up display specifiers
Modifying display specifiers
Adding users container
Modifying users container
Adding computers container
Modifying computers container
Setting up sam.ldb data
Setting up well known security principals
Setting up sam.ldb users and groups
Setting up self join
Setting acl on sysvol skipped
Adding DNS accounts
Creating CN=MicrosoftDNS,CN=System,DC=fatagar,DC=roomit,DC=tech
Creating DomainDnsZones and ForestDnsZones partitions
Populating DomainDnsZones and ForestDnsZones partitions
See /var/lib/samba/private/named.conf for an example configuration include file for BIND
and /var/lib/samba/private/named.txt for further documentation required for secure DNS updates
Setting up sam.ldb rootDSE marking as synchronized
Fixing provision GUIDs
A Kerberos configuration suitable for Samba 4 has been generated at /var/lib/samba/private/krb5.conf
Setting up fake yp server settings
Once the above files are installed, your Samba4 server will be ready to use
Server Role:           active directory domain controller
Hostname:              ADDC1
NetBIOS Domain:        ADDC1
DNS Domain:            addc1.roomit.tech
DOMAIN SID:            S-1-5-21-4097619914-84555263-3210783664
Importing WINS database
Importing Account policy
Importing idmap database
Cannot open idmap database, Ignoring: [Errno 2] No such file or directory
Adding groups
Importing groups
Group already exists sid=S-1-5-21-4097619914-84555263-3210783664-513, groupname=Domain Users existing_groupname=Domain Users, Ignoring.
Commiting 'add groups' transaction to disk
Adding users
Importing users
Commiting 'add users' transaction to disk
Adding users to groups
Commiting 'add users to groups' transaction to disk
Setting password for administrator
```

> Note: If you re-run the classicupgrade, you will need to remove the auto-generated smb.conf and the databases:
```bash
rm -f /etc/samba/smb.conf
rm -rf /var/lib/samba/private/*
```
