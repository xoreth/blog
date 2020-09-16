---
layout: post
title: Joining Domain Centos7 and Ubuntu18 to Samba AD DC Using Realm
author: Galuh D Wijatmiko
categories: [Authentication]
tags: [JoinDomain,samba4]
draft: false
published: true
---




Login As ROOT
```bash
su - root
```

#### Ubuntu ####

Install Depedency
```bash
apt -y install realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit
```

Enable PAM Access
```bash
bash -c "cat > /usr/share/pam-configs/mkhomedir" <<EOF
Name: activate mkhomedir
Default: yes
Priority: 900
Session-Type: Additional
Session:
        required                        pam_mkhomedir.so umask=0022 skel=/etc/skel
EOF
```

Checklist for enable make directory home
```bash
pam-auth-update
```

Joining
```bash
realm discover roomit.sso
realm join -v -U dwiyan.wijatmiko roomit.sso
```


 
#### Centos ####
Install Depedency
```bash
yum -y install realmd sssd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation
```

Enable PAM Access
```bash
authconfig --enablewinbind --enablewinbindauth --smbsecurity ads --smbworkgroup=ROOMIT --smbrealm  roomit.tech --smbservers=ad.roomit.tech --krb5realm=roomit.tech \
--enablewinbindoffline --enablewinbindkrb5 --winbindtemplateshell=/bin/bash --winbindjoin=administrator --update  --enablelocauthorize  --enablesssdauth --enablemkhomedir --update
```

Joining
```bash
realm discover roomit.sso
realm join -v -U dwiyan.wijatmiko roomit.sso
```



