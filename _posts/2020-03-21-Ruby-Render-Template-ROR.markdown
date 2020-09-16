---
layout: post
title: "[Ruby] Render Template ROR"
author: Galuh D Wijatmiko
categories: [Programming]
tags: [ruby,ror]
draft: false
published: true
---


Next chapter from [Generate Controller RoR]({{ site.url }}/notes/2020/03/20/generate-project-ruby-on-rails/)

How to Render Template :
1. Create route ./config/routes.rb
```bash
Rails.application.routes.draw do
  get 'demo/index'
  get 'demo/coba'
  get 'demo/iseng'
end
```

2. Add method in demo controller ./app/controllers/demo_controller.rb
```bash
class DemoController < ApplicationController
  def index
  end

  def coba
  end

  def iseng
    render plain: 'test test'
  end
end
```

3. Create File in ./app/views/demo/main.html.erb
```bash
Testting
```
Running Server 
```bash
rails server
```

Access your web browser
> http://localhost:3000/demo/iseng


How Create Template Diffrent Folder
Assume we had created file in ./app/views/home/index.html.erb
```bash
<h1>Test</h1>
```

For direction to template in methode iseneg in demo_controller.rb just

```bash
class DemoController < ApplicationController
  def index
  end

  def coba
  end

  def iseng
    render 'home/index'
  end
end
```