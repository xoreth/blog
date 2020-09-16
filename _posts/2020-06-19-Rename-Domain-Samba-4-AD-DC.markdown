---
layout: post
title: Rename Domain Samba 4 AD DC
author: Galuh D Wijatmiko
categories: [Authentication]
tags: [samba4,renamedomain]
draft: false
published: true
---

We got case, 
we want rename base dn from dc=roomit,dc=com to dc=roomit,dc=tech

Just do it :

Remove all data in NEW SERVER AD

```bash
cp /etc/samba/smb.conf ~/ && systemctl stop samba && rm -rf /etc/samba && mkdir -p /etc/samba 
```


Dump Data Samba ad dc in OLD SERVER AD
```bash
samba-tool domain backup rename ROOMIT ROOMIT.TECH --server=ad.roomit.com --targetdir=/opt/ -Udwiyan.wijatmiko
```

copy data dumped *.tar.gz to NEW Server AD and restore
```bash
samba-tool domain backup restore --backup-file=filebackupdumped.tar.gz --newservername=addc1 --targetdir=/etc/samba
```

