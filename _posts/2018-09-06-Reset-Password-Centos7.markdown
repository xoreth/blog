---
layout: post
title: Centos 7 Recovery
author: Galuh D Wijatmiko
categories: [Troubleshot]
tags: [Linux,Recovery]
---

ON GRUB EDIT
add line 

```bash
rd.break systemd.unit=emergency.target
```


#luthfi
