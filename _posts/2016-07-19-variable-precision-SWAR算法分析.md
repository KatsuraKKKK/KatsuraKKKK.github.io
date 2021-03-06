---
layout: post
title: "variable-precision SWAR算法：计算Hamming Weight"
data: 2016-07-19 20:03:30 +0800
category: Algorithm
tags:
- Algorithm
- 算法
- HammingWeight
comments: true
---

# variable-precision SWAR算法：计算Hamming Weight

最近看书看到了一个计算Hamming Weight的算法，觉得挺巧妙的，纪录一下。

Hamming Weight，即汉明重量，指的是一个位数组中非0二进制位的数量。

对于这个问题，最直观的算法就是遍历二进制位，时间复杂度是O(n)，每次需要遍历n个位。另外一个算法是查表，用一个数组记录下一定位数每个数值的汉明重量如：数组hwTable=[0, 1, 1, 2]纪录了0， 1， 2， 3的汉明重量。这个算法的时间复杂度也是O(n)，但是不需要执行n次，而是只需要执行n／m次，m取决于查表一次能够决定的二进制位的长短，这个算法需要使用额外的空间为O(m^2)。

而我们接下来的所提到的SWAR算法既有着较高的效率，又不需要使用那么大的空间，算法实现如下：

```java
// 计算32位二进制的汉明重量
int32_t swar(int32_t i)
{	
	i = (i & 0x55555555) + ((i >> 1) & 0x55555555);
	i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
	i = (i & 0x0F0F0F0F) + ((i >> 4) & 0x0F0F0F0F);
	i = (i * (0x01010101) >> 24);
	return i
}
```
计算32位的位数组只需要O(1)，而且比查表法需要的空间更少。

乍一看好像看不出什么头绪，只要动手一步步之行一下这个算法就可以看到它的巧妙之处。下面我们一步步执行一下这个算法：

```
5: 0101	3: 0011	F:	1111
input:	0011 1010 0111 0000 1111 0010 0001 1011
step1:	0001 0000 0101 0000 0101 0000 0001 0001(i&0x55555555)
	   	0001 0101 0001 0000 0101 0001 0000 0101((i>>1)&0x55555555)
	   	0010 0101 0110 0000 1010 0001 0001 0110(+)

step2:	0010 0001 0010 0000 0010 0001 0001 0010(i&0x33333333)
		0000 0001 0001 0000 0010 0000 0000 0001((i>>2)&33333333)
		0010 0010 0011 0000 0100 0001 0001 0011(+)

step3:	0000 0010 0000 0000 0000 0001 0000 0011(i&0x0F0F0F0F)
		0000 0010 0000 0011 0000 0100 0000 0001((i>>4)&0x0F0F0F0F)
		0000 0100 0000 0011 0000 0101 0000 0100(+)

step4: ...
```

可以清楚的看到，第一步的结果中，每两位为一组，纪录了这两位里面非0位的个数；第二步的执行结果中，每四位为一组，纪录了每四位里面非0位的个数；第三步的结果中，每八位为一组，纪录了每八位里面非0位的个数；第四步只要想想笔算乘法就清楚了^_^。当然如果一次要计算六四位也是可以的。。

这个是目前已知效率最好的计算汉明重量的通用算法，在redis的bit array中也有使用，不过redis中将SWAR算法和查表法结合起来了。
