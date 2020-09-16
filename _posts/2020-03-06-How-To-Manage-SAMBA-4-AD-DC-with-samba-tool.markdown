---
layout: post
title: How To Manage SAMBA 4 AD DC with samba-tool
author: Galuh D Wijatmiko
categories: [Authentication]
tags: [samba4]
draft: false
published: true
---

[[Category:Fileshare]]
## CREATE USER ##
```bash
  samba-tool user create foo.bar 
```
## ADD FIRSTNAME AND LASTNAME STRUCTURE ##
Create file foo.bar.fl.ldif
```bash
dn: CN=foo.bar,CN=Users,DC=roomit,DC=com
changetype: modify
replace: givenName
givenName: foo
replace: sn
sn: bar
```
Apply ldif to user
```bash
ldbmodify -H  /etc/samba/private/sam.ldb   foo.bar.fl.ldif
```

## ADD EMAIL STRUCTURE ##
Create file foo.bar.mail.ldif
```bash
dn: CN=foo.bar,CN=Users,DC=roomit,DC=com
changetype: modify
replace: mail
mail: foo.bar@roomit.com
```
Apply ldif to user
```bash
ldbmodify -H  /etc/samba/private/sam.ldb   foo.bar.mail.ldif
```

## CREATE GROUP ##
Create group as department
```bash
samba-tool group add System-Architect-Design-And-Analyst 
samba-tool group add Finance-And-Accounting 
samba-tool group add Telco
samba-tool group add Operation 
samba-tool group add HRD 
samba-tool group add Development 
samba-tool group add QA-QC 
samba-tool group add Project-Management 
samba-tool group add Sales-And-Marketing 
samba-tool group add DevOps 
samba-tool group add Top-Management 
samba-tool group add GA 
```

Create group as filesharing
```bash
samba-tool group add share-hrd
samba-tool group add share-adm
samba-tool group add share-fin
samba-tool group add share-dev
samba-tool group add share-mkt
samba-tool group add share-tel
samba-tool group add share-ga
samba-tool group add share-mgt
```

Create group as additional 
Application mediawiki wikiops.roomit.com need seperate for read and write.
```bash
samba-tool group add Mediawiki-Operation
samba-tool group add Junior-Operation
samba-tool group add Senior-Operation
```

Finance need audit file sharing marketing
```bash  
samba-tool group add Finance-And-Marketing
```
## ASSIGN GROUP TO GROUP ##
example, share-dev have included department Development, QA/QC and Project Management.
```bash
samba-tool group addmembers share-dev Development
samba-tool group addmembers share-dev QA-QC 
samba-tool group addmembers share-dev Project-Management 
```

Lisitng group share-dev
```bash
samba-tool group listmembers share-dev

#[root@ad ~]# samba-tool group listmembers share-dev
#QA-QC
#Development
```

## ASSIGN USER TO GROUP ##
example, user foo.bar have opeartion department
```bash
samba-tool group addmembers Operation foo.bar
```
Listing
```bash 
  samba-tool group listmembers Operaion
```
## REMOVE USER ##
```bash
  samba-tool user delete foo.bar
```
## REMOVE GROUP From GROUP ##
```bash
  samba-tool group deletemembers share-dev Operation
```

## REMOVE User From Group ##
```bash
  samba-tool group deletemembers Operation foo.bar
```
## REMOVE GROUP ##
```bash
  samba-tool group delete Operation
```
## RESET User Password ##
```bash
  samba-tool user setpassword foo.bar
```
## REMOVE NS ##
```bash
samba-tool dns delete localhost roomit.auth @ NS adprimary.roomit.com.roomit.auth -U dwiyan.wijatmiko
```
## LIST DNS ##
```bash
samba-tool dns query localhost roomit.auth @ ALL -U dwiyan.wijatmiko
```
## Remove A Record ##
```bash
samba-tool dns delete localhost roomit.auth @ A 10.0.2.15 -U dwiyan.wijatmiko
```
## Add A record ##
```bash
samba-tool dns add localhost roomit.auth adsecondary A 192.168.33.14 -U dwiyan.wijatmiko
```