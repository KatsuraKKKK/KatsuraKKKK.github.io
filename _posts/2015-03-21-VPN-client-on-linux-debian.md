---
layout: post
title: "VPN client on linux debian"
data: 2015-02-14 11:15:30 +0800
category: linux
tags:
- vpn 
- debian
- linux
comments: false
---

Install the pptp-linux and pptp-linux-client:

```bash
sudo apt-get install pptp-linux pptp-linux-client
```
Create a connection config:

```bash
sudo pptpsetup --create [ConnectionName] --server [Ip] --username [Username] --password [Password] --encrypt
```

Connect the VPN:

```bash 
sudo pon [ConnectionName]
```

Add router:

```bash 
sudo route add default dev ppp0
```

Check the routor table:

```bash 
sudo route -n
```

Disconnect the VPN:

```bash 
sudo poff [ConnectionName]
```

<br>
[我的渣github](http://github.com/KatsuraKotarou)
