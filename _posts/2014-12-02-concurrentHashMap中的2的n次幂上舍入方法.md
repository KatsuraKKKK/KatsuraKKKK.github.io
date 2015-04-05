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



