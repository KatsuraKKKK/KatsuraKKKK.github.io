---
layout: post
title: "《Tinking In Java第四版》拾遗"
data: 2016-05-07 16:40:30 +0800
category: Java
tags:
- Java
- Thinking
- note
comments: true
---

#《Tinking In Java第四版》拾遗

近日重读了《Thinking In Java第四版》（可能版本比较老），发现一些有趣的和值得注意的地方，在此作个记录。

## 返回值过载
不能用返回值对函数进行overload，因为有可能调用方并不关心返回值，这就造成了二义性。如：

```java
void f();
int f();
```

调用f()的时候就会造成二义性。

## this引用
可以用this引用在构造函数中调用过载的构造函数，但是只能调用一个，并且构造函数调用必须是我们做的第一件事，否则编译器会报错。另外，只能在构造函数中调用其它构造函数。

```java
public class ThisTest {
	public ThisTest() {
//		System.out.print("Constructor");
		this(1);
//		this(1, 2);
	}
	public ThisTest(int n) {}

	public ThisTest(int n, int m) {}
}
```

## 属性初始化
可以使用方法调用对属性进行初始化，但是不能调用未初始化的属性。注意，属性的初始化与代码顺序有关，而不是与程序的编译方式有关。

```java
class PropertyInitTest {
	int i = init();
	int j = init(i);

//  Compile Error Here.
//	int n = init(m);
//	int m = init();

	public int init() {
		return 1;
	}

	public int init(int n) {
		return n + 1;
	}
}
```

## 非静态属性的代码块初始化方式
匿名内部类的属性初始化必须使用这种方式。

```java
public class ThisTest {
	public static void main(String[] args) {
		InitCodeTest ict = new InitCodeTest();
		ict.printProperties();
	}
}

class InitCodeTest {
	int i;
	int j;

	public InitCodeTest() {
		System.out.println("Constructor.");
	}

	{
		i = increase(1);
		j = increase(2);
	}

	int increase(int n) {
		System.out.println("increase:" + n);
		return n + 1;
	}

	void printProperties() {
		System.out.println("i=" + i + "|j=" + j);
	}
}
```
代码运行的输出如下：
```
increase:1
increase:2
Constructor.
i=2|j=3
```

## Compilation unit
每个Compilation unit就是一个java文件，必须以一个.java结尾，而且在编辑单元内部可以有一个public类，必须与编辑单元的名字相同。并且每个编辑单元中只能有一个public类，但是可以有多个非public类。如下：

```java
// EditUnit.java
public class EditUnit {
}

class NotPublic {
}
```

## final方法
1. 不希望方法在继承过程中改变
2. inline，将一个方法设置成final以后，编译器就可以把对那个方法的所有调用都变成内联函数，直接加入需要调用的地方，免除了函数调用的入栈和退栈操作。但是过大的方法内联会使得程序变得臃肿，所以不要过于相信编译器的判断，最好只有在方法代码量非常少或者想明确禁止方法被覆盖的时候，才应考虑将一个方法设为final。
3. 类内所有private方法都自动成为final。可以为一个private方法添加final提示符，但却不能为那个方法提供任何额外的含义。

## 接口中定义的字段
接口中定义的字段会自动具有static和final属性。它们不能是‘空白final’，但可以初始化成非常数表达式。如下：

```java
public interface RandVals {
	int rint = (int)(Math.random() * 10);
	long rlong = (long)(Math.random() * 10);
	float rfloat = (float)(Math.random() * 10);
	double rdouble = (double)(Math.random() * 10);
}
```
由于字段是static的，所以会在首次装载类之后，以及首次访问任何字段之前获得初始化。所以接口里面的属性可以理解为一个static字段，它们也是保存于那个接口的static存储区域中。

## 内部类和upcast
内部类看起来没有什么特别的地方，然而当我们准备upcast到一个基类的时候，内部类就开始发挥其关键作用。这是由于内部类随后可以完全进入不可见或者不可用的状态--对任何人都如此。所以我们可以非常方便的隐藏实施细节。我们得到的全部回报就是一个基础类或者接口的句柄，而且甚至有可能不知道准确的类型。如下：

```java
abstract class Contents {
	abstract public int value();
}

interface Destination {
	String readLabel();
}

class Parcel {
	private class PContents extends Contents {
		private int i = 11;

		@Override
		public int value() {
			return i;
		}
	}

	protected class PDestination implements Destination {
		private String label;

		private PDestination(String whereTo) {
			label = whereTo;
		}

		@Override
		public String readLabel() {
			return label;
		}
	}

	public Destination dest(String s) {
		return new PDestination(s);
	}

	public Contents cont() {
		return new PContents();
	}
}

class Test {
	public static void main(String[] args) {
		Parcel p = new Parcel();
		Contents c = p.cont();
		Destination d = p.dest("ShenZhen");
		// Illegal -- can't access private class:
		//! Parcel.PContents c = p.new Pcontents();
	}
}
```
Contents和Destination代表可由程序员调用的接口，在Parcel中，内部类PContents设为private，所以除了Parcel之外，其他东西不能访问它。PDestination设为protected，所以除了Parcel，Parcel包内的类，以及Paarcel的继承者外，其他东西都不能访问PDestination。事实上，我们不能downcast到一个private内部类（或者一个protected内部类，除非自己本身是一个继承者），因为我们不能访问名字。所以，利用private内部类，类设计人员可以完全禁止其他人以来类型编码，并可以将具体的实施细节完全隐藏。除此之外，从客户程序员的角度看，一个接口的范围没有意义的，因为他们不能访问不属于公共接口类的任何额外方法。这样一来Java编译器也有机会生成效率更高的代码。
另外，普通（非内部）类不能设置为private或者protected--只允许public或者package。

## 匿名内部类
看下面这段代码

```java
public class InnerClass {
	public Contents count() {
    	return new Contents() {
        	private int i = 11;
            public int value() {
            	return i;
            }
        }
    }
}
```
cont()方法同时合并了返回值的创建代码，以及用于那个返回值的类。除此之外，这个类是匿名的。这种语法要表达的意思是：“创建从Contents衍生出来的一个匿名类对象”。由new表达式返回的实例引用会自动upcast成一个Contents引用。匿名内部类的语法其实要表达的是：

```java
class MyContents extends Contents {
	private int i = 11;
    public int value() {
    	return i;
    }
    return new MyContents();
}
```

如果需要用到基类的带有参数的构造函数，那么可以在new的时候使用带有参数的构造函数。如下：

```java
public Contents count(int x) {
	return new Contents(x) {
    	private int i = 11;
        public int value() {
        	return i;
        }
    }
}
```

注意，匿名类不能拥有一个构造函数，这和在构造函数中调用super()的常规做法不同。

在匿名内部类中，如果需要使用外部对象则需要该外部对象为final属性。如果需要采取一些类似于构造函数的行为，可以通过前面提到的初始化代码块实现。如下：

```java
public Contents count(final Integer x) {
	private int cost;
    {
    	cost = (int)(Math.random() * 10);
        System.out.println(cost);
    }
    int i = x;
    public value() {
    	return i;
    }
}
```

## 从内部类继承
由于内部类构建起必须同封装对象的一个引用联系到一起，所以从一个内部类集成的时候，情况会变得比较独特。问题在于封装类的隐含引用必须获得初始化，而在衍生类中不再有一个默认的对象可以连接。解决这个问题的办法是采用一种特殊的语法，明确建立这种关联：

```java
class WithInner {
	class Inner {}
}

class InheritInner extends WithInner.Inner {
	// InheritInner() {} // Compile error.
	InheritInner(WithInner wi) {
		wi.super();
	}
}
```

可以看到，InheritInner只对内部类进行了扩展，没有扩展外部类。但是在需要创建一个构造函数的时候，默认对象已经没有意义，我们不能只是传递封装对象的一个句柄。此外，必须在构造函数中采用下述语法：

```java
enclosingClassHandle.super();
```

它提供了必要的句柄，以便程序正确编译。

## 继承和finalize()
在继承的时候必须OverWrite衍生类中的finalize()方法，在覆盖衍生类的finalize()方法时，务必记住调用finalize()的基础版本。否则，基础类的初始化根本不会发生。finalize()的顺序最好和类的初始化顺序相反，这是由于衍生类finalize()的时候可能会要求基类的组件仍然处于活动状态。

## 类初始化过程
1. 为对象分配的存储空间初始化成二进制零。
2. 初始化基类
3. 按照声明的顺序调用成员初始化代码
4. 调用衍生类的构造函数
> 关于类的初始化过程最好去看一下《Java虚拟机规范》--https://docs.oracle.com/javase/specs/

## 继承中的异常声明
这个分为两种情况，一种是对于普通方法OverWrite的，另一种是对于构造函数的。
1. 对于普通方法声明的异常范围只能在继承和覆盖时变得更“窄”。也就是说在继承和覆盖的时候方法声明的异常不能超过父类中方法声明的异常的范围。因为在upcast的时候调用接口会多态调用到子类中的方法，如果子类覆盖的方法声明的异常超过父类接口，那么调用的代码将无法处理意想不到的异常。
2. 对于构造函数，子类构造函数中声明的异常只能变得更宽。也就是说子类的构造函数必须至少声明父类构造函数中声明的异常。这也很好理解，如果不是这样的话那么在子类构造实例的时候会调用父类的构造函数，这样调用者也有可能会收到意想不到的异常。

## 关于异常的一些事项
若调用了break和continue语句，finally语句也会得以执行。与break和continue一道，finally排除来了Java对跳转语句的需求。

关于异常的准则（用异常做下列事情）：
1. 解决问题并再次调用造成异常的方法。
2. 平息事态的发展，并在不重新尝试方法的前提下继续。
3. 计算另一些结果，而不是希望方法产生的结果。
4. 在当前环境中尽可能的解决问题，以及将相同的异常重新抛出一个更高级的环境。
5. 在当前环境中尽可能的解决问题，以及将不同的威力重新抛出一个更高级的环境。
6. 终止程序执行。
7. 简化编码。若异常方案使事情变得更加复杂，那就会使人非常烦恼，不如不用。
8. 使自己的库和程序变得更加安全。这是一种“短期投资”（便于调试），也是一种“长期投资”（改善应用程序的健壮性“

## 关于序列化
自定义序列化：
1. 实现Externalizable接口，实现writeExternal()和readExternal()方法。若从一个Externalizable对象继承，通常要调用writeExternal()和readExternal()方法的父类版本，以便正确的保存和回复基础类组件。
2. 实现Serializeble接口，并添加（注意是添加，不是实现或者覆写）writeObject()和readObject()方法。一旦对象被序列化或者重新装配就会调用这两个方法。也就是说，只要提供了这两个方法，就会优先使用它们而不考虑默认的序列化机制。两个方法的声明如下：

```java
private void writeObject(ObjectOutputStream stream) throws IOException;
private void readObject(ObjectInputStream stream) throws IOException, ClassNotFoundException;
```

看起来似乎我们调用ObjectOutputStream.writeObject()的时候，我们传递给它的Serializable对象似乎会被检查是否自己实现了writeObject()，如果是就会跳过常规的序列化过程，并调用writeObject()。readObject()也会遇到类似问题。
在我们的writeObject()内部，可以调用defaultWriteObject()，从而决定采取默认的writeObject()行为。类似的在readObject()中，可以调用defaultReadObject()。如下：

```java
private void writeObject(ObjectOutputStream stream) throws IOException {
	stream.defaultWriteObject();
    stream.writeObject(/*A transient property, for example.*/);
}
private void readObject(ObjectInputStream stream) throws IOException, ClassNotFoundException {
	stream.defaultReadObject();
    b = (String)stream.readObject();
}
```

如果对象A和对象B共同引用了对象C，那么如果把A和B序列化到一个流里面，那么只有一个对象C会被序列化，但是如果把A和B分别序列化到不同的流，再反序列化出来的时候就会有两个不同的对象C。

对于static的属性，需要我们亲自动手去序列化和反序列化。

## 关于clone
clone()方法是定义在Object类中的，但是可能考虑到不是每个类都需要克隆的能力，所以把Object中的clone方法设置成了protected。如果某个类想要拥有clone的特性，可以在类中对clone进行覆写，将它设置成public，然后再里面调用super.clone()。
除了覆写clone()方法，需要clone特性的类还需要实现Cloneable()接口。虽然这个接口并没有定义任何的方法，只是作为一个标记。
两方面的原因促成了Cloneable interface的这种存在。首先，可能有一个upcast句柄指向一个基础类型，而且不知道它是否真的能克隆那个对象。在这种情况下，可以用instanceof关键字调查句柄是否确实同一个能克隆的对象连接：

```java
if (myHandle instanceof Cloneable) //...
```

第二个原因是考虑到我们可能不愿所有的对象都能克隆。所以Object.clone()会验证一个类是否真的是实现了Cloneable接口。若答案是否定的，则抛出一个CloneNotSupportedException异常。

总之，如果希望一个类能够克隆，那么：
1. 实现Cloneable接口。
2. 覆写clone()。
3. 在自己的clone()中调用super.clone()。
4. 在自己的clone()中捕获异常。

## 为何会堵塞
线程的堵塞可能是由于下述五方面的原因造成的:
1. 调用sleep(m)，使线程进入”睡眠“状态。在规定的时间内，这个线程是不会运行的。
2. 用suspend()暂停了线程的执行。除非线程收到resume()消息，否则不会返回”可运行“状态。
3. 用wait()暂停了线程的执行。除非线程收到notify()或者notifyAll()消息，否则不会变成”可运行“状态。
4. 线程正在等候一些IO（输入输出）操作完成。
5. 线程试图调用另一个对象的”同步“方法，但是那个对象处于锁定状态，暂时无法使用。
> 在此推荐《Java并发编程实战》一书。

## wait()和notify()
wait()和notify()比较特别的地方是这个方法属于基础类Object的一部分，不像sleep()，suspend()以及resume()那样属于Thread的一部分。而且，我们能调用wait()的唯一地方是在一个同步的方法或者代码块内部。若在一个不同步的地方调用了wait()或者notifiy()，尽管程序仍然会通过编译，但是在运行的时候会得到一个IllegalMonitorStateException。
另外，最好不要使用stop()方法停止线程，因为它会解除所有由线程获取的锁定，而且如果对象处于一种不连贯状态，那么其他线程在那种状态下检查和修改它们，便会造成数据的不一致。
对于阻塞线程的停止，最好使用Thread提供的interrupt()方法。