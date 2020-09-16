---
layout: post
title: Fixing Issue Ansible sftp transfer mechanism failed on [xx.xxx.xxx.xx] CentOS
author: Galuh D Wijatmiko
categories: [Provisioning,Troubleshot]
tags: [Ansible,Script,Provisioning,Troubleshot]
draft: False
published: True
---


Have issue about this :

```
TASK [Gathering Facts] *****************************************************************************************************************
[WARNING]: Unhandled error in Python interpreter discovery for host xx.xx.xx.xx: unexpected output from Python interpreter discovery
[WARNING]: sftp transfer mechanism failed on [xx.xx.xx.xx]. Use ANSIBLE_DEBUG=1 to see detailed information
[WARNING]: scp transfer mechanism failed on [xx.xx.xx.xx]. Use ANSIBLE_DEBUG=1 to see detailed information
[WARNING]: Platform unknown on host xx.xx.xx.xx is using the discovered Python interpreter at /usr/bin/python, but future installation
of another Python interpreter could change this. See
https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more information.
ok: [xx.xx.xx.xx]
```

on /etc/ssh/sshd_config, comment line 
> Subsystem	sftp	/usr/libexec/openssh/sftp-server

and change with this
> Subsystem sftp internal-sftp

Restart Service sshd

```bash
systemctl restart sshd
```