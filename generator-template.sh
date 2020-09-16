#!/bin/bash
#
# Generator Page Jekyll
#
#
#
#


Date=`date  "+%Y-%m-%d"`

read -p "Enter Title: " Title
echo -e "Enter Category:
        1. Authentication (IDM)
        2. StorageAndFilesystem
        3. SecurityTunningAndHardening 
        4. Packaging 
        5. Virtualization 
        6. Networks
        7. Provisioning
        8. Container
        9. Ebooks
        10. Tools
        11. Databases
        12. MessageBroker
        13. Programming 
        14. Script 
        15. Server
        16. Troubleshot
        17. Service Discovery
        18. LoggingAndMonitoring" 
read -p "Choose Category: " Category
case "$Category" in
	1)
    Category="Authentication";
	;;
  2)
	  Category="StorageAndFilesystem";
	;;
  3)
	  Category="SecurityTunningAndHardening";
	;;
  4)
	  Category="Packaging";
	;;
  5)
	  Category="Virtualization";
	;;
  6)
	  Category="Networks";
	;;
  7)
	  Category="Provisioning";
	;;
  8)
	  Category="Container";
	;;
  9)
	  Category="Ebooks";
	;;
  10)
	  Category="Tools";
	;;
  11)
	  Category="Databases";
	;;
  12)
	  Category="MessageBroker";
	;;
  13)
	  Category="Programming";
	;;
  14)
	  Category="Script";
	;;
  15)
	  Category="Server";
	;;
  16)
	  Category="Troubleshot";
	;;
  17)
    Category="ServiceDiscovery";
  ;;
  18)
    Category="LoggingAndMonitoring" ;
  ;;
  *)
    echo "There is no Category"
    exit 1;
	;;
esac


read -p "Enter Tags:" Tags

Title_File=`echo $Title | tr " " "-" |tr -d '"'|tr -d "[]."`

if [ -z "$Title" ] 
then
  echo "Title is empty";
  exit 1;
fi

if [ -z "$Category" ]
then
  echo "Category is empty";
  exit 1;
fi

if [ -z "$Tags" ]
then
  echo "Tags is empty";
  exit 1;
fi


cat >  _posts/"${Date}"-"${Title_File}".markdown <<EOF
---
layout: post
title: $Title
author: Galuh D Wijatmiko
categories: [$Category]
tags: [$Tags]
draft: true
published: false
[Comment1] #[Install Samba]({{ site.url }}/notes/2020/03/03/install-samba-4-ad-dc/)
[Comment2] #![Setting DNS](/assets/images/data_blog/SettingDNSWindows.png)
[Comment3]]: #https://ecotrust-canada.github.io/markdown-toc/
---
EOF


echo ""
echo "Result"
echo ""
echo "_posts/"${Date}"-"${Title_File}".markdown"
echo ""

