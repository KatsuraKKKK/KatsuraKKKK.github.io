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

## 编辑单元（翻译单元）
每个编辑单元都必须以一个.java结尾，而且在编辑单元内部可以有一个public类，必须与编辑单元的名字相同。并且每个编辑单元中只能有一个public类，但是可以有多个非public类。如下：
```
// EditUnit.java
public class EditUnit {
}

class NotPublic {
}
```
