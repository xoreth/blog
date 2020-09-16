---
layout: post
title: Install SSP Service on SAMBA 4 AD DC
author: Galuh D Wijatmiko
categories: [Authentication]
tags: [samba4,SSP,SelfServicePassword,WebClient,centos7,installation]
---

# Install Packages
add file in /etc/yum.repos.d/ltb-project.repo
From LTB repository Configure the yum repository : 
```bash
[ltb-project-noarch]
name=LTB project packages (noarch)
baseurl=https://ltb-project.org/rpm/$releasever/noarch
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-LTB-project
```

Then update:
```bash
# yum update
```
Import repository key:
```bash
# rpm --import https://ltb-project.org/wiki/lib/RPM-GPG-KEY-LTB-project
```
You are now ready to install:
```bash
# yum install self-service-password
```
# Configure Config
Config file in /usr/share/self-service-password/conf/config.inc.php 
```bash
<?php
#==============================================================================
# LTB Self Service Password
#
# Copyright (C) 2009 Clement OUDOT
# Copyright (C) 2009 LTB-project.org
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# GPL License: http://www.gnu.org/licenses/gpl.txt
#
#==============================================================================

#==============================================================================
# All the default values are kept here, you should not modify it but use
# config.inc.local.php file instead to override the settings from here.
#==============================================================================

#==============================================================================
# Configuration
#==============================================================================

# Debug mode
# true: log and display any errors or warnings (use this in configuration/testing)
# false: log only errors and do not display them (use this in production)
$debug = false;

# LDAP
$ldap_url = "ldap://addc1.roomit.tech:389";
$ldap_starttls = false;
$ldap_binddn = "cn=appadmin,cn=Users,dc=roomit,dc=tech";
$ldap_bindpw = "yourpasswd";
$ldap_base = "dc=roomit,dc=tech";
$ldap_login_attribute = "sAMAccountName";
$ldap_fullname_attribute = "cn";
$ldap_filter = "(&(objectClass=user)(sAMAccountName={login}))";

# Active Directory mode
# true: use unicodePwd as password field
# false: LDAPv3 standard behavior
$ad_mode = true;
# Force account unlock when password is changed
$ad_options['force_unlock'] = false;
# Force user change password at next login
$ad_options['force_pwd_change'] = false;
# Allow user with expired password to change password
$ad_options['change_expired_password'] = false;

# Samba mode
# true: update sambaNTpassword and sambaPwdLastSet attributes too
# false: just update the password
$samba_mode = true;
# Set password min/max age in Samba attributes
#$samba_options['min_age'] = 5;
#$samba_options['max_age'] = 45;

# Shadow options - require shadowAccount objectClass
# Update shadowLastChange
$shadow_options['update_shadowLastChange'] = false;
$shadow_options['update_shadowExpire'] = false;

# Default to -1, never expire
$shadow_options['shadow_expire_days'] = -1;

# Hash mechanism for password:
# SSHA, SSHA256, SSHA384, SSHA512
# SHA, SHA256, SHA384, SHA512
# SMD5
# MD5
# CRYPT
# clear (the default)
# auto (will check the hash of current password)
# This option is not used with ad_mode = true
$hash = "SSHA";

# Prefix to use for salt with CRYPT
$hash_options['crypt_salt_prefix'] = "$6$";
$hash_options['crypt_salt_length'] = "6";

# Local password policy
# This is applied before directory password policy
# Minimal length
$pwd_min_length = 8;
# Maximal length
$pwd_max_length = 0;
# Minimal lower characters
$pwd_min_lower = 0;
# Minimal upper characters
$pwd_min_upper = 0;
# Minimal digit characters
$pwd_min_digit = 0;
# Minimal special characters
$pwd_min_special = 0;
# Definition of special characters
$pwd_special_chars = "^a-zA-Z0-9";
# Forbidden characters
#$pwd_forbidden_chars = "@%";
# Don't reuse the same password as currently
$pwd_no_reuse = true;
# Check that password is different than login
$pwd_diff_login = true;
# Complexity: number of different class of character required
$pwd_complexity = 0;
# use pwnedpasswords api v2 to securely check if the password has been on a leak
$use_pwnedpasswords = false;
# Show policy constraints message:
# always
# never
# onerror
$pwd_show_policy = "never";
# Position of password policy constraints message:
# above - the form
# below - the form
$pwd_show_policy_pos = "above";

# Who changes the password?
# Also applicable for question/answer save
# user: the user itself
# manager: the above binddn
$who_change_password = "manager";

## Standard change
# Use standard change form?
$use_change = true;

## SSH Key Change
# Allow changing of sshPublicKey?
$change_sshkey = false;

# What attribute should be changed by the changesshkey action?
$change_sshkey_attribute = "sshPublicKey";

# Who changes the sshPublicKey attribute?
# Also applicable for question/answer save
# user: the user itself
# manager: the above binddn
$who_change_sshkey = "user";

# Notify users anytime their sshPublicKey is changed
## Requires mail configuration below
$notify_on_sshkey_change = false;

## Questions/answers
# Use questions/answers?
# true (default)
# false
$use_questions = true;

# Answer attribute should be hidden to users!
$answer_objectClass = "extensibleObject";
$answer_attribute = "info";

# Crypt answers inside the directory
$crypt_answers = true;

# Extra questions (built-in questions are in lang/$lang.inc.php)
#$messages['questions']['ice'] = "What is your favorite ice cream flavor?";

## Token
# Use tokens?
# true (default)
# false
$use_tokens = false;
# Crypt tokens?
# true (default)
# false
$crypt_tokens = true;
# Token lifetime in seconds
$token_lifetime = "3600";

## Mail
# LDAP mail attribute
$mail_attribute = "userPrincipalName";
# Get mail address directly from LDAP (only first mail entry)
# and hide mail input field
# default = false
$mail_address_use_ldap = true;
# Who the email should come from
$mail_from = "admin@ssp.roomit.tech";
$mail_from_name = "Self Service Password";
$mail_signature = "";
# Notify users anytime their password is changed
$notify_on_change = true;
# PHPMailer configuration (see https://github.com/PHPMailer/PHPMailer)
$mail_sendmailpath = '/usr/sbin/sendmail';
$mail_protocol = 'smtp';
$mail_smtp_debug = 1;
$mail_debug_format = 'error_log';
$mail_smtp_host = 'sysmon.roomit.tech';
$mail_smtp_auth = false;
$mail_smtp_user = '';
$mail_smtp_pass = '';
$mail_smtp_port = 26;
$mail_smtp_timeout = 30;
$mail_smtp_keepalive = false;
$mail_smtp_secure = 'tls';
$mail_smtp_autotls = true;
$mail_contenttype = 'text/plain';
$mail_wordwrap = 0;
$mail_charset = 'utf-8';
$mail_priority = 3;
$mail_newline = PHP_EOL;

## SMS
# Use sms
$use_sms = false;
# SMS method (mail, api)
$sms_method = "mail";
$sms_api_lib = "lib/smsapi.inc.php";
# GSM number attribute
$sms_attribute = "mobile";
# Partially hide number
$sms_partially_hide_number = true;
# Send SMS mail to address
$smsmailto = "{sms_attribute}@service.provider.com";
# Subject when sending email to SMTP to SMS provider
$smsmail_subject = "Provider code";
# Message
$sms_message = "{smsresetmessage} {smstoken}";
# Remove non digit characters from GSM number
$sms_sanitize_number = false;
# Truncate GSM number
$sms_truncate_number = false;
$sms_truncate_number_length = 10;
# SMS token length
$sms_token_length = 6;
# Max attempts allowed for SMS token
$max_attempts = 3;

# Encryption, decryption keyphrase, required if $crypt_tokens = true
# Please change it to anything long, random and complicated, you do not have to remember it
# Changing it will also invalidate all previous tokens and SMS codes
$keyphrase = "PasswordTokens";

# Reset URL (if behind a reverse proxy)
#$reset_url = $_SERVER['HTTP_X_FORWARDED_PROTO'] . "://" . $_SERVER['HTTP_X_FORWARDED_HOST'] . $_SERVER['SCRIPT_NAME'];

# Display help messages
$show_help = false;

# Default language
$lang = "en";

# List of authorized languages. If empty, all language are allowed.
# If not empty and the user's browser language setting is not in that list, language from $lang will be used.
$allowed_lang = array();

# Display menu on top
$show_menu = false;

# Logo
$logo = "images/ltb-logo.png";

# Background image
$background_image = "images/unsplash-space.jpeg";

# Where to log password resets - Make sure apache has write permission
# By default, they are logged in Apache log
$reset_request_log = "/var/log/self-service-password";

# Invalid characters in login
# Set at least "*()&|" to prevent LDAP injection
# If empty, only alphanumeric characters are accepted
$login_forbidden_chars = "*()&|";

## CAPTCHA
# Use Google reCAPTCHA (http://www.google.com/recaptcha)
$use_recaptcha = false;
# Go on the site to get public and private key
$recaptcha_publickey = "";
$recaptcha_privatekey = "";
# Customization (see https://developers.google.com/recaptcha/docs/display)
$recaptcha_theme = "light";
$recaptcha_type = "image";
$recaptcha_size = "normal";
# reCAPTCHA request method, null for default, Fully Qualified Class Name to override
# Useful when allow_url_fopen=0 ex. $recaptcha_request_method = '\ReCaptcha\RequestMethod\CurlPost';
$recaptcha_request_method = null;

## Default action
# change
# sendtoken
# sendsms
$default_action = "change";

## Extra messages
# They can also be defined in lang/ files
#$messages['passwordchangedextramessage'] = NULL;
#$messages['changehelpextramessage'] = NULL;

# Launch a posthook script after successful password change
#$posthook = "/usr/share/self-service-password/posthook.sh";
#$display_posthook_error = true;

# Hide some messages to not disclose sensitive information
# These messages will be replaced by badcredentials error
#$obscure_failure_messages = array("mailnomatch");

# Allow to override current settings with local configuration
if (file_exists (__DIR__ . '/config.inc.local.php')) {
    require __DIR__ . '/config.inc.local.php';
}
```

# Modify SSP For Reset To Iredmail and LDAP/SAMBA3
Add in /usr/share/self-service-password/pages/change.php 
```bash
.......
function throw_api($login,$oldpassword,$newpassword,$confirmpassword){
    $madangkara_server = @fsockopen('madangkara.roomit.tech', '443');
    $ssp_server = @fsockopen('ssp.roomit.tech', '443');

    if (is_resource($madangkara_server)){
       echo '<center>Mail Server Port 443 is <font face="verdana" color="blue">Open</font></center>';
       ########## MADANGKARA #########
       $curly = curl_init();
       curl_setopt($curly, CURLOPT_URL,"https://madangkara.roomit.tech/ssp/");
       curl_setopt($curly, CURLOPT_POST, 1);
       curl_setopt($curly, CURLOPT_POSTFIELDS,"login=$login&oldpassword=$oldpassword&newpassword=$newpassword&confirmpassword=$confirmpassword");
       curl_setopt($curly, CURLOPT_RETURNTRANSFER, true);
       curl_setopt($curly, CURLOPT_VERBOSE, true);
       curl_setopt($curly, CURLOPT_STDERR, fopen('curl.log', 'w'));
       $server_output = curl_exec ($curly);
       curl_close ($curly);
       fclose($madangkara_server);
       echo '<center>Password Email Already <font face="verdana" color="blue">Success</font></center>';
    }
    else{
        echo 'Mail Server Port 443 Down : <font face="verdana" color="red"> Reset Email Failed</font>';
    }

    if (is_resource($ssp_server)){
       echo '<center>LDAP Server Port 443 is <font face="verdana" color="blue">Open</font></center>';
       ########### FATAGAR ###########
       $logindec=urlencode($login);
       $oldpassworddec=urlencode($oldpassword);
       $newpassworddec=urlencode($newpassword);
       $confirmpassworddec=urlencode($confirmpassword);
       exec("curl -X POST  -d 'login=''$logindec''&oldpassword=''$oldpassworddec''&newpassword=''$newpassworddec''&confirmpassword=''$confirmpassworddec''' 'https://ssp.roomit.tech'");
       fclose($ssp_server);
       echo '<center>Password LDAP Already <font face="verdana" color="blue">Success</font></center>';
    }
    else{
        echo 'LDAP Server Port 443 Down : <font face="verdana" color="red">Reset User Ldap Samba 3 Failed</font>';
    }

}
........

#==============================================================================
# Change password
#==============================================================================
if ( $result === "" ) {
    $result = change_password($ldap, $userdn, $newpassword, $ad_mode, $ad_options, $samba_mode, $samba_options, $shadow_options, $hash, $hash_options, $who_change_password, $oldpassword);

    throw_api($login,$oldpassword,$newpassword,$confirmpassword); #throw api for update to mail server and fatagar

    if ( $result === "passwordchanged" && isset($posthook) ) {
        $command = escapeshellcmd($posthook).' '.escapeshellarg($login).' '.escapeshellarg($newpassword).' '.escapeshellarg($oldpassword);
        exec($command, $posthook_output, $posthook_return);
    }
}
.......
```

# Config Apache HTTPD
edit /etc/httpd/conf.d/ssp.conf
```bash
<VirtualHost *:80>
	ServerName ssp.roomit.tech
        RedirectMatch ^/$ https://ssp.roomit.tech
        RewriteEngine on
        RewriteCond %{SERVER_NAME} =ssp.roomit.tech
        RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>


<VirtualHost *:443>
  ServerName ssp.roomit.tech
  LogLevel debug
  SSLEngine on
  SSLProtocol all -SSLv2 -SSLv3
  SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM:+LOW
  SSLCertificateFile /etc/cacerts/roomit.tech.crt
  SSLCertificateKeyFile /etc/cacerts/roomit.tech.key
  SSLCertificateChainFile /etc/cacerts/roomi.ttech-int.crt
  DocumentRoot /usr/share/self-service-password
  DirectoryIndex index.php
 
  AddDefaultCharset UTF-8
  #Alias /ssp /usr/share/self-service-password
  <Directory /usr/share/self-service-password>
      AllowOverride None
      <IfVersion >= 2.3>
          Require all granted
      </IfVersion>
      <IfVersion < 2.3>
          Order Deny,Allow
          Allow from all
      </IfVersion>
  </Directory>
 
  <Directory /usr/share/self-service-password/scripts>
      AllowOverride None
      <IfVersion >= 2.3>
          Require all denied
      </IfVersion>
      <IfVersion < 2.3>
          Order Deny,Allow
          Deny from all
      </IfVersion>
  </Directory>
</VirtualHost>
```

# Restart HTTPD
```bash
systemctl restart httpd
```
