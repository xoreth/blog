---
layout: post
title: "[Ruby] [Basic] Variable and Print Out in Ruby"
author: Galuh D Wijatmiko
categories: [Programming]
tags: [Ruby,BasicRuby]
draft: false
published: true
---


#Variable in Ruby

Create file variable.rb
```bash
## String
mahasiswa = "Dwiyan Galuh"

## Integer
nilai_uts = 90

## Decimal
nilai_harian = 90.5

## Boolean
valid = true


puts mahasiswa,nilai_uts,nilai_harian,valid
puts ""
puts "ini adalah ",mahasiswa," ",nilai_uts,nilai_harian,valid
puts ""
print mahasiswa,nilai_uts,nilai_harian,valid
puts "nama saya adalah #{mahasiswa}"
```

running
```bash
ruby variable.rb
```

* _puts_ will be create new line in last _,_
* _print_ will be continous line
* _\#\{mahasiswa\} is interpolate variable, you can manupulate your variable in stdout strings