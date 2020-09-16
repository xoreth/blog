---
layout: post
title: Ansible Vault Summary
author: Galuh D Wijatmiko
categories: [Provisioning]
tags: [ansible,automation]
draft: false
published: true
---


## Vault
Ansible-vault can encrypt any structured data. Since YAML itself is a structured
language, almost everything that you write for Ansible meets this criteria. The
following are the pointers on what can be encrypted with the vault:

- Most commonly, we encrypt variables, which can be as follows:
  - Variable files in roles, for example, vars and defaults  
  - Inventory variables, for example, host_vars , group_vars  
  - Variables files included with include_vars or vars_files  
  - Variable files passed to the Ansible-playbook with the -e option, for example, -e @vars.yml or -e @vars.json
- Since tasks and handlers are also JSON data, these can be encrypted with the vault. However, this should be rarely practiced. It's recommended that you encrypt variables and reference them in tasks and handlers instead.

The following data are a good candidates for encryption:
* Credentials, for example, database passwords and application credentials
* API keys, for example, AWS access and secret keys
* SSL keys for web servers
* Private SSH keys for deployments

```bash
ansible-vault create vars/main.yml #create secure variable
ansible-vault edit vars/main.yml #edit secure variable
ansible-vault rekey vars/main.yml  #change password
ansible-vault decrypt vars/main.yml #decrypt file
ansible-vault encrypt vars/main.yml #encrypt file
```

How to Call
```bash
ansible-playbook -i customhosts site.yml --ask-vault-pass
```

Using Password File
```bash
echo "password" > ~/.vault_pass
chmod 600 ~/.vault_pass
```
How to Call
```bash
ansible-playbook -i customhosts site.yml --vault-password-file ~/.vault_pass
```
