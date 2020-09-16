---
layout: post
title: "[Ruby] Install Ruby"
author: Galuh D Wijatmiko
categories: [Programming]
tags: [ruby,ror]
draft: false
published: true
[Table Of Content]: #https://ecotrust-canada.github.io/markdown-toc/
---


# On ArchLinux
On Arch Linux is very completed ruby and rbenv
```bash
yay -S ruby ruby-build rbenv yarn
```

# DEB Base And RPM Base
RPM Depend
```bash
yum install -y bash curl git patch 
curl -sL https://dl.yarnpkg.com/rpm/yarn.repo -o /etc/yum.repos.d/yarn.repo
yum install -y yarn
```

DEB Depend
```bash
apt-get install bash curl git-core patch
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt update
apt install yarn
```

# Install Rbenv
Cloning Package and Setup rbenv
```bash
cd ~/
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL
```

Add Ruby Environment
```bash
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
exec $SHELL
```


Install Ruby Version
```bash
rbenv install 2.5.7
rbenv rehash
rbenv global 2.5.7
ruby -v
```