---
layout: post
title: Hardening SSH
author: Galuh D Wijatmiko
categories: [SecurityTunningAndHardening]
tags: [ssh,hardening]
---

### Secure SSH Config ###


1. sshd_config

```bash
ListenAddress 159.89.98.163:57913
ListenAddress 10.8.0.1:22
Protocol 2
AllowTcpForwarding no
ClientAliveCountMax  2
Compression no 
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
SyslogFacility AUTHPRIV
GatewayPorts no
LogLevel verbose
MaxAuthTries 2
MaxSessions 2
TCPKeepAlive no
X11Forwarding no
AllowAgentForwarding yes
PermitRootLogin no
PubkeyAuthentication yes
AuthorizedKeysFile	.ssh/authorized_keys
PasswordAuthentication no
ChallengeResponseAuthentication no
GSSAPIAuthentication no
GSSAPICleanupCredentials no
UsePAM yes
X11Forwarding yes
UseDNS no
Banner /etc/ssh/sshd_banner
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
AcceptEnv XMODIFIERS
Subsystem	sftp	/usr/libexec/openssh/sftp-server
```


sshd_banner

```bash
                                                                #####
                                                                #######
                   @                                            ##O#O##
  ######          @@#                                           #VVVVV#
    ##             #                                          ##  VVV  ##
    ##         @@@   ### ####   ###    ###  ##### ######     #          ##
    ##        @  @#   ###    ##  ##     ##    ###  ##       #            ##
    ##       @   @#   ##     ##  ##     ##      ###         #            ###
    ##          @@#   ##     ##  ##     ##      ###        QQ#           ##Q
    ##       # @@#    ##     ##  ##     ##     ## ##     QQQQQQ#       #QQQQQQ
    ##      ## @@# #  ##     ##  ###   ###    ##   ##    QQQQQQQ#     #QQQQQQQ
  ############  ###  ####   ####   #### ### ##### ######   QQQQQ#######QQQQQ
     ********************************************************************
     *                                                                  *
     * This system is for the use of authorized users only.  Usage of   *
     * this system may be monitored and recorded by system personnel.   *
     *                                                                  *
     * Anyone using this system expressly consents to such monitoring   *
     * and is advised that if such monitoring reveals possible          *
     * evidence of criminal activity, system personnel may provide the  *
     * evidence from such monitoring to law enforcement officials.      *
     *                                                                  *
     ********************************************************************
                            VPS.WAJATMAKA.COM

```
