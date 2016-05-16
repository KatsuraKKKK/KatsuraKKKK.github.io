---
layout: post
title: "concurrentHashMap中的2的n次幂上舍入方法"
data: 2014-12-02 13:38:32 +0800
category: algorithm
tags:
- algorithm
comments: true
---
最近看JDK中的concurrentHashMap类的源码，其中有那么一个函数

```java
/**
     * Returns a power of two table size for the given desired capacity.
     * See Hackers Delight, sec 3.2
     */
    private static final int tableSizeFor(int c) {
        int n = c - 1;
        n |= n >>> 1;
        n |= n >>> 2;
        n |= n >>> 4;
        n |= n >>> 8;
        n |= n >>> 16;
        return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
    }
```
看不明白这是做什么的，但是后来我查看了《hackers delight》（中译：高效程序的奥秘）这本书，才知道这个函数是用来计算c的上舍入到2的n次幂。书上的函数如下图：
![License Badge]({{ site.baseurl}}/images/201412/01/concurrentHashMap1.png)

这个算法的原理是什么我们举个例子就可以清楚的知道：

```

例如32位的unsigned int:

inited:        01000000 00000000 00000000 00000001;
n = c - 1 :    01000000 00000000 00000000 00000000;
n |= n >>> 1:  01100000 00000000 00000000 00000000;
n |= n >>> 2:  01111000 00000000 00000000 00000000;
n |= n >>> 4:  01111111 10000000 00000000 00000000;
n |= n >>> 8:  01111111 11111111 10000000 00000000;
n |= n >>> 16: 01111111 11111111 11111111 11111111;
n = n + 1:     10000000 00000000 00000000 00000000;

可以看到这个算法的主要思想就是把最为1的最高位后面全部转换成1然后加1进位。

```

[My Github](http://katsurakkkk.github.io/)