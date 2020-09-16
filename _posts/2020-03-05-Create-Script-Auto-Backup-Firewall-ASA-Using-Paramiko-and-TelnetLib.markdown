---
layout: post
title: "[Application] Create Script Auto Backup Firewall ASA Using Paramiko and TelnetLib"
author: Galuh D Wijatmiko
categories: [Programming]
tags: [Script,Automation]
draft: false
published: true
---

[Source](https://github.com/wajatmaka/wjtTools-Script/tree/master/cisco-asa-backup)


# Automatic Network Configuration Backup #

As such a title, this tools for automatic network configuration backup cisco asa firewall

## License ##
```bash
 ---------------------------------------------------------------------------------
 "THE BEER-WARE LICENSE" (Revision 42):
 <phk@FreeBSD.ORG> wrote this file.  As long as you retain this notice you
 can do whatever you want with this stuff. If we meet some day, and you think
 this stuff is worth it, you can buy me a beer or coffee in return. Poul-Henning Kamp
 ---------------------------------------------------------------------------------
 
 Created : Dwiyan Galuh W
 https://blog.roomit.tech
 https://github.com/wajatmaka
```
## Requierment ##

* python3
* configparser
* pip3
* paramiko

Install Depedency
```bash
pip3 install -r req.txt
```

# CISCO ASA FIREWALL#
## How to Play Cisco ASA ?? ##
This script can handle backup via telnet and ssh, if telnet not worked so ssh can be handle for backup.
Example, we have added in firewall-asa.cfg cisco asa-a:

```bash
[fwasa-a]
IP = 10.32.200.223
USER= sys
PASSWORD = 228844sdasf
ENABLE = sdfsdfsd
PATH = /data/backup/data
```

## How To Use? ##

```bash
python3 firewall-asa-backup

```

