---
layout: post
title: "[Ruby] Generate Controller RoR"
author: Galuh D Wijatmiko
categories: [Programming]
tags: [ruby,ror]
draft: false
published: true
---


Next chapter from [Generate Project RoR]({{ site.url }}/notes/2020/03/20/Generate-Project-Ruby-On-Rails/)
We will generate controller, before that RoR have pattern MVC (Model,View,Controller).
What is MVC? [MVC Answer](https://id.wikipedia.org/wiki/MVC) 


Generate Controller:
```bash
cd first_project
rails generate controller demo index
```

Output:
```bash
Running via Spring preloader in process 200189
      create  app/controllers/demo_controller.rb
       route  get 'demo/index'
      invoke  erb
      create    app/views/demo
      create    app/views/demo/index.html.erb
      invoke  test_unit
      create    test/controllers/demo_controller_test.rb
      invoke  helper
      create    app/helpers/demo_helper.rb
      invoke    test_unit
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/demo.coffee
      invoke    scss
      create      app/assets/stylesheets/demo.scss
```

Information :
1. _generate_ is command generator
2. _controller_ is param for controller
3. _demo_ is Name Controller
4. _index_ is Method

Running Service built in:
```bash
rails server
```

Running in your browser:
> http://localhost:3000/demo/index

Path Important :
```bash
app :
  - controllers
  - models
  - views
config :
  - routes.rb
```


for routing url you can add in ./config/routes.rb
