# &lt;Tinking In Java>拾遗

## 返回值过载
不能用返回值对函数进行overload，因为有可能调用方并不关心返回值，这就造成了二义性。如：
```
void f();
int f();
```
调用f()的时候就会造成二义性。

## this引用
可以用this引用在构造函数中调用过载的构造函数，但是只能调用一个，并且构造函数调用必须是我们做的第一件事，否则编译器会报错。另外，只能在构造函数中调用其它构造函数。
```
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
```
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
```
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
```
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
```
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
```
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