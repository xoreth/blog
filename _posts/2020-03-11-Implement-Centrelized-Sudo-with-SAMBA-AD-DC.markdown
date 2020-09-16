---
layout: post
title: Implement Centrelized Sudo with SAMBA AD DC
author: Galuh D Wijatmiko
categories: [Authentication,SecurityTunningAndHardening]
tags: [Security,samba4]
draft: false
published: true
[Table Of Content]: #https://ecotrust-canada.github.io/markdown-toc/
---

# Table Of Contents - [Table Of Contents](#table-of-contents)
- [Table Of Mechine](#table-of-mechine)
- [Configure Vagrant](#configure-vagrant)
- [Install And Configure SAMBA AD DC](#install-and-configure-samba-ad-dc)
- [Configure Sudoers using Windows Server](#configure-sudoers-using-windows-server)
  * [Setting Keyboard and Time](#setting-keyboard-and-time)
  * [Join Windows Server to SAMBA AD DC](#join-windows-server-to-samba-ad-dc)
    + [Setting DNS](#setting-dns)
    + [Joining Windows Server]({{site.url}}/notes/2020/03/11/implement-centrelized-sudo-with-samba-ad-dc/#joining-windows-server)
  * [Install RSAT (Remote Server Administrator Tools)](#install-rsat--remote-server-administrator-tools-)
  * [Import Schema Sudo](#import-schema-sudo)
  * [Copy Kerberos Config](#copy-kerberos-config)
  * [Create and Import Profile Sudo](#create-and-import-profile-sudo)
  * [Remove Unused DNS Record](#remove-unused-dns-record)
  * [Add User](#add-user)
  * [Check user](#check-user)
  * [Permission Group Sudo](#permission-group-sudo)
- [Configure Centralized Authentication in Client](#configure-centralized-authentication-in-client)
  * [Install Tools](#install-tools)
  * [Setting DNS](#setting-dns-1)
  * [PAM](#pam)
  * [Join](#join)
  * [Testing Sudo](#testing-sudo)




# Table Of Mechine
<table>
<tr>
    <th>Host</th>
    <th>IP</th>
    <th>OS</th>
    <th>Info</th>
</tr>
<tr>
    <td>addc1.roomit.tech</td>
    <td>192.168.33.13</td>
    <td>Centos 7</td>
    <td>as Samba ad dc Server</td>
</tr>
<tr>
    <td>client.roomit.tech</td>
    <td>192.168.33.14</td>
    <td>Centos 7</td>
    <td>as Client will doing sudo</td>
</tr>
<tr>
    <td>ws.roomit.tech</td>
    <td>192.168.33.15</td>
    <td>Windows Server 2008 RC 2</td>
    <td>Installation Sudoers</td>
</tr>
</table>


# Configure Vagrant
Create Directory and Configure Vagrant File
```bash
mkdir myVagrant
cd myVagrant/
vim Vagrantfile
```

Copy Paste
```bash
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure("2") do |config|
    config.vm.box_check_update = false
    config.vm.define "addc1" do |addc1|
        addc1.vm.box = "bento/centos-7.7"
        addc1.vm.hostname = "addc1.roomit.tech"
        addc1.vm.network "private_network", ip: "192.168.33.13"
        addc1.vm.provider "virtualbox" do |vb|
                vb.name = "addc1"
                vb.memory = "1024"
                vb.cpus  = 1
        end
    end
    config.vm.define "client" do |client|
        client.vm.box = "bento/centos-7.7"
        client.vm.hostname = "client.roomit.tech"
        client.vm.network "private_network", ip: "192.168.33.14"
        client.vm.provider "virtualbox" do |vb|
                vb.name = "client"
                vb.memory = "1024"
                vb.cpus  = 1
        end
    end
    config.vm.define "ws" do |ws|
        ws.vm.box = "mrlunar/windows-server-2008r2"
        ws.vm.hostname = "ws.roomit.tech"
        ws.vm.network "private_network", ip: "192.168.33.15"
        ws.vm.provider "virtualbox" do |vb|
                vb.name = "ws"
                vb.memory = "2048"
                vb.cpus  = 2
                vb.gui  = true
        end
    end
end

```

Running Vagrant
```bash
vagrant up addc1 client ws
```

> TURN OF FIREWALL IN ALL NODE (temporary)

# Install And Configure SAMBA AD DC
Please, Install samba first
source : [Install Samba]({{ site.url }}/notes/2020/03/03/install-samba-4-ad-dc/)

> Note

Make Sure Parameter when installation change to
* REALM : ROOMIT.TECH
* NETBIOS : addc1
* WORKGROUP: ROOMIT

the purpose for match with this tutorial

# Configure Sudoers using Windows Server

## Setting Keyboard and Time
Go to
* Control Panel
* Clock, Language, And Region
* Date And Time
    * Change Timezone

      > change to UTC +7 Jakarta

      ![Timezone](/assets/images/data_blog/TimeZoneSettings.png)
* Region And language
    * Change Keyboard and Languages

      > Default Input Language  US Indonesia

        ![Keyboard And Languages](/assets/images/data_blog/KeyboardAndLanguages)
    
## Join Windows Server to SAMBA AD DC
### Setting DNS
Go to
* Control Panel
* Network And Internet
* Network And Sharing Center
* Change Adapter Settings
* Right Click Local Area Network 2 -> Properties
* Internet Protocol Version 4 -> Properties
* Use The Following DNS Server Address
  > 192.168.33.13 (IP Server AD)

  ![Setting DNS](/assets/images/data_blog/SettingDNSWindows.png)

Testing DNS 
* Windows + R
* ping roomit.auth

![Testing DNS](/assets/images/data_blog/PingDNS.png)


Output : 
> Replay ...
  
### Joining Windows Server
Go to
* Control Panel
* System And Security
* System
* Remote Settings 
* Computer Name (Tab)
* Change Domain
    > roomit.auth
* Pop Up Dialog
    > Username : Administrator
    
    > Password : YourPassword
* Restart Your 
* Login With account Administrator
    > Username : administrator@roomit.auth

    > Password : YourPassword

> Make Sure Your Keyboard Still Using US - Indonesia

![Joining Windows Server](/assets/images/data_blog/JoinDomain.png)

## Install RSAT (Remote Server Administrator Tools)
Go to
* Control Panel
* Programs
* Programs And Features
* Turn Windows Features on or off
* Features (Below Roles)
* Install RSAT

    ![Install RSAT](/assets/images/data_blog/InstallRSAT.png)

* Restart

## Import Schema Sudo
Go to
* Start 
* Administrative Tools
* Adsi Edit
* Action
* Connect to 

Go to addc1.roomit.tech in your host
```bash
vagrant ssh addc1
```
Go to document sudo and listening port 8080
```bash
sudo su
cd /usr/share/doc/sudo-1.8.23/
python -m SimpleHTTPServer 8080
```
After that
add option  in [global] /etc/samba/smb.conf
```bash
# Global parameters
[global]
	dns forwarder = 10.0.2.3
	netbios name = ADDC1
	realm = ROOMIT.AUTH
	server role = active directory domain controller
	workgroup = ROOMIT
	idmap_ldb:use rfc2307 = yes
    dsdb:schema update allowed = Yes #add this 
    client ldap sasl wrapping = sign #add this
    ldap server require strong auth = no #add this
    bind interfaces only = yes  #add this
    interfaces = lo eth1  #add this



[netlogon]
	path = /var/lib/samba/sysvol/roomit.auth/scripts
	read only = No

[sysvol]
	path = /var/lib/samba/sysvol
	read only = No
```

## Copy Kerberos Config
```bash
cp /etc/samba/krb5.conf /etc/samba
```

content krb5.conf:
```bash
[libdefaults]
	default_realm = ROOMIT.AUTH
	dns_lookup_realm = false
	dns_lookup_kdc = true

```

Restart samba on root
```bash
systemctl restart samba
```

Go to Windows Server Again
* Open Browser Internet Explorer
* Open Url : http://192.168.33.13:8080
* Download schema.ActiveDirectory
* Create Folde in C:\\SUDO
* Save schema.ActiveDirectory in C:\\SUDO
* Open CMD
* execute this command

```bash
cd \
cd SUDO
ldifde -i -f schema.ActiveDirectory -c dc=X dc=roomit,dc=auth
```
Output:

![Import Schema](/assets/images/data_blog/importSchemaSudo
.png)

Go to Server addc1
Create OU 
```bash
samba-tool ou create "ou=sudoers"
```
Listing OU
```bash
samba-tool ou list
```
Output:
```bash
OU=sudoers
OU=Domain Controllers
```

## Create and Import Profile Sudo
Go to addc1 Server
Create file crud.ldif:
```bash
dn: CN=crud,OU=sudoers,DC=roomit,DC=auth
objectClass: top
objectClass: sudoRole
cn: crud
distinguishedName: CN=crud,OU=sudoers,DC=roomit,DC=auth
name: crud
sudoHost: ALL
sudoUser: dwiyan.wijatmiko
sudoCommand: /usr/bin/less
sudoCommand: /usr/bin/vi /etc/hosts
sudoCommand: /usr/bin/vim /etc/hosts
sudoCommand: /usr/bin/nano /etc/hosts
sudoCommand: /usr/bin/tail
sudoCommand: /usr/bin/more
```
Import Profile Ldif
```bash
ldbadd  -H  /etc/samba/sam.ldb  crud.ldif
```
## Remove Unused DNS Record
Remove A with IP 10.0.2.15
```bash
samba-tool dns delete localhost roomit.auth @ A 10.0.2.15 -U administrator
```
Remove A record with name addc1 and ip 10.0.2.15
```bash
samba-tool dns delete localhost roomit.auth  addc1 A 10.0.2.15 -U administrator
```
## Add User
```bash
samba-tool user create dwiyan.wijatmiko
```

## Check user
```bash
samba-tool user list | grep dwiyan.wi
```

## Permission Group Sudo
Go to Windows Server
* Start 
* Administrative Tools
* Adsi Edit
* Action
* Connect to 
* Expand DC=roomit,DC=auth
* Click Right on ou=sudoers - Properties
* Tab Security
* Add Group "Domain Users" And "Domain Computer"

![Add User and Group](/assets/images/data_blog/addGroupUserComputer.png)

* Advanced
* Domain Computers -> edit
* Apply to _this object and all descendant objects_
* Domain Users -> edit
* Apply to _this object and all descendant objects_

![Add User and Group](/assets/images/data_blog/PermissionsObject.png)



# Configure Centralized Authentication in Client 
Running VM Client
```bash
vagrant up client
```

login to VM Client
```bash
vagrant ssh client
```

## Install Tools
Update First For debian:
```bash
apt update
```

For DEB Base
```bash
apt -y install realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin oddjob oddjob-mkhomedir packagekit krb5-user
```

For RPM Base
```bash
yum install realmd sssd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation 
``` 
## Setting DNS
vi /etc/resolv.conf or you can manage in network setting using networkmanager or netplan.
```bash
nameserver 192.168.33.13
```

## PAM
Configure PAM DEB Base
```bash
echo "session    required    pam_mkhomedir.so skel=/etc/skel/ umask=0022" >>  /etc/pam.d/common-session  
```

Configure PAM RPM BASE
```bash
authconfig --enablemkhomedir --update
```

## Join
Discover AD Domain
```bash
realm discover ROOMIT.AUTH

roomit.auth
  type: kerberos
  realm-name: ROOMIT.AUTH
  domain-name: roomit.auth
  configured: no
  server-software: active-directory
  client-software: sssd
  required-package: sssd-tools
  required-package: sssd
  required-package: libnss-sss
  required-package: libpam-sss
  required-package: adcli
  required-package: samba-common-bin
```

join 
```bash
realm join ROOMIT.AUTH -U Administrator
```

Check User
```bash
id dwiyan.wijatmiko@roomit.auth

uid=1157201105(dwiyan.wijatmiko@roomit.auth) gid=1157200513(domain users@roomit.auth) groups=1157200513(domain users@roomit.auth)
```

change sssd config /etc/sssd/sssd.conf
```bash
....
use_fully_qualified_names = False
fallback_homedir = /home/%u
...
```

or change become
```
[sssd]
domains = roomit.auth
config_file_version = 2
services = nss, pam, sudo

[sudo]

[pam]
offline_credentials_expiration = 120 #120 days offline cache

[domain/roomit.auth]
debug_level = 6 
ad_domain = roomit.auth
krb5_realm = ROOMIT.AUTH
realmd_tags = manages-system joined-with-adcli 
cache_credentials = True
id_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_id_mapping = True
use_fully_qualified_names = False #Remove Domain 
fallback_homedir = /home/%u #Standard home directory
access_provider = ad
sudo_provider = ad
ldap_sudo_search_base = ou=sudoers,dc=roomit,dc=auth
ldap_sudo_full_refresh_interval = 86400
ldap_sudo_smart_refresh_interval = 3600
```

add this if you want limit user login in mechine
```bash
ad_access_filter = (memberOf=CN=Operation,CN=Users,DC=roomit,DC=auth) #Filtering by Group
```

## Testing Sudo
```bash
sudo -l
```