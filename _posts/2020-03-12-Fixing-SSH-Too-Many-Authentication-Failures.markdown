---
layout: post
title: Fixing SSH Too Many Authentication Failures
author: Galuh D Wijatmiko
categories: [Troubleshot]
tags: [ssh]
draft: false
published: true
[Table Of Content]: #https://ecotrust-canada.github.io/markdown-toc/
---


Error :
```bash
Received disconnect from 192.168.33.14 port 22:2: Too many authentication failures
```

Background :
> To Many Identities in SSH Client side

Fixing:
```bash
 ssh -o IdentitiesOnly=yes username@yourserver
```

Or You can add in Config SSH as Default

~/.ssh/config

```bash
Host *
    IdentitiesOnly=yes
    PreferredAuthentications=publickey,keyboard-interactive,password
    AddressFamily inet
    Protocol 2
    Compression yes
    ServerAliveInterval 60
    ServerAliveCountMax 20
    AddKeysToAgent yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    CheckHostIP no
    UpdateHostKeys no
    LogLevel quiet
```
