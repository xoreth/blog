---
layout: post
title: Server Authentication Freeradius Using Samba 4 AD DC authentication
author: Galuh D Wijatmiko
categories: [SecurityTunningAndHardening,Authentication,Networks]
tags: [freeradius,samba4]
draft: false
published: true
---


## Overview ##
Concept:<br/>
![Concept 802.1x](/assets/images/data_blog/Concept-802.1x.png)

Freeradius server specifications:
```bash
  Operating system: Centos 7
  Processor: 1 core
  Memory: 1GB
  Storage: 10GB
  Freeradius: ver.3.0.20
```
 ## Install Freeradius ##
Import  RPM public key for the LDAP Toolbox Project:
```bash
  $ rpm --import <nowiki>https://ltb-project.org/lib/RPM-GPG-KEY-LTB-project</nowiki>
```

Create a Yum / DNF repository file for the LDAP Toolbox Project:
```bash
  $ echo '[ltb-project]
  name=LTB project packages
  baseurl=<nowiki>https://ltb-project.org/rpm/$releasever/$basearch</nowiki>
  enabled=1
  gpgcheck=1
  gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-LTB-project' > /etc/yum.repos.d/ltb-project.repo
```
Import the PGP key for NetworkRADIUS:
```bash
  $ gpg --keyserver keys.gnupg.net --recv-key 0x41382202
  $ gpg --armor --export packages@networkradius.com > /etc/pki/rpm-gpg/packages.networkradius.com.gpg
```
Create a Yum / DNF repository file for NetworkRADIUS:
```bash
  $ echo '[networkradius]
  name=NetworkRADIUS-$releasever
  baseurl=<nowiki>http://packages.networkradius.com/releases/centos/$releasever/repo/</nowiki>
  gpgcheck=1
  gpgkey=file:///etc/pki/rpm-gpg/packages.networkradius.com.gpg' >  /etc/yum.repos.d/networkradius.repo
```
Install freeradius packages:
```bash
  $ yum install -y freeradius-*
```

## Join in Samba4 Active Directory Domain ##
Install some required packages.
```bash
  $ yum -y install realmd sssd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation
  $ yum install -y samba-*
```

Enable and start necessary services.
```bash
  $ systemctl enable smb nmb winbind
  $ systemctl start smb nmb winbind
```
Change DNS server to Samba4 ipaddr.
```bash
  # change in /etc/resolv.conf
  nameserver 10.32.16.130
```

Join in Samba4 domain.
```bash
  # discover AD domain
  [root@freeradius-test ~]# realm discover roomit.tech
  roomit.tech
    type: kerberos
    realm-name: ROOMIT.TECH
    domain-name: roomit.tech
    configured: kerberos-member
    server-software: active-directory
    client-software: sssd
    required-package: oddjob
    required-package: oddjob-mkhomedir
    required-package: sssd
    required-package: adcli
    required-package: samba-common-tools
    login-formats: %U@roomit.tech
    login-policy: allow-realm-logins
  [root@freeradius-test ~]# realm join roomit.tech -U appadmin
  Password for appadmin:
  
  # check users. Make sure users from samba is displayed.
  [root@freeradius-test ~]# wbinfo -u
  ... ((list of user)) ...
  
  # test auth.
  [root@freeradius-test ~]# wbinfo -a dwiyan.wijatmiko
  [root@freeradius ~]# wbinfo -a dwiyan.wijatmiko
  Enter dwiyan.wijatmiko's password: 
  plaintext password authentication failed
  Could not authenticate user dwiyan.wijatmiko with plaintext password
  Enter dwiyan.wijatmiko's password: 
  challenge/response password authentication succeeded
```  
Enable ntlm auth in samba. This configuration needs to be set all participating Samba members, and also on (Samba4) AD-DC servers.<br/>
Add this line in */etc/samba/smb.conf* on *[global]* configuration section.
```bash 
 [global] 
    ntlm auth = mschapv2-and-ntlmv2-only
  ...
```

Configure /etc/nsswitch.conf, add winbind in line passwd, shadow and group.
```bash
    passwd:     files sss winbind
    shadow:     files sss winbind
    group:      files sss winbind
  ...
```

Restart services.
```bash
  [root@freeradius-test ~]# systemctl restart smb nmb winbind
```
## Freeradius Configuration ##
In this example we use two clients, Netgear GS748T switch and Ruckus AP R510.

Add those two NAS client in */etc/raddb/clients.conf*. Add these following lines in the end of the config file.

```bash
 client switch-E {
  	secret = testing123
  	ipaddr = 10.32.16.128
  	shortname = switch-e
  }  
  client ruckus-ap {
  	secret = Roomit2019
  	ipaddr = 10.32.16.244
  	shortname = ruckus
  }
```


## Configure MSCHAP module ##
Edit */etc/raddb/mods-enabled/mschap*. Find the *ntlm_auth =* parameter and edit it as follow.
```
 > ntlm_auth = "/bin/ntlm_auth --allow-mschapv2 --request-nt-key  --username=\%{mschap:User-Name} --domain=ROOMIT --challenge=\%{\%{mschap:Challenge}:-00} --nt-response=\%{\%{mschap:NT-Response}:-00}"
```

## Configure LDAP Module ##
Create config file for LDAP module to point to Samba4 LDAP in **etc/raddb/mods-enabled/ldap**. And edit as following example.
```bash
ldap {
    server          = "10.32.16.130"
    port            = "389"
    identity        = "CN=appadmin,CN=Users,DC=roomit,DC=tech"
    password        = Jancoek
    base_dn         = "DC=roomit,DC=tech"
    filter          = "(userPrincipalName=\%{User-Name})"
    scope           = sub
    base_filter     = "(objectclass=user)"
    rebind          = yes
    chase_referrals = yes
    update {
        control:User-Name := 'sAMAccountName'
        request:User-Name := "sAMAccountName"
    }
    user {
        base_dn = "${..base_dn}"
        filter = "(|(UserPrincipalName=%{User-Name})(UserPrincipalName=\%{Stripped-User-Name})(sAMAccountName=\%{\%{Stripped-User-Name}:-\%{User-Name}}))"
    }
    group {
        base_dn = 'CN=Users,DC=roomit,DC=tech'
        membership_filter = "(|(member=\%{control:Ldap-UserDn})(memberUid=\%{\%{Stripped-User-Name}:-\%{User-Name}}))"
        membership_attribute = 'memberOf'
    }
options {
        chase_referrals = yes
        rebind = yes
    }
    pool {
        start = 0
    }
}
```
Edit the permission as follow to allow radius to access it.
```bash
  # ls -lrth /etc/raddb/mods-enabled/ldap 
  -rwxrwx--- 1 root radiusd 1,1K Nov 22 10:32 /etc/raddb/mods-enabled/ldap
```


## Configure Users Configuration for VLAN Assignment ##
In the Radius users config file, **/etc/raddb/users**, add these following line in the end of the file to enable VLAN assignment based on Department configured on the Samba.
```bash
#########################################################
# You should add test accounts to the TOP of this file! #
# See the example user "bob" above.                     #
#########################################################

DEFAULT Ldap-Group == "CN=Operation,CN=Users,DC=roomit,DC=tech"
        Tunnel-Type = VLAN,
        Tunnel-Medium-Type = IEEE-802,
        Tunnel-Private-Group-Id = "5"

DEFAULT Ldap-Group == "CN=System-Architect-Design-And-Analyst,CN=Users,DC=roomit,DC=tech"
        Tunnel-Type = VLAN,
        Tunnel-Medium-Type = IEEE-802,
        Tunnel-Private-Group-Id = "9"

DEFAULT Ldap-Group == "CN=DevOps,CN=Users,DC=roomit,DC=tech"
        Tunnel-Type = VLAN,
        Tunnel-Medium-Type = IEEE-802,
        Tunnel-Private-Group-Id = "9"

DEFAULT Ldap-Group == "CN=Development,CN=Users,DC=roomit,DC=tech"
        Tunnel-Type = VLAN,
        Tunnel-Medium-Type = IEEE-802,
        Tunnel-Private-Group-Id = "6"

DEFAULT Ldap-Group == "CN=Finance-And-Accounting,CN=Users,DC=roomit,DC=tech"
        Tunnel-Type = VLAN,
        Tunnel-Medium-Type = IEEE-802,
        Tunnel-Private-Group-Id = "7"

DEFAULT Ldap-Group == "CN=GA,CN=Users,DC=roomit,DC=tech"
        Tunnel-Type = VLAN,
        Tunnel-Medium-Type = IEEE-802,
        Tunnel-Private-Group-Id = "10"

DEFAULT Ldap-Group == "CN=HRD,CN=Users,DC=roomit,DC=tech"
        Tunnel-Type = VLAN,
        Tunnel-Medium-Type = IEEE-802,
        Tunnel-Private-Group-Id = "8"

DEFAULT Ldap-Group == "CN=Project-Management,CN=Users,DC=roomit,DC=tech"
        Tunnel-Type = VLAN,
        Tunnel-Medium-Type = IEEE-802,
        Tunnel-Private-Group-Id = "6"

DEFAULT Ldap-Group == "CN=QA-QC,CN=Users,DC=roomit,DC=tech"
        Tunnel-Type = VLAN,
        Tunnel-Medium-Type = IEEE-802,
        Tunnel-Private-Group-Id = "6"

DEFAULT Ldap-Group == "CN=Sales-And-Marketing,CN=Users,DC=roomit,DC=tech"
        Tunnel-Type = VLAN,
        Tunnel-Medium-Type = IEEE-802,
        Tunnel-Private-Group-Id = "11"

DEFAULT Ldap-Group == "CN=Telco,CN=Users,DC=roomit,DC=tech"
        Tunnel-Type = VLAN,
        Tunnel-Medium-Type = IEEE-802,
        Tunnel-Private-Group-Id = "9"

DEFAULT Ldap-Group == "CN=Top-Management,CN=Users,DC=roomit,DC=tech"
        Tunnel-Type = VLAN,
        Tunnel-Medium-Type = IEEE-802,
        Tunnel-Private-Group-Id = "14"

DEFAULT Auth-Type := Reject
```


## Configure Authorize, Authenticate and Post-Auth ##
Enable mschap, ldap and ntlm_auth in the **authenticate** section. And also configure update reply in the **post-auth** section for VLAN assignment.<br>
Edit the **/etc/raddb/sites-enabled/default** as following example.
```bash
 ## /etc/raddb/sites-enabled/default
  server default {
  
  	listen {
  		type = auth
  		ipaddr = *
  		port = 0
  		limit {
  		      max_connections = 16
  		      lifetime = 0
  		      idle_timeout = 30
  		}
  	}
  
  	listen {
  		ipaddr = *
  		port = 0
  		type = acct
  		limit {
  		}
  	}
  
  	listen {
  		type = auth
  		ipv6addr = ::	# any.  ::1 == localhost
  		port = 0
  		limit {
  		      max_connections = 16
  		      lifetime = 0
  		      idle_timeout = 30
  		}
  	}
  
  	listen {
  		ipv6addr = ::
  		port = 0
  		type = acct
  		limit {
  		}
  	}
  
  	authorize {
  		filter_username
  		preprocess
  		chap
  		mschap          
  		digest
  		suffix
  		eap {
  			ok = return
  		}
  		files
  		-sql
  	#	-ldap
  		expiration
  		logintime
  		ntlm_auth
  	}
  
  	authenticate {
  		Auth-Type ntlm_auth {
  	        	ntlm_auth
  		}
  		Auth-Type PAP {
  			pap
  		}
  		Auth-Type CHAP {
  			chap
  		}
  		Auth-Type MS-CHAP {
  			mschap
  		}
  		Auth-Type LDAP {
  			ldap
  		}
  		mschap
  		digest
  		eap
  	}
  
  	preacct {
  		preprocess
  		acct_unique
  		suffix
  		files
  	}
  
  	accounting {
  		detail
  		unix
  		-sql
  		exec
  		attr_filter.accounting_response
  	}
  
  	session {
  	}
  
  	post-auth {
                ### This is for VLAN assignment ###
  		if (LDAP-Group == "CN=Operation,CN=Users,DC=roomit,DC=tech") {
  	           update reply {
  	             Tunnel-Type := VLAN
  	             Tunnel-Medium-Type := IEEE-802
  	             Tunnel-Private-Group-ID := 5
  	          }
  	        }
  		elsif (LDAP-Group == "CN=System-Architect-Design-And-Analyst,CN=Users,DC=roomit,DC=tech") {
  	            update reply {
  	                Tunnel-Type := VLAN
  	                Tunnel-Medium-Type := IEEE-802
  	                Tunnel-Private-Group-Id := 9
  	            }
  	        }
  		elsif (LDAP-Group == "CN=DevOps,CN=Users,DC=roomit,DC=tech") {
  		    update reply { 
  			Tunnel-Type := VLAN
  		    	Tunnel-Medium-Type := IEEE-802
  		    	Tunnel-Private-Group-Id := 6
  		    }
  		}
  		elsif (LDAP-Group == "CN=Development,CN=Users,DC=roomit,DC=tech") {
  		    update reply { 
  			Tunnel-Type := VLAN
  		        Tunnel-Medium-Type := IEEE-802
  		        Tunnel-Private-Group-Id := 6
  		    }
  		}
  		elsif (LDAP-Group == "CN=Finance-And-Accounting,CN=Users,DC=roomit,DC=tech") {
  		    update reply { 
  			Tunnel-Type := VLAN
  		        Tunnel-Medium-Type := IEEE-802
  		        Tunnel-Private-Group-Id := 7
  		    }
  		}
  		elsif (LDAP-Group == "CN=GA,CN=Users,DC=roomit,DC=tech") {
  		    update reply { 
  			Tunnel-Type := VLAN
  		        Tunnel-Medium-Type := IEEE-802
  		        Tunnel-Private-Group-Id := 10
  		    }
  		}
  		elsif (LDAP-Group == "CN=HRD,CN=Users,DC=roomit,DC=tech") {
  		    update reply { 
  			Tunnel-Type := VLAN
  		        Tunnel-Medium-Type := IEEE-802
  		        Tunnel-Private-Group-Id := 8
  		    }
  		}
  		elsif (LDAP-Group == "CN=Project-Management,CN=Users,DC=roomit,DC=tech") {
  		    update reply { 
  			Tunnel-Type := VLAN
  		        Tunnel-Medium-Type := IEEE-802
  		        Tunnel-Private-Group-Id := 14
  		    }
  		}
  		elsif (LDAP-Group == "CN=QA-QC,CN=Users,DC=roomit,DC=tech") {
  		    update reply { 
  			Tunnel-Type := VLAN
  		        Tunnel-Medium-Type := IEEE-802
  		        Tunnel-Private-Group-Id := 16
  		    }
  		}
  		elsif (LDAP-Group == "CN=Sales-And-Marketing,CN=Users,DC=roomit,DC=tech") {
  		    update reply { 
  			Tunnel-Type := VLAN
  		        Tunnel-Medium-Type := IEEE-802
  		        Tunnel-Private-Group-Id := 11
  		    }
  		}
  		elsif (LDAP-Group == "CN=Telco,CN=Users,DC=roomit,DC=tech") {
  		    update reply { 
  			Tunnel-Type := VLAN
  		        Tunnel-Medium-Type := IEEE-802
  		        Tunnel-Private-Group-Id := 9
  		    }
  		}
  		elsif (LDAP-Group == "CN=Top-Management,CN=Users,DC=roomit,DC=tech") {
  		    update reply { 
  			Tunnel-Type := VLAN
  		        Tunnel-Medium-Type := IEEE-802
  		        Tunnel-Private-Group-Id := 14
  		    }
  		}
  		else {
  			reject
  		}
  
  		Post-Auth-Type REJECT {
  			attr_filter.access_reject
  		}
  		Post-Auth-Type Challenge {
  		}
  	}
  
  	pre-proxy {
  	}
  
  	post-proxy {
  		eap
  	}
  }
```

Edit file **/etc/raddb/sites-enabled/inner-tunnel** as follow.
```bash
  ## /etc/raddb/sites-enabled/inner-tunnel 
  server inner-tunnel {
  
      listen {
             ipaddr = 127.0.0.1
             port = 18120
             type = auth
      }
  
      authorize {
      	filter_username
      	chap
      	mschap
      	suffix
      	update control {
      		&Proxy-To-Realm := LOCAL
      	}
      	eap {
      		ok = return
      	}
      	files
      	-sql
      #	-ldap
      	expiration
      	logintime
      	ntlm_auth
      }
  
      authenticate {
      	Auth-Type ntlm_auth {
                      ntlm_auth
              }
      	Auth-Type PAP {
      		pap
      	}
      	Auth-Type CHAP {
      		chap
      	}
      	Auth-Type MS-CHAP {
      		ntlm_auth
      	}
      	Auth-Type LDAP {
      		ldap
      	}
      	mschap
      	eap
      }
  
      session {
      	radutmp
      }
  
      post-auth {
      	if (LDAP-Group == "CN=Operation,CN=Users,DC=roomit,DC=tech") {
                 update reply {
                   Tunnel-Type := VLAN
                   Tunnel-Medium-Type := IEEE-802
                   Tunnel-Private-Group-ID := 5
                }  
              }
      	elsif (LDAP-Group == "CN=System-Architect-Design-And-Analyst,CN=Users,DC=roomit,DC=tech") {
                  update reply {
                      Tunnel-Type := VLAN
                      Tunnel-Medium-Type := IEEE-802
                      Tunnel-Private-Group-Id := 9
                  }
              }
      	elsif (LDAP-Group == "CN=DevOps,CN=Users,DC=roomit,DC=tech") {
                  update reply {
                      Tunnel-Type := VLAN
                      Tunnel-Medium-Type := IEEE-802
                      Tunnel-Private-Group-Id := 6
                  }
              }
              elsif (LDAP-Group == "CN=Development,CN=Users,DC=roomit,DC=tech") {
                  update reply {
                      Tunnel-Type := VLAN
                      Tunnel-Medium-Type := IEEE-802
                      Tunnel-Private-Group-Id := 6
                  }
              }
              elsif (LDAP-Group == "CN=Finance-And-Accounting,CN=Users,DC=roomit,DC=tech") {
                  update reply {
                      Tunnel-Type := VLAN
                      Tunnel-Medium-Type := IEEE-802
                      Tunnel-Private-Group-Id := 7
                  }
              }
              elsif (LDAP-Group == "CN=GA,CN=Users,DC=roomit,DC=tech") {
                  update reply {
                      Tunnel-Type := VLAN
                      Tunnel-Medium-Type := IEEE-802
                      Tunnel-Private-Group-Id := 10
                  }
              }
              elsif (LDAP-Group == "CN=HRD,CN=Users,DC=roomit,DC=tech") {
                  update reply {
                      Tunnel-Type := VLAN
                      Tunnel-Medium-Type := IEEE-802
                      Tunnel-Private-Group-Id := 8
                  }
              }
              elsif (LDAP-Group == "CN=Project-Management,CN=Users,DC=roomit,DC=tech") {
                  update reply {
                      Tunnel-Type := VLAN
                      Tunnel-Medium-Type := IEEE-802
                      Tunnel-Private-Group-Id := 14
                  }
              }
              elsif (LDAP-Group == "CN=QA-QC,CN=Users,DC=roomit,DC=tech") {
                  update reply {
                      Tunnel-Type := VLAN
                      Tunnel-Medium-Type := IEEE-802
                      Tunnel-Private-Group-Id := 16
                  }
              }
              elsif (LDAP-Group == "CN=Sales-And-Marketing,CN=Users,DC=roomit,DC=tech") {
                  update reply {
                      Tunnel-Type := VLAN
                      Tunnel-Medium-Type := IEEE-802
                      Tunnel-Private-Group-Id := 11
                  }
              }
              elsif (LDAP-Group == "CN=Telco,CN=Users,DC=roomit,DC=tech") {
                  update reply {
                      Tunnel-Type := VLAN
                      Tunnel-Medium-Type := IEEE-802
                      Tunnel-Private-Group-Id := 9
                  }
              }
              elsif (LDAP-Group == "CN=Top-Management,CN=Users,DC=roomit,DC=tech") {
                  update reply {
                      Tunnel-Type := VLAN
                      Tunnel-Medium-Type := IEEE-802
                      Tunnel-Private-Group-Id := 14
                  }
              }
      	else {
      		reject
      	}
      	Post-Auth-Type REJECT {
      		attr_filter.access_reject
      	}
      }
  
      pre-proxy {
      }
  
      post-proxy {
      	eap
      }
  
  } # inner-tunnel server block
```
## Start Radius ##
Start radius service with command:
```bash
  # systemctl start radiusd
```

## Client Connection SOP ##
### Wired connection ###
* On the network connection settings, create new connection.
* Click on 802.1X Security Tab. And tick option "Use 802.1X security for this connection".
* Configure as following example. Use your LDAP username/password for authentication.

![802.1x](/assets/images/data_blog/8021X-Linux.png)

* Click "Save".

### Wireless connection ###
* On Network Manager settings, create new connection. Select 'Wi-Fi' for connection type.

![1](/assets/images/data_blog/8021X-wifi-1.png)

* Configure the Wi-Fi connection as follow.  

![2](/assets/images/data_blog/8021X-wifi-2.png)

![3](/assets/images/data_blog/8021X-wifi-3.png)

<br>e.g:<br>
SSID: Rommit#Test <br>
Security: Dynamic WEP (802.1X) <br>
Authentication: Protected EAP (PEAP)<br>
PEAP version: Automatic<br>
Inner Authentication: MSCHAPv2<br>
Username: LDAP Username<br>
Password: LDAP Password<br>
* Click Save

## NAC SOP ##

## References ##
* [http://deployingradius.com/documents/configuration/active_directory.html Deploy Radius]
* [https://networkradius.com/freeradius-packages/ Freeradius Packages]
* [https://www.server-world.info/en/note?os=CentOS_7&p=realmd Centos7 Join AD]
