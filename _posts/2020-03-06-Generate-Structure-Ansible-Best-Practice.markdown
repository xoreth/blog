---
layout: post
title: Generate Structure Ansible and Roles Best Practice
author: Galuh D Wijatmiko
categories: [Provisioning]
tags: [ansible]
draft: false
published: true 
---


From References structure best practide ansible [Ansible Structure](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

```bash
── inventories
│   ├── production
│   │   ├── group_vars
│   │   └── host_vars
│   └── staging
│       ├── group_vars
│       └── host_vars
├── playbook
│   ├── production
│   └── staging
└── roles
    |
    ├── global_epel_release
    │   ├── defaults
    │   ├── files
    │   ├── handlers
    │   ├── meta
    │   ├── tasks
    │   ├── templates
    │   ├── tests
    │   └── vars
    └── roomit_droplet
        ├── defaults
        ├── files
        ├── handlers
        ├── meta
        ├── results
        ├── tasks
        ├── templates
        ├── tests
        └── vars
```


Create Directory Structure
```bash
mkdir myAnsible
cd myAnsible
mkdir -p inventories/{production/{group_vars,host_vars},staging/{group_vars,host_vars}} roles
mkdir -p playbook/{production,staging}
cat > ansible.cfg <<EOF
[defaults]
command_warnings=False
#roles_path = /home/wajatmaka/Activity/LEARN/ANSIBLE/roles
host_key_checking = false
EOF
touch inventories/production/hosts
touch inventories/production/group_vars/all
touch inventories/staging/hosts
touch inventories/staging/group_vars/all
```

## How Generate Roles
```bash
cd myAnsible
ansible-galaxy init --init-path roles/ mysql
```