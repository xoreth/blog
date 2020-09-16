---
layout: post
title: ACL File And Directory on Unix Like
author: Galuh D Wijatmiko
categories: [Server,SecurityTunningAndHardening]
tags: [ACL,Script]
---

### ACL LINUX ####


Package ACL in linux have 3 command
- setfacl
- getfacl
- chacl


##### How to Set Access List a Folder/File? #####
Example  :
```bash
> sudo su

# touch file.txt

# ls -ltr
total 0
-rw-r--r-- 1 root root 0 Apr 10 10:14 file.txt

# setfacl -m u:wajatmaka:rwx file.txt

# ls -ltr
-rw-rwxr--+  1 root      root                5 Apr 10 10:18 file.txt

# getfacl file.txt
file: file.txt
owner: root
group: root
user::rw-
user:wajatmaka:rwx
group::r--
mask::rwx
other::r--

# su - wajatmaka

> vi file.txt


#chacl -B file.txt 


#getfacl file.txt 
file: file.txt
owner: root
group: root
user::rw-
group::r--
other::r--

```

Information 

> -m = modify

> -x = set

> -B = remove all acl



although mode parent owner is ROOT, but ACL permit user wajatmaka for execute, read and write file.txt
