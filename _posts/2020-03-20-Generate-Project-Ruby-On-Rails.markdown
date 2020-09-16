---
layout: post
title: "[Ruby] Generate Project Ruby On Rails"
author: Galuh D Wijatmiko
categories: [Programming]
tags: [ruby,ror]
draft: false
published: true
[Table Of Content]: #https://ecotrust-canada.github.io/markdown-toc/
---


First make sure, you have a ruby.
Install Rails 5.
```bash
 gem install rails -v 5.2.4.2 bundler
```

check rails
```bash
rails -v
```

Generate Project Ruby On Rails
```bash
rails new first_project
```

Running Server Builtin ROR
```bash
cd first_project
bundle install
rails server 
```

Access from your browser:
> http://localhost:3000


### TIPS AND TRICK
Remove Rails On Gems

```bash
gem uninstall rails
rails uninstall gem
rails uninstall railties
rbenv rehash
```