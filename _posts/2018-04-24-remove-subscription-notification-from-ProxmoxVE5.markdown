---
layout: post
title: Remove Subscription Notification From Proxmox VE 5
author: Galuh D Wijatmiko
categories: [Virtualization]
tags: [proxmox]
---

1. Login via ssh to host proxmox

2. Let's move to directory js

```bash
cd /usr/share/pve-manager/js/
```

3. Backup file

```bash
cp pvemanagerlib.js pvemanagerlib.js.bkp
```

4. Change File

> Before

```bash
if (data.status === 'Active') {
    Ext.Msg.show({
      title: gettext('No valid subscription'),
      icon: Ext.Msg.WARNING,
      msg: PVE.Utils.noSubKeyHtml,
      buttons: Ext.Msg.OK,
      callback: function(btn) {
          if (btn !== 'ok') {
              return;
          }
          orig_cmd();
      }
    });
} else {
    orig_cmd();
}
```

> After

```bash
if (data.status === 'Active') {
    Ext.Msg.show({
      title: gettext('No valid subscription'),
      icon: Ext.Msg.WARNING,
      msg: PVE.Utils.noSubKeyHtml,
      buttons: Ext.Msg.OK,
      callback: function(btn) {
          if (btn !== 'ok') {
              return;
          }
          orig_cmd();
      }
    });
} else {
    orig_cmd();
}
```
