---
layout: post
title: Export Cookies Firefox
author: Galuh D Wijatmiko
categories: [SecurityTunningAndHardening]
tags: [cookies]
draft: false
published: true
[Table Of Content]: #https://ecotrust-canada.github.io/markdown-toc/
---


Install sqlite3
```bash
apt install sqlite3 mlocate
yum install sqlite3 mlocate
```

Search and move to your cookies database in ~/.mozilla/firefox/YourProfile.default
Or 
You can Search with locate
```bash
updatedb 
locate cookies.sqlite
```

after that enter to database:
```bash
sqlite cookies.sqlite
> .output mozilla_cookies.txt
> select * from moz_cookies;
```