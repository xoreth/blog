---
layout: post
title: Store Package RPM and DEB
author: Galuh D Wijatmiko
categories: [Packaging,Script]
tags: [Linux,Package,LinuxPackage,Script]
---

# SAVE PACKAGE RPM or DEB#


## Save Package RPM ##

```bash
yum install namepackage --downloadonly --downloaddir=/opt/
```

## Save Package DEB ##

```bash
apt-get download namepackage && apt-cache depends -i namepackage | awk '/Depends:/ {print $2}'| xargs apt-get download
```
