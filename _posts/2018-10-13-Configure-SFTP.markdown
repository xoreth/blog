---
layout: post
title: Configure SFTP Server Fot File Sharing
author: Galuh D Wijatmiko
categories: [Server]
tags: [sftp,network,Server,Fileshare]
---
# SFTP Server  Centos 7 #

Create Directory in /data/sftp

```bash
mkdir -p /data/sftp
```

Create User and store home in /data/sftp expired until 2018-10-28

```bash
adduser --home /data/sftp/bangladesh -s /sbin/nologin  -e 2018-10-28 bangladesh
```

Create directory files for upload data in /data/sftp/bangladesh/files and .ssh

```bash
mkdir -p /data/sftp/bangladesh/files
mkdir -p /data/sftp/bangladesh/.ssh
touch /data/sftp/bangladesh/.ssh/authorized_keys
```

Create group sftpusers and sign user bangladesh to group sftpusers

```bash
usermod bangladesh -G sftpusers
```

Configure Access Mode and Owner 

```bash
chmod 755 /data/sftp
chown root:root /data/sftp
chmod 640 /data/sftp/bangladesh
chown root:sftpusers /data/sftp/bangladesh
chmod 777 /data/sftp/bangladesh/files
chown bangladesh:sftpusers /data/sftp/bangladesh/files
chmod 700 /data/sftp/bangladesh/.ssh
chown bangladesh:bangladesh -R /data/sftp/bangladesh/.ssh
chmod 600 /data/sftp/banladesh/.ssh/authorized_keys
```

Fill public key in /data/sftp/bangladesh/.ssh/authorized_keys

```bash
cat id_rsa.pub >> /data/sftp/bangladesh/.ssh/authorized_keys
```


Comment line "#Subsystem	sftp	/usr/libexec/openssh/sftp-server"
and add line 

```bash
Subsystem       sftp    internal-sftp -f AUTH -l INFO
Match Group sftpusers
      ChrootDirectory /data/sftp/bangladesh
      AllowTCPForwarding no
      X11Forwarding no
      ForceCommand internal-sftp 
```

Restart SSHD

```bash
systemctl restart sshd
```

Test upload data

```bash
sftp -i bangladesh.rsa.id bangladesh@server

```
