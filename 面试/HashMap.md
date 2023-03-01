# 问题

1、hashMap和hashTable的区别

> ①、HashMap 是线程不安全的，HashTable 是线程安全的；
>
> ②、由于线程安全，所以 HashTable 的效率比不上 HashMap；
>
> ③、HashMap最多只允许一条记录的键为null，允许多条记录的值为null，而 HashTable不允许；
>
> ④、HashMap 默认初始化数组的大小为16，HashTable 为 11，前者扩容时，扩大两倍，后者扩大两倍+1；
>
> ⑤、HashMap 需要重新计算 hash 值，而 HashTable 直接使用对象的 hashCode

2、hashTable和concurrentHashMap的区别

> 1、数据结构不一样，hashTable全部都是链表结构，没有转换红黑树的情况
>
> 2、锁的粒度不同，hashTable是整个数组一个锁。concurrentHashMap是每个哈希桶一个锁，且只对写操作加锁（1.8之后）

3、LinkedHashMap和HashMap的区别

>1、底层都是使用数组+链表实现。但是LinkedHashMap是有序的，hashMap是无序的
>
>2、LinkedHashMap底层使用双向链表保持顺序。（原有的结构上，增加一个双向链表用于记录顺序，分为访问顺序和插入顺序）

4、说说你对红黑树的见解？

> - 每个节点非红即黑
> - 根节点总是黑色的
> - 如果节点是红色的，则它的子节点必须是黑色的（反之不一定）
> - 每个叶子节点都是黑色的空节点（NIL节点）
> - 从根节点到叶节点或空子节点的每条路径，**必须包含相同数目的黑色节点**（即相同的黑色高度）
>
> **为什么HashMap使用红黑树而不使用AVL树?**
>
> 红黑树适用于大量插入和删除；因为它是非严格的平衡树；只要从根节点到叶子节点的最长路径不超过最短路径的2倍，就不用进行平衡调节
>
> AVL 树是严格的平衡树，上述的最短路径与最长路径的差不能超过 1，AVL 允许的差值小；在进行大量插入和删除操作时，会频繁地进行平衡调整，严重降低效率；

# 1. hashMap的结构

由数组和链表组合构成

数组中每个地方都是保存了key-value这样的实例，本身所有位置都是null。在put的时候会根据key的hash及计算一个index值

![链表+数组](https://img-blog.csdnimg.cn/20181102221702492.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dvc2hpbWF4aWFvMQ==,size_16,color_FFFFFF,t_70)

为什么会需要链表呢<br/>
为了解决哈希冲突，即因为计算的原因会导致同一个key值计算出来的hashCode相同。所以index就相同。
对于一个index会出现多个key-value。这个时候就需要使用链表来存储多个

```java
Map<String,String> map=new HashMap<>();

map.put("蛋炒饭","我爱吃蛋炒饭");
map.put("饭炒蛋","我爱吃蛋炒饭");
```

即比如`蛋炒饭`和`饭炒蛋`两个值计算的hash数值一样的时候。就会导致存入的index是同一个，这个时候就需要使用链表来将其存储在同一个index上

```java
hashMap的源码

    static class Node<K,V> implements Map.Entry<K,V> {
        final int hash;
        final K key;
        V value;
        Node<K,V> next;
    }
```

可以看到每个hashmap都需要四个参数，hash、key、value及next

# HashMap底层原理结构分析

数组和链表上存储的是Entry的对象（对象中包含Key和value）

在进行数据插入的时候，对数据进行取模运算，来存储在**数组**的一个节点上。如果发现取模结果的节点已经存在，就在这个节点之后的**链表**上往后增加数据，如果一条链表的数据超过了八个，就会转变成**红黑树**（少于6个转换成链表）

四大方法**hash**、**get**、**put**、**resize**（扩容）

# 头插法和尾插法

针对链表的插入，也就是hash值相同时，java8之前使用的头插法，即新来的值会在插入链表时。因为开发者认为新来的值检索的可能性更大，这样可以提升查询效率。

java8之后，都改成了尾插法。因为hashMap的扩容机制

为什么不是用头插法了，而使用尾插法呢。

因为在多线程的时候，如果一个线程在插入头部的时候，处理器或者其他问题中间插入了一条新的。由于头插法会改变链表中的顺序，所以会在resize扩容的时候出现环形链表的情况。这也就是为什么hashMap是线程不安全的原因

jdk8之后，链表使用了红黑树。红黑树将链表的时间复杂度从O(n)降到了O(logn)。如果**使用尾插**，在扩容时会保持链表元素原本的顺序，就不会出现链表成环的问题了。

但是这样仍然没办法解决线程不安全的问题，毕竟存在一个线程在做put的时候还有其他在做get。还是没有使用加锁来解决这个问题。

## Put

Put步骤：
1、hash运算：进行Hash获取对应的HashCode，这个操作减少了hash冲突的可能，将所有的32位全部参与运算（先对原值右移16位再与原值进行异或处理）<br/>
2、是否初始化：判断数组是否为空，如果为空就进行第一次扩容（初始化类似）<br/>
3、定位数组下标：按照key的hash值找到在数组的下标位置。判断数组上的第一个元素的key是否等于该key。如果等于就直接覆盖，如果不等于就去遍历该下标下面的链表结构<br/>
4、更新或者新增：判断结构是红黑树还是链表，并按照对应的结构进行遍历，如果找到key一致的就进行更新，如果没找到就在尾部新增一条数据。<br/>
5、转换红黑树：然后判断是否大于8如果大于8就转换成红黑树（对于该结构为链表的时候）

put代码：

```java
    
    public V put(K key, V value) {
        //先进行hash操作
        return putVal(hash(key), key, value, false, true);
    }

    final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        //tab：就是数组，p：是数组上链接的那个链表的首节点，n：是数组的长度，i：是hash取模后的下标
        HashMap.Node<K,V>[] tab; HashMap.Node<K,V> p; int n, i;
        //如果是空的时候就进行初始化
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        //如果要插入的数组下标节点的链表是空的就会创建一个链表
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        //不为空的链表就直接在链表上进行操作
        else {
            HashMap.Node<K,V> e; K k;
            //如果当前的k-v与首节点哈希值和key都相等，赋值p->e，也就是插入的是同一个key就进行更新操作即可
            if (p.hash == hash &&
                    ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
            //结构为红黑树，则按照红黑树的方式进行添加
            else if (p instanceof HashMap.TreeNode)
                e = ((HashMap.TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            //遍历整个链表来找到最后的节点进行增加元素
            else {
                //1。 遍历整个链表
                for (int binCount = 0; ; ++binCount) {
                    //2。 如果是找到了最后的节点还没跳出整个循环则将数据添加到尾节点上，即next==null
                    if ((e = p.next) == null) {
                        //3。 创建新的节点
                        p.next = newNode(hash, key, value, null);
                        //4。 如果链表的长度超过了8（上面是先遍历后+所以这个地方判断是否>=7）将链表转变成红黑树
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            //4。1将链表转变成红黑树
                            treeifyBin(tab, hash);
                        break;
                    }
                    //当前遍历到的节点e的哈希值和key与k-v的相等则退出循环，因为这里只处理新增（一般不会出现这种情况，应该在上面就已经拦截住了）
                    if (e.hash == hash &&
                            ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    //当前节点e不为尾结点，将e->p，继续遍历
                    p = e;
                }
            }
            //处理更新操作，新值换旧值
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
        //如果当前map中包含的k-v键值数超过了阈值threshold则扩容resize
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }
```

结论：

1. 如果链表长度超过8则转换成红黑树：`if (binCount >= TREEIFY_THRESHOLD - 1)  treeifyBin(tab, hash); `
2. 如果数组元素超过阀值则进行扩容；默认值：`(int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY)`即 16*0.75=12；`if (++size > threshold) resize();`
3. 先将key进行hash（(h = key.hashCode()) ^ (h >>> 16)）也就是先将原始值右移16位然后再和原始值进行异或处理，这样做的目的就是为了将16位数字全部参加运算（相当于这个数值是完整的32位操作得出来的）这样可以降低hash冲突的可能性。 ![](https://img2020.cnblogs.com/blog/1162587/202011/1162587-20201113150824675-137769143.png)

![借用大佬的一张流程图](https://img-blog.csdnimg.cn/20181105181728652.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dvc2hpbWF4aWFvMQ==,size_16,color_FFFFFF,t_70)

## Get

Get步骤：
1、hash获取hashCode：和Put一样的Hash规则<br/>
2、使用hashCode获取数组下标<br/>
3、判断其衔接的结构是红黑树还是链表，按照对应的结构进行遍历来比对key值

## Resize

扩容

原理：

两个因素

+ Capcity，及hashMap的当前长度，默认16
+ LoadFactor，负载因子，默认0.75f

这个0.75即插入的数据在hashmap中占用了75%的空间之后就会进行扩容

扩容方式：

> 创建一个新的Entry空数组，长度是原有数组的两倍
> 遍历原有的Entry数组，将所有的Entry重新计算hash到新数组中

为什么要重新hash呢。因为长度变大了，hash值就变了

hash的公式：`index=HashCode(Key)&(Length-1)`

### JDK7

步骤：
1、判断是否超过最大的容量，超过则不能扩容。否则创建一个新数组
2、

### JDK8


# ConcurrentHashMap底层结构分析

我们知道最基础的ConcurrentHashMap和HashMap的区别在于前者是线程安全的。那什么是线程安全，就是多个线程对一个资源或者一个数据进行访问的时候得遵循加锁原则也就是只有上一个访问完成之后才允许下一个访问

<font color="red">**Java7**</font>及其之前：

![](https://img-blog.csdnimg.cn/img_convert/5cd777c30769ab49c24de982c53d0af9.png)

其中有一个Segment的概念，使用分段锁的概念（一个Segment就是一个分段锁，一个线程访问一个Segment的时候不会影响到其他的Segment的操作）



<font color="red">**Java8**</font>之后：

1. 加锁范围尽量的小，抛弃了Segment的概念而采用**CAS + synchronized**来保证线程安全（之前segment的时候需要两次定位，先定位segment再定位index。8之后只需要一次定位）
2. 也和HashMap的优化一样增加了红黑树来协助取数据链表的速度慢的问题
3. 扩容
4. 将原本的HashEntry 改为 Node。其中的val next 都用了 volatile

# 4. hashMap的默认初始化长度为什么是16

```java
源码:
    static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // aka 16
    默认初始化容量
    1 << 4相当于位运算，及1*2的4次方
```

1. 这里是位运算，首先需要是2的幂次方，为了使扩容之后原有的key对应的code的index转换二进制的时候，只有最左边新增了一个1，这样可以
2. 为什么选择16呢，因为在使用不是2的幂的数字的时候，Length-1的值是所有二进制位全为1，这种情况下，index的结果等同于HashCode后几位的值。只要输入的HashCode本身分布均匀，Hash算法的结果就是均匀的。

hashMap的值在put的时候才会分配内存空间。如果toSize<16分配的内存空间是16。大于则按照2的幂次方往上累加


# 问题

1、简述Jdk8和Jdk7的hashMap的区别
2、简述Put步骤和Get的步骤
3、简述扩容的机制和步骤
4、扩容后数据位置

- HashMap的底层数据结构？
- HashMap的存取原理？
- Java7和Java8的区别？
- 为啥会线程不安全？
- 有什么线程安全的类代替么?
- 默认初始化大小是多少？为啥是这么多？为啥大小都是2的幂？
- HashMap的扩容方式？负载因子是多少？为什是这么多？

- HashMap的主要参数都有哪些？
- HashMap是怎么处理hash碰撞的？
- hash的计算规则？

# 学习自以下大佬，支持原创

1. [HashMap](https://blog.csdn.net/woshimaxiao1/article/details/83661464)
2. [ConcurrentHashMap](https://www.cnblogs.com/jajian/p/10385377.html)
3. [HashMap](https://www.cnblogs.com/jajian/p/13965678.html)
4. [ConcurrentHashMap](https://blog.csdn.net/weixin_44460333/article/details/86770169)



# 面试题

## 1. HashMap的工作原理是什么?

使用数组和链表来存储数据，当链表长度超过8的时候就会转换成红黑树。在存储的时候首先使用hashcode进行取模获得索引值。如果发生碰撞就使用equals来判断是否与之相等

HashMap采用Entry数组来存储key-value对，每一个键值对组成了一个Entry实体，Entry类实际上是一个单向的链表结构，它具有Next指针，可以连接下一个Entry实体。 只是在JDK1.8中，链表长度大于8的时候，链表会转成红黑树。为6转换成链表

### 1.2 为什么用数组+链表？

数组是用来确定桶的位置，利用元素的key的hash值对数组长度取模得到. 
链表是用来解决hash冲突问题，当出现hash值一样的情形，就在数组上的对应位置形成一条链表。


## 2. <font color="red">为什么数组大小（桶）需要是2的幂次方</font>

1. 由于hashMap是用数组和链表一起来存储某个数值的
2. 为了能够更快的取得数值，所以我们希望能够将各种数据均匀的分布，也就是每个链表只存储一个元素
3. 所以为了能够每个元素均匀分布，所以就可以使用取模的方式来存储到对应的数组中
4. 但是如果直接使用hash&数组长度--->产生问题，效率很低而且无法处理负数
5. 为了解决效率问题。所以就使用下面的方式来取模`hash&(length-1);`
6. **只有length是2^n时，减去一才能获取全部都是1，取模一个全部都是1。这样效率就很快了**

<font color="yellow">总结</font>：

为了解决均匀分布，以及效率的问题。所以使用`hash&(length-1)`的方式来计算应该的**数组下标**，只有length为2^n时，才能使对应的二进制都是1，才能使效率大大加快

## 3. 如果两个键hashcode相同，如何找到对应的对象

1. 首先使用`hashcode`找到对应的`bucket`
2. 然后使用`equals`方法找到链表上对应的元素


## 4. 扩容，what扩容，why扩容，when扩容，how扩容

1. hashmap是有数组和链表组成的，但是一般为了提升效率，所以将存储的值均匀分布，也就是保证一个链表上只有一个值。当数组达到上限的时候，就需要**增大数组容量**。这个过程就是扩容

2. 为了能提高查询效率，也为了能够存储更多的数据

3. 一般在元素个数到达（数据大小*负载因子）的时候扩容

4. 按照2^n扩容

注：

1. 扩容会带来的问题是resize
2. 负载因子就是loadFactor，默认是0.75。在创建对象的时候可以传入


## 5. HashMap的put过程

1. 使用key的hashCode()做hash运算，计算出index。
2. 如果index没有碰撞，就放到数组中，如果碰撞，就放到对应的哈希桶中
3. 如果对应的链表过长（大于等于TREEIFY_THRESHOLD），就将链表转换成红黑树
4. 如果节点已经存在，或者数组满了，就resize

## 6. HashMap的get过程

1. 使用key的hashCode()做hash运算，计算出index
2. 使用index在数组中查找，如果链表的第一个值直接命中，就直接返回
3. 如果有冲突，就使用key.equals(k)去做对比，找出对应链表中的那个值
4. 若为树，O(logn)。若为链表，O(n)。


## 7. hash算法的目的

将一个大范围映射成一个小范围

为了减少空间消耗，使数据更容易保存

比较有名的MD5使用的就是hash算法

## 8. 为什么HashMap的链表超过8就变成红黑树（为6退化）

红黑树的平均查找长度是log(n)，长度为8，平均查找长度是3，如果继续使用的话，平均查找长度就变成了4
桶的长度超过8的概率是非常小的，我想，加入红黑树的其中一个主要原因是为了防止恶意使用带来的性能骤降。作者根据概率统计而选择了8作为阀值，由此可见，将阈值定为8这个选择是非常严谨和科学的一个决定。

## 9. jdk8中的hashmap有什么改进

1. 由原本的`数组+链表`结构转换成了`数组+链表+红黑树`
2. 优化了高位运算的hash算法
3. 扩容后，元素要么是在原位置，要么是在原位置再移动2次幂的位置，且**链表顺序不变**（解决了之前说的resize导致死循环的问题）

## 10. 为什么不直接使用红黑树而是先使用链表，在超过8的时候再转换成红黑树

因为红黑树的实现其实比链表要消耗资源（左旋，右旋，变色等）。在元素小于8的时候，其实使用链表比使用红黑树更经济

## 11. 为什么非要使用红黑树而不使用二叉树

二叉树在一定的情况下会转换成线性结构（直线）

## 12. HashMap的并发问题

产生原因，hashMap并不是线程安全的。所以在并发的情况下可能会出现多个线程同时使用同一个数据。这样就有可能会出现一个数据被修改的时候另一个线程也在修改。这就导致不一致的问题

解决方案：使用HashTable或者ConCurrentHashMap这种线程安全的实现类。还有`vector`

## 13. 什么作为HashMap的key

key可以为空，计算结果index表示放在HashMap的数组的第一个位置

一般使用Integer或者**String**，后者使用更多

## 14. 自己实现一个HashMap

```java
 static class Entry<K,V> implements Map.Entry<K,V> {
         final K key;
         V value;
         Entry<K,V> next;
         int hash;
}
```

## 15. 为什么右移16位进行异或运算

因为后面需要将这个hashcode与map的大小进行与运算来获取其下标地址。但是map的大小一般不会很大，所以一般只会与hashcode的后面几位进行运算。为了降低这个后面几位的重复出现的情况进行了上面的操作

## 16. Map的哪种遍历方式效率最高

Iterator方式效率最高

```java
 public static void main(String[] args) {
        HashMap<String, String> map = new HashMap<String, String>();
        map.put("aaa", "111");
        map.put("bbb", "222");
        map.put("ccc", "333");
        //使用迭代器遍历Map
        Iterator<Map.Entry<String, String>> iter = map.entrySet().iterator();
        while (iter.hasNext()) {
            Map.Entry<String, String> entry = iter.next();
            System.out.println(entry.getKey() + "\t" + entry.getValue());
        }
    }

```

还有其他遍历方式

> keySet()：`for (String key : map.keySet())`
>
> Entry：`for (Map.Entry<String, String> entry : map.entrySet())`

迭代器的遍历方式，在所有集合类型中都有。包括ArrayList