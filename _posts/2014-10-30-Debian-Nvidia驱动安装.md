---
layout: post
title: "Debian Nvidia驱动安装"
date: 2014-10-30 18:38:32 +0800
category: linux
tags: 
- linux
- debian
- driver
- nvidia
comments: false
---

  用Debian算算也有四年时间了，期间装系统的次数也不少，自从用Gnome3以后闭源的驱动才能开启Gnome3的特效。不然会出现无法进入图形界面的情况，下面是安装驱动需要安装的软件。还是用日志记一下好了：

```
#apt-get install nvidia-glx nvidia-xconfig nvidia-settings xserver-xorg nvidia-kernel
```

  安装好后运行一下xconfig生成配置文件：

```
#nvidia-xconfig
```
