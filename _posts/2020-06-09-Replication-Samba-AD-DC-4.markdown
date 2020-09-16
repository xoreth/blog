---
layout: post
title: Replication Samba AD DC 4
author: Galuh D Wijatmiko
categories: [Authentication]
tags: [samba4,sambaaddc,samba]
draft: false
published: true
---

Best Practice Replication :

Master

in /etc/samba/smb.conf
```bash
# Global parameters
[global]
    dns forwarder = 10.0.2.3
    netbios name = ADDC1
    realm = ROOMIT.SSO
    server role = active directory domain controller
    workgroup = ROOMIT
    idmap_ldb:use rfc2307 = yes
        ### BARU ###
        tls enabled  = yes
        tls keyfile  = tls/key.pem
        tls certfile = tls/cert.pem
        tls cafile   = tls/ca.pem
        winbind use default domain = yes
        template homedir = /home/%U
        template shell   = /bin/bash
        ntlm auth = mschapv2-and-ntlmv2-only
        client ldap sasl wrapping = sign
        ldap server require strong auth = no
        interfaces = lo eth1
        bind interfaces only = yes

[netlogon]
    path = /var/lib/samba/sysvol/roomit.sso/scripts
    read only = No

[sysvol]
    path = /var/lib/samba/sysvol
    read only = No
```

on slave initiate replication
```bash
samba-tool domain join roomit.sso  DC -U administrator --dns-backend=SAMBA_INTERNAL 
```

on master
```bash
tdbbackup -s .bak /etc/samba/idmap.ldb
scp scp idmap.ldb.bak vagrant@192.168.33.14:~/
```
on slave
```bash
cp ~/idmap.ldb.bak /etc/samba/idmap.ldb
systemctl start samba
```

on slave master check replication:
```bash
samba-tool drs showrepl
```

copy config /etc/samba/smb.cnf on master to slave, don't forget ssl and dns forwarder parameter.