---
layout: post
title: Backup And Restore SAMBA 4 AD DC
author: Galuh D Wijatmiko
categories: [Authentication]
tags: [Backup,samba4]
---


# BACKUP 
## BACKUP SAMBA MANUAL

> Make Sure Your LDAP Still Running

The Samba backup script isn't installed by 'make install'. You need to you copy it from the sources directory (source4/scripting/bin/samba_backup) to somewhere like /usr/sbin, and set secure permissions:
```bash
cp .../source4/scripting/bin/samba_backup /usr/sbin
chown root:root /usr/sbin/samba_backup
chmod 750 /usr/sbin/samba_backup
```

Adjust the following variables inside the script to your needs:
```bash
FROMWHERE=/etc/samba
WHERE=/opt/backup
DAYS=90
```
Create the destination folder, you have configured in the $WHERE variable and set permissions:
```bash
mkdir /usr/local/backups
chmod 750 /usr/local/backups
```

Start the backup script for a first test:
```bash
/usr/sbin/samba_backup
```

If the script exits without an error, you should find three files in the destination folder:
```bash
etc.{Timestamp}.tar.bz2
samba4_private.{Timestamp}.tar.bz2
sysvol.{Timestamp}.tar.bz2
```

If your test backup succeeded, you should add a cron-job for daily backup:
```bash
crontab -e
```
Add the following line to backup daily at 2am:
> 0 2 * * * /usr/sbin/samba_backup

## BACKUP ONLINE 

Backup Onlie able renaming Domain and Workgroup, example with backup online renaming :

```bash
samba-tool domain backup rename WORKGROUP ROOMIT.AUTH --server=addc1.roomit.tech --targetdir=/opt/ -UAdministrator
```

Backup Online without rename Domain and Workgroup, example :

```bash
samba-tool domain backup online --targetdir=/opt/backup/ --server=addc1.roomit.tech -U Administrator
```

Samba Script Backup Manual and Backup Online
```bash
#FROMWHERE=/usr/local/samba
#WHERE=/usr/local/backups
#DAYS=90                                # Set default retention period.
FROMWHERE=/etc/samba
WHERE=/opt/backup
BACKUP=/backup
DAYS=7                          # Set default retention period.
if [ -n "$1" ] && [ "$1" = "-h" -o "$1" = "--usage" ]; then
       echo "samba_backup [provisiondir] [destinationdir] [retpd]"
       echo "Will backup your provision located in provisiondir to archive stored"
       echo "in destinationdir for retpd days. Use - to leave an option unchanged."
       echo "Default provisiondir: $FROMWHERE"
       echo "Default destinationdir: $WHERE"
       echo "Default destinationdir: $DAYS"
       exit 0
fi
[ -n "$1" -a "$1" != "-" ]&&FROMWHERE=$1        # Use parm or default if "-".  Validate later.
[ -n "$2" -a "$2" != "-" ]&&WHERE=$2            # Use parm or default if "-".  Validate later.
[ -n "$3" -a "$3" -eq "$3" 2> /dev/null ]&&DAYS=$3      # Use parm or default if non-numeric (incl "-").
DIRS="private etc sysvol"
#Number of days to keep the backup
WHEN=`date +%Y-%m-%d`   # ISO 8601 standard date.
if [ ! -d $WHERE ]; then
       echo "Missing backup directory $WHERE"
       exit 1
fi
if [ ! -d $FROMWHERE ]; then
       echo "Missing or wrong provision directory $FROMWHERE"
       exit 1
fi
cd $FROMWHERE
for d in $DIRS;do
       relativedirname=`find . -type d -name "$d" -prune`
       n=`echo $d | sed 's/\//_/g'`
       if [ "$d" = "private" ]; then
               find $relativedirname -name "*.ldb.bak" -exec rm {} \;
               for ldb in `find $relativedirname -name "*.ldb"`; do
                       tdbbackup $ldb
                       Status=$?       # Preserve $? for message, since [ alters it.
                       if [ $Status -ne 0 ]; then
                               echo "Error while backing up $ldb - status $Status"
                               exit 1
                       fi
               done
               # Run the backup.
               #    --warning=no-file-ignored set to suppress "socket ignored" messages.
               tar cjf ${WHERE}/samba4_${n}.${WHEN}.tar.bz2  $relativedirname --exclude=\*.ldb --warning=no-file-ignored --transform 's/.ldb.bak$/.ldb/'
               Status=$?       # Preserve $? for message, since [ alters it.
               if [ $Status -ne 0 -a $Status -ne 1 ]; then     # Ignore 1 - private dir is always changing.
                       echo "Error while archiving ${WHERE}/samba4_${n}.${WHEN}.tar.bz2 - status = $Status"
                       exit 1
               fi
               find $relativedirname -name "*.ldb.bak" -exec rm {} \;
       else
               # Run the backup.
               #    --warning=no-file-ignored set to suppress "socket ignored" messages.
               tar cjf ${WHERE}/${n}.${WHEN}.tar.bz2  $relativedirname --warning=no-file-ignored
               Status=$?       # Preserve $? for message, since [ alters it.
               if [ $Status -ne 0 ]; then
                       echo "Error while archiving ${WHERE}/${n}.${WHEN}.tar.bz2 - status = $Status"
                       exit 1
               fi
       fi
done
### BACKUP ONLINE ###
/usr/bin/samba-tool domain backup online --targetdir=$WHERE --server=$HOSTNAME -P
/bin/mount -t cifs //HostDestination/backupad /backup -o username=[username],password=[password],domain=ROOMIT.TECH
/bin/mv $WHERE/*.bz2 $BACKUP
find $BACKUP -name "*.bz2" -mtime +$DAYS -exec rm  {} \;
/bin/umount /backup
```

# RESTORE
## Restore Manual
The following restore guide assumes that you backed-up your databases with the 'samba_backup' script. If you have your own script, adjust the steps.
Very important notes:
```bash
rm -rf /etc/samba/
rm -rf /etc/samba/private
rm -rf /etc/samba/state/sysvol
```
Now unpack your latest working backup files to their old location:
```bash
cd /opt/backup
tar -jxf etc.{Timestamp}.tar.bz2 -C /etc/samba
tar -jxf samba4_private.{Timestamp}.tar.bz2 -C /etc/samba/private
tar -jxf sysvol.{Timestamp}.tar.bz2 -C /etc/samba/state/sysvol
```

Rename *.ldb.bak files in the 'private' directory back to *.ldb. This can be done with GNU find and Bash:
```bash
find /etc/samba/private/ -type f -name '*.ldb.bak' -print0 | while read -d $'\0' f ; do mv "$f" "${f%.bak}" ; done
```
If your backup doesn't contain extended ACLs
```bash
samba-tool ntacl sysvolreset
```
Now you can start samba and test if your restore was successful. 

## Resotore From Backup Online
Search your backup file, and do it :
```bash
samba-tool domain backup restore --backup-file=<tar-file> --newservername=<DC-name> --targetdir=<new-samba-dir>
samba-tool domain backup restore --backup-file=/opt/backup/samba-backup-roomit.tech-2019-11-15T00-00-23.726376.tar.bz2 --newservername=addc1.roomit.tech --targetdir=/etc/samba
```
Restore config
```bash
cd /etc/samba/etc
mv smb.conf ../
```
Start Service samba
```bash
systemctl start samba
```

