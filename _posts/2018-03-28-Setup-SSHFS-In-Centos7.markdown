---
layout: post
title: Setup SSHFS Centos 7
author: Galuh D Wijatmiko
categories: ['StorageAndFilesystem',Server]
tags: [ssh,centos7,installation,Fileshare]
---

### Flow ###
1. Server A Have access to Server B via ssh
2. Server A Will be mounting /data/ in server B to /remote in Server A

### Requierment Installation ###

  `yum install epel-release`
  `yum install sshfs fuse fuse-libs`

make sure fuse was avaiable from kernel

  `lsmod | grep fuse`

probing driver kernel

  `modprobe fuse`

### Manual Mounting ###

create folder in local remote (Server A)

  `mkdir -p /remote` 

as a root user
mounting :

  `mount -t fuse.sshfs root@serverB:/data /remote`

as a user, example vagrant
check uid and gid
  
  `id vagrant`

output

  `uid=1000(vagrant) gid=1000(vagrant) groups=1000(vagrant)`

mounting :
  
  `mount -t fuse.sshfs -o  delay_connect,_netdev,user,idmap=user,transform_symlinks,reconnect,identityfile=/home/vagrant/.ssh/id_rsa,allow_other,default_permissions,uid=1000,gid=1000 userB@ServerB:/data  /remote`

### Automatic Mounting ###
add line in /etc/fstab

  `userB@ServerB:/data /remote fuse.sshfs delay_connect,_netdev,user,idmap=user,transform_symlinks,reconnect,identityfile=/home/vagrant/.ssh/id_rsa,allow_other,default_permissions,uid=1000,gid=1000 0 0`

testing

  `mount -a`

checking

  `df -h`
