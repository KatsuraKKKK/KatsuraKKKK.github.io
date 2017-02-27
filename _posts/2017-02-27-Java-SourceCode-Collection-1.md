---
layout: post
title: "JDK源码阅读—基本集合类"
data: 2017-02-27 11:36:30 +0800
category: Java
tags:
- Java
- Jdk
- SourceCode
comments: true
---

#JDK源码阅读—基本集合类

本文主要为自己在阅读JDK集合类源码的一些笔记，其中涉及java.util包中的集合类型，没有包括java.util.concurrent包。
惯例的类图
![collection1]({{ site.baseurl}}/images/2017/02/colletion1.png)

### Vector 
 Vector 实现可增长的对象数组。与数组一样，它包含可以使用整数索引进行访问的组件。Vector 的大小可以根据需要增大或缩小，以适应创建 Vector 后进行添加或移除项的操作。
每个向量会试图通过维护 capacity 和 capacityIncrement 来优化存储管理。capacity始终至少应与向量的大小相等；这个值通常比后者大些，因为随着将组件添加到向量中，其存储将按 capacityIncrement的大小增加存储。应用程序可以在插入大量组件前增加向量的容量；这样就减少了增加的重分配的量。 它是线程安全的。
下面是它的扩容相关的方法。

```java
protected Object[] elementData;
protected int capacityIncrement; // 如果不设置，在扩容时翻倍
public synchronized void ensureCapacity(int minCapacity) {
    if (minCapacity > 0) {
        modCount++;
        ensureCapacityHelper(minCapacity);
    }
}

private void ensureCapacityHelper(int minCapacity) {
    // overflow-conscious code
    if (minCapacity - elementData.length > 0)
        grow(minCapacity);
}

private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;
private void grow(int minCapacity) {
    // overflow-conscious code
    int oldCapacity = elementData.length;
    int newCapacity = oldCapacity + ((capacityIncrement > 0) ? capacityIncrement : oldCapacity);
    if (newCapacity - minCapacity < 0)
        newCapacity = minCapacity;
    if (newCapacity - MAX_ARRAY_SIZE > 0) 
        newCapacity = hugeCapacity(minCapacity);
    elementData = Arrays.copyOf(elementData, newCapacity);
}

private static int hugeCapacity(int minCapacity) {
    if (minCapacity < 0) // overflow
        throw new OutOfMemoryError();
    return (minCapacity > MAX_ARRAY_SIZE) ? Integer.MAX_VALUE :
        MAX_ARRAY_SIZE;
}
```

### ArrayList

ArrayList是List的数组实现，使用数组作为元素存储的数据结构，使用的是一个Object[]。下面是ArrayList数组扩容的方法。

```java
private void grow(int minCapacity) {
  // 下面代码考虑了int的溢出
  int oldCapacity = elementData.length;
  int newCapacity = oldCapacity + (oldCapacity >> 1);
  if (newCapacity - minCapacity < 0)
  newCapacity = minCapacity;
  if (newCapacity - MAX_ARRAY_SIZE > 0)
    newCapacity = hugeCapacity(minCapacity);
  elementData = Arrays.copyOf(elementData, newCapacity);
}

private static int hugeCapacity(int minCapacity) {
  if (minCapacity < 0) // overflow
    throw new OutOfMemoryError();
  return (minCapacity > MAX_ARRAY_SIZE) ? Integer.MAX_VALUE : MAX_ARRAY_SIZE;
}
```

另外，subList()方法提供的是ArrayList的一个视图，列表的修改冲突使用一个modCount计数器作为判断依据。Iterator中有一个modCount的快照，在修改数组的时候如果快照与modCount不相等说明列表被同时修改了，这时候操会抛出异常。
ArrayList不是线程安全的。

### LinkedList

LinkedList是列表的双向链表实现，在LinkedList中有first，last两个Node的引用，分别是链表的头和尾。
Node的数据结构如下。

```java
private static class Node<E> {
    E item;
    Node<E> next;
    Node<E> prev;
    Node(Node<E> prev, E element, Node<E> next) {
        this.item = element;
        this.next = next;
        this.prev = prev;
    }
}
```

LinkedList因为使用的是链表的实现，所以不存在数组扩容的问题，其他的实现与ArrayList类似，只是换成了链表的相关操作。
下面是获取对应index的节点的操作，还是做了一些优化的：

```java
/**
 * Returns the (non-null) Node at the specified element index.
 */
Node<E> node(int index) {
    // assert isElementIndex(index);
    // 如果index小于size的二分之一则从头遍历，否则从链尾遍历
    if (index < (size >> 1)) {
        Node<E> x = first;
        for (int i = 0; i < index; i++)
            x = x.next;
        return x;
    } else {
        Node<E> x = last;
        for (int i = size - 1; i > index; i--)
            x = x.prev;
        return x;
    }
}
```

LinkedList也不是线程安全的。


### HashMap

HashMap使用一个Node<K,V>数组作为桶的数据结构。在有元素冲突发生的时候，使用链表和红黑树解决冲突。当一个桶中的元素小于TREEIFY_THRESHHOLD的时候，使用链表处理冲突，否则用将链表转换成红黑树。当桶中的元素个数小于UNTREEIFY_THRESHOLD的时候，将红黑树转换成链表。
由于红黑树是一种部分平衡的二叉搜索树，这使得在一个桶中元素较多的时候HashMap避免遍历链表，还能有较好的查询性能。


```java
static final int TREEIFY_THRESHOLD = 8
static final int UNTREEEIFY_THRESHOLD = 6
static final int MIN_TREEIF_CAPACITY = 64
transuebt Node<K,N>[] table;
transient Set<Map.Entry<K,V>> entrySet;
//基本的节点类
static class Node<K,V> implements Map.Entry<K,V> {
    final int hash;
    final K key;
    V value;
    Node<K,V> next;
    // ...
    public final int hashCode() {
        return Objects.hashCode(key) ^ Objects.hashCode(value);
    }
    // ...
    public final boolean equals(Object o) {
        if (o == this)
            return true;
        if (o instanceof Map.Entry) {
            Map.Entry<?,?> e = (Map.Entry<?,?>)o;
            if (Objects.equals(key, e.getKey()) &&
                Objects.equals(value, e.getValue()))
                return true;
        }
        return false;
    }
}

/**
 * 对于传入的size，计算能够容纳该size的2的最小次幂，这个神奇的算法在《算法心得》中有提到。
 */
static final int tableSizeFor(int cap) {
    int n = cap - 1;
    n |= n >>> 1;
    n |= n >>> 2;
    n |= n >>> 4;
    n |= n >>> 8;
    n |= n >>> 16;
    return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
}
/**
 * 元素插入
 */
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
    Node<K,V>[] tab; Node<K,V> p; int n, i;
    if ((tab = table) == null || (n = tab.length) == 0)
        n = (tab = resize()).length;
    if ((p = tab[i = (n - 1) & hash]) == null)
        tab[i] = newNode(hash, key, value, null);
    else {
        Node<K,V> e; K k;
        if (p.hash == hash && ((k = p.key) == key || (key != null && key.equals(k))))
            e = p;
        else if (p instanceof TreeNode) // 如果是红黑树节点
            e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
        else {
            for (int binCount = 0; ; ++binCount) {
                if ((e = p.next) == null) { // 没有已存在的相等节点
                    p.next = newNode(hash, key, value, null);
                    // 是否超过转化成红黑树的阀值
                    if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                        treeifyBin(tab, hash);
                    break;
                }
                if (e.hash == hash && ((k = e.key) == key || (key != null && key.equals(k)))) // 找到想等节点
                    break;
                p = e;
            }
        }
        if (e != null) { // existing mapping for key
            V oldValue = e.value;
            if (!onlyIfAbsent || oldValue == null)
                e.value = value;
            afterNodeAccess(e);
            return oldValue;
        }
    }
    ++modCount;
    if (++size > threshold)
        resize();
    afterNodeInsertion(evict);
    return null;
  }

/**
 * 扩容Map
 */
final Node<K,V>[] resize() {
    Node<K,V>[] oldTab = table;
    int oldCap = (oldTab == null) ? 0 : oldTab.length;
    int oldThr = threshold;
    int newCap, newThr = 0;
    if (oldCap > 0) {
        if (oldCap >= MAXIMUM_CAPACITY) {
            threshold = Integer.MAX_VALUE;
            return oldTab;
        } else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                  oldCap >= DEFAULT_INITIAL_CAPACITY) 
            newThr = oldThr << 1; // 原来的两倍
    } else if (oldThr > 0) // initial capacity was placed in threshold
        newCap = oldThr;
    else {               // zero initial threshold signifies using defaults
        newCap = DEFAULT_INITIAL_CAPACITY;
        newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
    }
    if (newThr == 0) {
        float ft = (float)newCap * loadFactor;
        newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                 (int)ft : Integer.MAX_VALUE);
    }
    threshold = newThr;
    @SuppressWarnings({"rawtypes","unchecked"})
    Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
    table = newTab;
    if (oldTab != null) {
        // rehash
        for (int j = 0; j < oldCap; ++j) {
            Node<K,V> e;
            if ((e = oldTab[j]) != null) {
                oldTab[j] = null;
                if (e.next == null) // 如果桶中只有一个元素
                    newTab[e.hash & (newCap - 1)] = e;
                else if (e instanceof TreeNode) // 处理红黑树
                    ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                else { // preserve order
                    Node<K,V> loHead = null, loTail = null;
                    Node<K,V> hiHead = null, hiTail = null;
                    Node<K,V> next;
                    // 这一段处理比较巧妙，用e.hash & oldCap根据oldCap的为1的那一位是否是1来判断该元素是在新的桶数组的前一半还是后一半
                    do {
                        next = e.next;
                        if ((e.hash & oldCap) == 0) {
                            if (loTail == null)
                                loHead = e;
                            else
                                loTail.next = e;
                                loTail = e;
                            }
                        else {
                            if (hiTail == null)
                                hiHead = e;
                            else
                                hiTail.next = e;
                                hiTail = e;
                            }
                    } while ((e = next) != null);
                    // lowHalf 在新桶数组的前一半
                    if (loTail != null) {
                        loTail.next = null;
                        newTab[j] = loHead;
                    }
                    // highHalf 在新桶数组的后一半
                    if (hiTail != null) {
                        hiTail.next = null;
                        newTab[j + oldCap] = hiHead;
                    }
                }
            }
        }
    }
    return newTab;
}
```
  
另外，在HashMap中的KeySet, Values, EntrySet都只是一个view，遍历通过相应的Iterator进行。HashMap不是线程安全的.那个神奇的求2的幂的算法我之前的文章也有提过 [ConcurrentHashMap中的2的n次幂上舍入方法](http://katsurakkkk.github.io/2014/12/concurrentHashMap%E4%B8%AD%E7%9A%842%E7%9A%84n%E6%AC%A1%E5%B9%82%E4%B8%8A%E8%88%8D%E5%85%A5%E6%96%B9%E6%B3%95)

### HashTable

HashTable是线程安全的Map实现，使用方法级的synchronized保证线程安全。
默认的初始化大小是11，size并不是2的幂，与HashMap 的不一样，它也是使用链表法处理冲突。下面是几个关键的操作方法，足以让我们了解HashTable的数据结构操作。

```java

private transient Entry<?,?>[] table;

protected void rehash() {
    int oldCapacity = table.length;
    Entry<?,?>[] oldMap = table;

    // 考虑了溢出的情况
    // 新的size是两倍＋1，跟HashMap的不一样
    int newCapacity = (oldCapacity << 1) + 1;
    if (newCapacity - MAX_ARRAY_SIZE > 0) {
        if (oldCapacity == MAX_ARRAY_SIZE)
            // Keep running with MAX_ARRAY_SIZE buckets
            return;
        newCapacity = MAX_ARRAY_SIZE;
    }
    Entry<?,?>[] newMap = new Entry<?,?>[newCapacity];

    modCount++;
    threshold = (int)Math.min(newCapacity * loadFactor, MAX_ARRAY_SIZE + 1);
    table = newMap;

    for (int i = oldCapacity ; i-- > 0 ;) {
        for (Entry<K,V> old = (Entry<K,V>)oldMap[i] ; old != null ; ) {
            Entry<K,V> e = old;
            old = old.next;
            int index = (e.hash & 0x7FFFFFFF) % newCapacity;
            e.next = (Entry<K,V>)newMap[index];
            newMap[index] = e;
        }
    }
}

private void addEntry(int hash, K key, V value, int index) {
    modCount++;
    Entry<?,?> tab[] = table;
    if (count >= threshold) {
        // Rehash the table if the threshold is exceeded
        rehash();
        tab = table;
        hash = key.hashCode();
        // 这里用了我们常见的取模操作
        index = (hash & 0x7FFFFFFF) % tab.length;
    }
    // Creates the new entry.
    @SuppressWarnings("unchecked")
    Entry<K,V> e = (Entry<K,V>) tab[index];
    tab[index] = new Entry<>(hash, key, value, e);
    count++;
}
    
@Override
public synchronized boolean remove(Object key, Object value) {
    Objects.requireNonNull(value);
    Entry<?,?> tab[] = table;
    int hash = key.hashCode();
    int index = (hash & 0x7FFFFFFF) % tab.length;
    @SuppressWarnings("unchecked")
    Entry<K,V> e = (Entry<K,V>)tab[index];
    for (Entry<K,V> prev = null; e != null; prev = e, e = e.next) {
        if ((e.hash == hash) && e.key.equals(key) && e.value.equals(value)) {
            modCount++;
            if (prev != null) {
                prev.next = e.next;
            } else {
                tab[index] = e.next;
            }
            count--;
            e.value = null;
            return true;
        }
    }
    return false;
}
```

### ArrayDeque

双端队列Deque接口的数组实现，非线程安全，使用数组作为存储数据结构，可以在使用的时候自动扩容。

```java

transient Object[] elements; // non-private to simplify nested class access 
// 队列头索引
transient int head;
// 队列尾索引
transient int tail;
/**
  * 又是这个神奇的算法
  * Allocates empty array to hold the given number of elements.
  */
private void allocateElements(int numElements) {
    int initialCapacity = MIN_INITIAL_CAPACITY;
    // Find the best power of two to hold elements.
    // Tests "<=" because arrays aren't kept full.
    if (numElements >= initialCapacity) {
        initialCapacity = numElements;
        initialCapacity |= (initialCapacity >>>  1);
        initialCapacity |= (initialCapacity >>>  2);
        initialCapacity |= (initialCapacity >>>  4);
        initialCapacity |= (initialCapacity >>>  8);
        initialCapacity |= (initialCapacity >>> 16);
        initialCapacity++;
        if (initialCapacity < 0)   // Too many elements, must back off
            initialCapacity >>>= 1;// Good luck allocating 2 ^ 30 elements
    }
    elements = new Object[initialCapacity];
}

private void doubleCapacity() {
    assert head == tail;
    int p = head;
    int n = elements.length;
    int r = n - p; // number of elements to the right of p
    int newCapacity = n << 1;
    if (newCapacity < 0)
        throw new IllegalStateException("Sorry, deque too big");
    Object[] a = new Object[newCapacity];
    System.arraycopy(elements, p, a, 0, r);
    System.arraycopy(elements, 0, a, r, p);
    elements = a;
    head = 0;
    tail = n;
}

```

对于ArrayDeque的操作，就要看内部类DeqIterator的实现了，以下是部分代码。

```java
private class DeqIterator implements Iterator<E> {
    // 头尾索引
    private int cursor = head;
    private int fence = tail;

    // next方法返回的位置, 如果有元素被删除，那么重置为-1
    private int lastRet = -1;

    public boolean hasNext() {
        return cursor != fence;
    }

    public E next() {
        if (cursor == fence)
            throw new NoSuchElementException();
        @SuppressWarnings("unchecked")
        E result = (E) elements[cursor];
        if (tail != fence || result == null)
            throw new ConcurrentModificationException();
        lastRet = cursor;
        cursor = (cursor + 1) & (elements.length - 1); // 相当于取模
        return result;
    }

    public void remove() {
        if (lastRet < 0)
            throw new IllegalStateException();
        if (delete(lastRet)) { // if left-shifted, undo increment in next()
            cursor = (cursor - 1) & (elements.length - 1);
            fence = tail;
        }
        lastRet = -1;
    }
    /**
     * 这个方法中注意为尽量少移动元素而进行的优化
     */ 
    private boolean delete(int i) {
        checkInvariants();
        final Object[] elements = this.elements;
        final int mask = elements.length - 1;
        final int h = head;
        final int t = tail;
        final int front = (i - h) & mask; // i到head的距离
        final int back  = (t - i) & mask; // i到tail的距离
        // Invariant: head <= i < tail mod circularity
        if (front >= ((t - h) & mask))
            throw new ConcurrentModificationException();
        // 为尽量少移动元素优化
        if (front < back) {
            // 离head比较近
            if (h <= i) {
                // 正常情况
                System.arraycopy(elements, h, elements, h + 1, front);
            } else { // Wrap around
                // oioootail****heado这种情况，o表示有元素*表示没有元素
                System.arraycopy(elements, 0, elements, 1, i);
                elements[0] = elements[mask];
                System.arraycopy(elements, h, elements, h + 1, mask - h);
            }
            elements[h] = null;
            head = (h + 1) & mask;
            return false;
        } else {
            // 离head比较远
            if (i < t) { // Copy the null tail as well
                System.arraycopy(elements, i + 1, elements, i, back);
                tail = t - 1;
            } else { // Wrap around
                // otail****headooio这种情况，o表示有元素*表示没有元素
                System.arraycopy(elements, i + 1, elements, i, mask - i);
                elements[mask] = elements[0];
                System.arraycopy(elements, 1, elements, 0, t);
                tail = (t - 1) & mask;
            }
            return true;
        }
    }
```


### LinkedHashMap
在Map的实现中，HashMap是无序的。而LinkedHashMap则是有序Map的一种，这个顺序可以是访问顺序或者插入顺序，这个根据构造函数的参数而定，默认是插入顺序。
LinkedHashMap维护了一个Entry的双向链表，通过重写父类HashMap中的操作后处理方法和TreeNode操作方法来维护链表。

```java
Node<K,V> replacementNode(Node<K,V> p, Node<K,V> next) {
    // ...
    transferLinks(q, t);
    return t;
}

TreeNode<K,V> newTreeNode(int hash, K key, V value, Node<K,V> next) {
    // ...
    linkNodeLast(p);
    return p;
}

TreeNode<K,V> replacementTreeNode(Node<K,V> p, Node<K,V> next) {
    // ...
    transferLinks(q, t);
    return t;
}

void afterNodeRemoval(Node<K,V> e) { // unlink
    LinkedHashMap.Entry<K,V> p =
        (LinkedHashMap.Entry<K,V>)e, b = p.before, a = p.after;
    p.before = p.after = null;
    if (b == null)
        head = a;
    else
        b.after = a;
    if (a == null)
        tail = b;
    else
        a.before = b;
}

void afterNodeInsertion(boolean evict) { // possibly remove eldest
    LinkedHashMap.Entry<K,V> first;
    if (evict && (first = head) != null && removeEldestEntry(first)) {
        K key = first.key;
        removeNode(hash(key), key, null, false, true);
    }
}

void afterNodeAccess(Node<K,V> e) { // move node to last
    LinkedHashMap.Entry<K,V> last;
    if (accessOrder && (last = tail) != e) {
        LinkedHashMap.Entry<K,V> p = (LinkedHashMap.Entry<K,V>)e, b = p.before, a = p.after;
        p.after = null;
        if (b == null)
            head = a;
        else
            b.after = a;
        if (a != null)
            a.before = b;
        else
            last = b;
        if (last == null)
            head = p;
        else {
            p.before = last;
            last.after = p;
        }
        tail = p;
        ++modCount;
    }
}
```

### TreeMap

说到有序的Map就不能不提TreeMap了。它是基于红黑树（Red-Black tree）的 NavigableMap 实现。该映射根据其键的自然顺序进行排序，或者根据创建映射时提供的 Comparator 进行排序，具体取决于使用的构造方法。此实现为 containsKey、get、put 和 remove 操作提供受保证的 log(n) 时间开销。这些算法是 Cormen、Leiserson 和 Rivest 的 Introduction to Algorithms 中的算法的改编。
TreeMap的操作更多是跟红黑树的实现相关，在这里我就不仔细说了（其实我也说不清楚哈哈），详情可以参考红黑树的wiki百科[Red Black Tree](https://en.wikipedia.org/wiki/Red%E2%80%93black_tree)

### WeakHashMap

 以弱键实现的基于哈希表的Map。在WeakHashMap中，当某个键不再正常使用时，将自动移除其条目。更精确地说，对于一个给定的键，其映射的存在并不阻止垃圾回收器对该键的丢弃，这就使该键成为可终止的，被终止，然后被回收。丢弃某个键时，其条目从映射中有效地移除，因此，该类的行为与其他的Map实现有所不同。 
 它将Key关联到一个弱引用，而元素的KV对象Entry继承自WeakReference，并绑定了一个队列，弱引用不影响GC对于Key的回收，当Key被回收以后，Entry会被添加到ReferenceQueue中。
 WakHashMap适合内存敏感的应用场景。
 
```java

/**
  * Reference queue for cleared WeakEntries
  */
private final ReferenceQueue<Object> queue = new ReferenceQueue<>();

private static class Entry<K,V> extends WeakReference<Object> implements Map.Entry<K,V> {
    V value;
    final int hash;
    Entry<K,V> next;

    /**
     * Creates new entry.
     */
    Entry(Object key, V value, ReferenceQueue<Object> queue, int hash, Entry<K,V> next) {
        super(key, queue);  // 调用WeakReference构造函数
        this.value = value;
        this.hash  = hash;
        this.next  = next;
    }
}

/**
 * 这个方法将队列中的Node清除
 */
private void expungeStaleEntries() {
    for (Object x; (x = queue.poll()) != null; ) {
        synchronized (queue) {
            @SuppressWarnings("unchecked")
                Entry<K,V> e = (Entry<K,V>) x;
            int i = indexFor(e.hash, table.length);

            Entry<K,V> prev = table[i];
            Entry<K,V> p = prev;
            while (p != null) {
                Entry<K,V> next = p.next;
                if (p == e) {
                    if (prev == e)
                        table[i] = next;
                    else
                        prev.next = next;
                    // Must not null out e.next;
                    // stale entries may be in use by a HashIterator
                    e.value = null; // Help GC
                    size--;
                    break;
                }
                prev = p;
                p = next;
            }
        }
    }
}
```

以上，下次估计是要写concurrent包了吧。