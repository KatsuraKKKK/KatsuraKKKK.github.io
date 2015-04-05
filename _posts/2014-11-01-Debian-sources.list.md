---
layout: post
title: "Debian sources.list"
data: 2014-11-01 22:38:32 +0800
category: linux
tags: 
- linux
- debian
- source list
comments: true
---

以下是在用的Debian7 testing的更新源，教育网内很好用，可以直接ipv6更新。由于我打开了32位软件包的支持，所以加上了64位和32位的选项。

```
deb [arch=amd64,i386] http://ftp.cn.debian.org/debian/ testing main contrib non-free
deb [arch=amd64,i386] http://ftp.cn.debian.org/debian-security/ testing/updates main contrib non-free
deb [arch=amd64,i386] http://ftp.cn.debian.org/debian-multimedia/ testing main non-free
deb [arch=amd64,i386] http://ftp.cn.debian.org/debian/ experimental main
deb-src [arch=amd64,i386] http://ftp.cn.debian.org/debian/ testing main contrib non-free 
```

