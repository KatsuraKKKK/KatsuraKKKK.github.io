---
layout: post
title: "Lambda Expression Of Java"
data: 2015-10-15 23:15:30 +0800
category: Java
tags:
- Java
- Lambda
- Java SE 8
comments: true
---

### 题记 ###
在阅读JDK源码*java.util.Collections*的时候在*UnmodifiableCollection*类中看到了这么一段代码：

```java
    public void forEach(Consumer<? super E> action) {
		c.forEach(action);
    }
```

而*Consumer*的源码如下：

```java
    @FunctionalInterface
	public interface Consumer<T> {
	    void accept(T t);
	    default Consumer<T> andThen(Consumer<? super T> after) {
	        Objects.requireNonNull(after);
	        return (T t) -> { accept(t); after.accept(t); };
	    }
	}
```

乍一看让我费解了一下，但是回过神来发现这不就是Java8的新特性Lambda表达式吗。原来对于这些新特性只是了解一下，没注意到在JDK源码中也使用到了，所以抽时间看了一下Java的Lambda表达式。

## Lambda演算 ##
Lambda演算在wiki上的非形式化表述如下：

```
	在λ演算中，每个表达式都代表一个函数，这个函数有一个参数，并且返回一个值。不论是参数和返回值，也都是一个单参的函数。可以这么说，λ演算中，只有一种“类型”，那就是这种单参函数。
	函数是通过λ表达式匿名地定义的，这个表达式说明了此函数将对其参数进行什么操作。例如，“加2”函数f(x)= x + 2可以用lambda演算表示为λx.x + 2 (或者λy.y + 2，参数的取名无关紧要)而f(3)的值可以写作(λx.x + 2) 3。函数的应用（application）是左结合的：f x y =(f x) y。
	考虑这么一个函数：它把一个函数作为参数，这个函数将被作用在3上：λf.f 3。如果把这个（用函数作参数的）函数作用于我们先前的“加2”函数上：(λf.f 3)(λx.x+2)，则明显地，下述三个表达式：
	    (λf.f 3)(λx.x+2) 与 (λx.x + 2) 3 与 3 + 2
	是等价的。有两个参数的函数可以通过lambda演算这么表达：一个单一参数的函数的返回值又是一个单一参数的函数（参见Currying）。例如，函数f(x, y) = x - y可以写作λx.λy.x - y。下述三个表达式：
	    (λx.λy.x - y) 7 2 与 (λy.7 - y) 2 与 7 - 2
	也是等价的。然而这种lambda表达式之间的等价性无法找到一个通用的函数来判定。
```

详细的形式化表述请跳转 [Lambda演算](https://zh.wikipedia.org/zh-cn/%CE%9B%E6%BC%94%E7%AE%97#lambda.E6.BC.94.E7.AE.97.E4.B8.AD.E7.9A.84.E7.AE.97.E8.A1.93)

## Java中的Lambda表达式 ##
在Java中Lambda表达式可以有多个参数，在[JSR335-FINAL](https://jcp.org/en/jsr/detail?id=335)(Java Specification Requests)中对Java中Lambda表达式的形式定义如下：

```
	LambdaExpression:
	  	LambdaParameters '->' LambdaBody

	LambdaParameters:
	  	Identifier
	  	'(' FormalParameterListopt ')'
	  	'(' InferredFormalParameterList ')'

	InferredFormalParameterList:
	 	Identifier
	  	InferredFormalParameterList ',' Identifier

	LambdaBody:
	  	Expression
	  	Block

	The following definitions from 8.4.1 are repeated here for convenience:

	FormalParameterList:
	  	LastFormalParameter
	  	FormalParameters ',' LastFormalParameter

	FormalParameters:
	  	FormalParameter
	  	FormalParameters, FormalParameter

	FormalParameter:
	  	VariableModifiersopt Type VariableDeclaratorId

	LastFormalParameter:
	  	VariableModifiersopt Type '...' VariableDeclaratorId
	  	FormalParameter
```

举例如下**Examples of lambda expressions**:

```
    () -> {}                     // No parameters; result is void
    () -> 42                     // No parameters, expression body
    () -> null                   // No parameters, expression body
    () -> { return 42; }         // No parameters, block body with return
    () -> { System.gc(); }       // No parameters, void block body
    () -> {
      	if (true) return 12;
      	else {
        	int result = 15;
        	for (int i = 1; i < 10; i++)
          		result *= i;
        	return result;
      	}
    }                          // Complex block body with returns
    (int x) -> x+1             // Single declared-type parameter
    (int x) -> { return x+1; } // Single declared-type parameter
    (x) -> x+1                 // Single inferred-type parameter
    x -> x+1                   // Parens optional for single inferred-type case
    (String s) -> s.length()   // Single declared-type parameter
    (Thread t) -> { t.start(); } // Single declared-type parameter
    s -> s.length()              // Single inferred-type parameter
    t -> { t.start(); }          // Single inferred-type parameter
    (int x, int y) -> x+y      // Multiple declared-type parameters
    (x,y) -> x+y               // Multiple inferred-type parameters
    (final int x) -> x+1       // Modified declared-type parameter
    (x, final y) -> x+y        // Illegal: can't modify inferred-type parameters
    (x, int y) -> x+y          // Illegal: can't mix inferred and declared types
```

*注意，在形式参数中推导参数和声明参数不能混用。*(Inferred-type parameters的类型是编译的时候从上下问中推断出来的，比如说是借口定义时指定的参数)

## Java SE 8: Lambda Quick Start ##
以下例子摘自 [Oracle-Java SE 8: Lambda Quick Start](http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/Lambda-QuickStart/index.html)

#### Runnable Lambda ####

```java
	public class LambdaTest {
		public static void main(String[] args) {
			LambdaTest LT = new LambdaTest();
			LT.runnableTest();
			LT.comparatorTest();
		}
		public void runnableTest() {
			System.out.println("=== RunnableTest ===");
			// Anonymous Runnable
			Runnable r1 = new Runnable() {
				@Override
				public void run() {
					System.out.println("Hello world one!");
				}
			};
			// Lambda Runnable
			Runnable r2 = () -> {
				System.out.println("Hello world two!");
				System.out.println("Hello world three!");
			};
			// Run em!
			r1.run();
			r2.run();
		}
	}
```

上面代码用Lambda表达式代替了*New*操作和*run*方法的定义，使得代码更为简洁。

#### Comparator Lambda ####

```java
	class Person {
		public String surName;
		public Person(String surName) {
			super();
			this.surName = surName;
		}
		public void printName() {
			System.out.println(this.surName);
		}
	}

	public void comparatorTest() {
		List<Person> personList = new ArrayList<Person>();
		personList.add(new Person("B"));
		personList.add(new Person("A"));

		//		// Sort with Inner Class
		//		Collections.sort(personList, new Comparator<Person>() {
		//			public int compare(Person p1, Person p2) {
		//				return p1.surName.compareTo(p2.surName);
		//			}
		//		});
		//
		//		System.out.println("=== Sorted Asc SurName ===");
		//		for (Person p : personList) {
		//			 p.printName();
		//		}

		// Use Lambda instead
		// Print Asc
		System.out.println("=== Sorted Asc SurName ===");
		Collections.sort(personList, (p1, p2) -> p1.surName.compareTo(p2.surName));
		for (Person p : personList) {
			p.printName();
		}

		// Print Desc
		System.out.println("=== Sorted Desc SurName ===");
		Collections.sort(personList, (p1, p2) -> p2.surName.compareTo(p1.surName));
		for (Person p : personList) {
			p.printName();
		}
	}
```

这里则是用Lambda表达式代替了匿名的对象*Comparator*的作用。

## Function ##
原先我以为Lambda表达式的加入只是一个简单的语法糖，但是后面发现还有更多的语法糖。设想一下如果你需要对一个List的数据做判断和筛选，通常我们会按照下面这种一般做法。

```java
	public class Person {
		public String givenName;
		public String surName;
		public int age;
		public Gender gender;
		public String eMail;
		public String phone;
		public String address;
		//getters and setters
        //...
	}

	public class RoboContactMethods2 {
		public void callDrivers(List<Person> pl){
           	for(Person p:pl){
             	if (isDriver(p)){
               		roboCall(p);
             	}
           }
		}

       	public boolean isDriver(Person p){
           	return p.getAge() >= 16;
       	}

       	public void roboCall(Person p){
           	System.out.println("Calling " + p.getGivenName() + " " + p.getSurName() + " age " + p.getAge() + " at " + p.getPhone());
     	}
	}
```

这样如果有多个过滤条件的需求，就需要实现更多的判断函数，那么更文艺一些的做法是这样的(还是用上面的Person对象举例)：

```java
	public interface MyTest<T> {
       	public boolean test(T t);
    }

    public class RoboContactAnon {
       	public void phoneContacts(List<Person> pl, MyTest<Person> aTest){
         	for(Person p:pl){
           		if (aTest.test(p)){
             		roboCall(p);
           		}
         	}
       	}

       	public void roboCall(Person p){
         	System.out.println("Calling " + p.getGivenName() + " " + p.getSurName() + " age " + p.getAge() + " at " + p.getPhone());
       	}

	   	public static void main (String[] args) {
			//get PersonList for testing.
	   		List<Person> pl = getInitedPersonList();
			RoboContactAnon rca = new RoboContactAnon();
			rca.phoneContacts(pl, (p) -> p.getAge() > 16);
	   	}
	}
```

我们这里使用了一个自定义的*MyTest*接口，但是其实我们不需要自己定义这个接口，因为在Java SE 8中，JDK为我们提供了一系列的接口供我们使用，比如我们的*MyTest*接口就可以用系统提供的*Predicte*接口进行替代，它的定义跟MyTest类似：

```java
    public interface Predicate<T> {
        public boolean test(T t);
    }
```

除了*Predicte*，JDK还提供了一系列的接口供我们在不同的场景使用。它们在*java.util.function*包中。下面是列举的是JDK提供的一部分接口：

```
	- Predicate: A property of the object passed as argument
    - Consumer: An action to be performed with the object passed as argument
    - Function: Transform a T to a U
    - Supplier: Provide an instance of a T (such as a factory)
    - UnaryOperator: A unary operator from T -> T
    - BinaryOperator: A binary operator from (T, T) -> T
```

## Collections ##
除了上面提到的语法糖，和java.util.function包以外，Java SE 8还增加了*java.util.stream*，这是对Collections对象起到了一定的增强。考虑以下场景“你需要对一个List根据一定的条件对元素进行过滤，然后求过滤后元素某个属性的平均值”。我们的做法一般是这样：

```java
	//仍旧以List<Person>举例
	double sum = 0;
	int count = 0;
	for (Person p : personList) {
		if (p.getAge() > 0) {
			sum += p.getAge();
			cout++;
		}
	}
	double average = count > 0 ? sum/average : 0;
```

如果我们使用stream的话，就可以用更文艺一点的写法：

```java
	// Get average of ages
	OptionalDouble averageAge = pl
             .stream()
             .filter((p) -> p.getAge() > 16)
             .mapToDouble(p -> p.getAge())
             .average();
```

可以看到这样写的话代码确实更简洁了，它把*List*转换成一个*Stream*，然后对元素进行操作。而且如果我们做的操作对元素的顺序没有要求那么我们可以将*stream()*方法换成*parallelStream()*方法，这样可以得到一个可以并行处理的流，当我们对元素进行处理的时候，JVM会把这个流进行划分，对每一个部分并行的进行处理，然后再进行归并，这样可以提高处理的效率，而这些对开发人员是透明的。

划分，映射，归并，这些听起来有没有觉得很熟悉，对，这就是*MapReduce*，只是跟*Hadoop*用机器作为处理节点不一样的是这里对于划分的处理是在一个JVM里面进行的。在*java.util.stream*中给我们提供了一个通用的*reduce()*方法：

```java
 	<U> U reduce(U identity,
              BiFunction<U, ? super T, U> accumulator,
              BinaryOperator<U> combiner);

	int sumOfWeights = widgets.stream()
              				.reduce(0,
                          	(sum, b) -> sum + b.getWeight()),
                            Integer::sum);
```

其中identity是一个reduce的初始值，如果没有元素进行reduce的话则返回identitiy值，如果有元素进行reduce则在identity上进行累加。accumulator是一个累加器，负责把部分结果与另一个元素进行累加，combiner则是一个合并器，负责把不同部分的子结果进行合并，取得最终的结果。这里如果所进行的运算对元素的元素没有要求的话我们可以使用parallelStream()，取得一个并行的流，这样才能对流进行划分和并行处理，充分发挥这些新特性的性能。

将一个输入的collection做转换也是可以的比如下面的例子就返回了元素中某个属性的List：

```java
 	<R> R collect(Supplier<R> supplier,
               BiConsumer<R, ? super T> accumulator,
               BiConsumer<R, R> combiner);

     ArrayList<String> strings = stream.collect(() -> new ArrayList<>(),
                                                (c, e) -> c.add(e.toString()),
                                                (c1, c2) -> c1.addAll(c2));

     List<String> strings = stream.map(Object::toString)
                                  .collect(ArrayList::new, ArrayList::add, ArrayList::addAll);
```

有可能你觉得这不是KV对操作，不像MapReduce，那么你可以将结果映射成一个Map，这就是妥妥的KV对了，这个操作需要使用到groupingBy(Collection collection)方法：

```java
     Collector<Employee, ?, Integer> summingSalaries
         = Collectors.summingInt(Employee::getSalary);

     Map<Department, Integer> salariesByDept
         = employees.stream().collect(Collectors.groupingBy(Employee::getDepartment,
                                                            summingSalaries));
```

以上只是对于stream的简单举例，详情请阅读[JSR335-FINAL](https://jcp.org/en/jsr/detail?id=335)(Java Specification Requests)中关于java.util.stream的部分。

### 后记 ###
起初我认为这些新特性只是一些语法糖，现在我也还认为这个特性是个语法糖。虽然在开发过程中很少用到这个新特性（甚至都不会用到），但是了解这些新特性总是没有坏除的，恰当的使用这些新特性在某些场景下的确可以取得很好的效果（简洁的代码，优秀的性能）。这篇文章的初衷一是对自己所得的记录，二是做一个分享。写得不好的或者谬误的地方还请大家批评指正，一起交流，共同进步。

### 参考文献 ###

[Lambda演算-wikipedia](https://zh.wikipedia.org/zh-cn/%CE%9B%E6%BC%94%E7%AE%97#lambda.E6.BC.94.E7.AE.97.E4.B8.AD.E7.9A.84.E7.AE.97.E8.A1.93)

[JSR335-FINAL](https://jcp.org/en/jsr/detail?id=335)(Java Specification Requests)

[Oracle-Java SE 8: Lambda Quick Start](http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/Lambda-QuickStart/index.html)

[My Github](http://katsurakkkk.github.io/)