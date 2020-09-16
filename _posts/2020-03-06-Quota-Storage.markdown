---
layout: post
title: Quota Storage
author: Galuh D Wijatmiko
categories: [StorageAndFilesystem]
tags: [samba4,quota,Fileshare]
draft: false
published: true
---


## Install Quota ##
```bash
yum install -y quota-4.01-19.el7.x86_64 \
quota-warnquota-4.01-19.el7.x86_64 \
quota-nls-4.01-19.el7.noarch \
quota-devel-4.01-19.el7.x86_64
```

## Configure Quota ##
Example, we had disk /dev/md0 (mirroring) and mounted in /home, We will limit per-user for quota storage. So open **/etc/fstab** :
```bash
  /dev/md0                /home                    ext4     defaults,rw,usrquota,grpquota  0 2
```

Remounting again your home :
```bash
  mount -o remount /home
```

## Create Quota ##
```bash
  quotacheck -cugv /home
```

Where :
```bash
-c : create quota file and don’t use the existing file
-v : verbose ouput
-u : user disk quota
-g : group disk quota
```

Above Command will create aquota.user & aquota.group files under /home

## Turn ON Quota ##
```bash
  quotaon /home/
```

## Lisitng Quota ##
```bash
  quota -v
```

## Add Quota User ##
```bash
  edquota -u foo.bar
```
Output :
 ```bash
Disk quotas for user foo.bar (uid 545022322):
  Filesystem                   blocks       soft       hard     inodes     soft     hard
  /dev/md0                          4   10000000   10000000          1        0        0
```

