---
layout: post
title: Install Font In Linux
author: Galuh D Wijatmiko
categories: [Tools]
tags: [Font,InstallFont,Desktop]
draft: false
published: true
---



Download Font what you want in [Google Font](https://fonts.google.com/)

```bash
wget -c https://fonts.google.com/download?family=Titillium%20Web
```

*Create Directory For Assign  Font*

this is will read for only level user
```bash
mkdir -p ~/.local/share/fonts 
```

or 

This is will read for All system Linux
```bash
mkdir -p  /usr/share/fonts/
```

Extract and copy font to directory 
```bash
unzip Titillium_Web.zip -d  ~/.local/share/fonts 
```

Clear cache Fonts
```bash
fc-cache -f -v
```

Search font titillium to make sure font already updated
```bash
fc-list | grep  -i titillium
```


