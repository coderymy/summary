# jvm的3W1H
# 0. 前言

W：why，为什么需要垃圾回收

W：what，垃圾回收什么

W：when，在什么时候回收

H：how，如何回收



# 1. what to 回收

前言：首先明确一点，垃圾回收针对的是堆和方法区中的内存，也就是主要针对的是**对象**进行内存回收

为什么不回收其它三个内存区域（虚拟机栈，本地方法栈，程序计数器）呢？

因为他们三个是线程私有的，会跟随线程的创建而创建，线程结束而被销毁

正题：那么第一点，怎么判断哪些对象需要回收呢?

这也就是我们说的，如何判断哪些对象还是“存活”，哪些对象是“已死”

这里主要使用两种算法

## 1.1 引用计数算法

算法的执行机制：（一般的可以这么理解，别人问你，也可以这么说）

> 给对象中添加一个引用计数器，每当一个地方引用它的时候，计数器就加一；每当引用失效的时候，计数器就减一。任何时候计数器为零的对象就是不可能再被使用的。也就是最后一次引用也已经失效了。所以这个时候就可以回收这个对象

但是一般来说虚拟机不使用这种算法进行对象是否需要垃圾回收作为判断

## 1.2 可达性分析法

算法实现机制：

> 通过一系列被称为“GCRoots”的对象作为起始点，从这些对象向下进行搜索，搜索所走的路径叫做引用链。当一个对象没有可以到达“GCRoots”的引用链，就可以认定这个对象是需要进行垃圾回收的

![4e220744e8bad48341a4232b1ddc0743.png](en-resource://database/4193:0)

## 1.3 综上所述

无论是引用计数算法还是可达性分析法，究其根本都是对`引用`进行判断。也就是说，一个对象是否存活，直接因素就是他的引用所代表的。所以java为了能更好的使用垃圾回收的机制，就希望能有这样的引用：当内存够的时候，可以保存在内存中；当内存不够的时候也可以将一些不是很重要的回收，而保留一些重要的

jdk1.2就增加了上述的使用方法，提出了四个引用形式

> 强引用：只要强引用还存在，那么垃圾回收器就永远不会回收掉这中引用对应的对象
>
> 软引用：用来描述一些还有用，但并非必须的对象。这种对象会在内存溢出异常之前，也就是第二次回收的时候被回收掉。jdk1.2之后使用`SoftReference`类创建
>
> 弱引用：描述非必须的对象，这种对象会直接被下一次的垃圾回收回收掉。也就是说无论内存是否足够都会被回收。jdk1.2之后使用`WeakReference`类创建
>
> 虚引用：这是一种比较特殊的存在，他的目的是**能在这个对象被收集器回收的时候收到一个系统通知**。jdk1.2之后使用`PhantomReference`类创建

我们一般创建的引用都是强引用。所以也就是说，只有这个引用不存在的时候才会被回收

## 1.4 方法区的回收

一般认为方法区是没有垃圾收集的。在java虚拟机规范中也明确的说明可以不要求也虚拟机在方法区进行垃圾收集。而且在方法区进行垃圾收集的“性价比”很低，所以也就没必要了

下面也不再赘述这部分内容



# 2. When to 回收

虚拟机使用的都是可达性分析法来判断是否对象"已死亡"，但是这个时候并没有到这个对象“非死不可”的地步。一般对象“非死不可”都需要两次标记。

1. 第一次标记就是可达性分析法判定这个引用没有对应的引用链。标记之后会进行一次筛选，筛选的条件如下

   1.对象是否覆盖finalize()方法

   2.finalize()方法已经被虚拟机调用过

   当满足上述两个条件的时候，就会认定这个对象“没有必要执行”。如果认定“有必要执行”，那么就会进入下一个阶段

2. 对象会被放在`F-Queue`队列中，这个队列会被`Finalizer`线程执行，执行期间会进行第二次标记。如果在执行之前，这个引用有连接上任何引用链，那么就可以不被标记。也就可以不用再面临死亡（当然我这里为了方便理解省略了一些执行流程，但是大体就是这么回事）。如果被标记了，那么就会真正的执行“死亡流程”



# 3. How to 回收

## 3.1 使用垃圾收集算法

### 3.1.1 标记--清除算法

实现机制

> 首先标记出所有需要回收的对象，在标记完成之后统一回收所有被标记的对象

缺点

> 1. 效率很低，标记和清除的效率都很低
> 2. 会产生大量的不连续的空间碎片，这样在之后创建大对象的时候，会出现无法分配空间的情况

![9c410213b686456c6ab185ba72e63812.png](en-resource://database/4195:0)

### 3.1.2 复制算法

实现机制

> 1. 将内存分成两块，只是用其中一块进行对象创建
> 2. 在需要进行回收的时候，将存活对象复制到另一块内存上，然后将本来的那一块全部清除

优缺点

> 优点：1. 不会产生内存碎片的问题
>
> 2. 效率会高一点
>
> 缺点：这样内存的可使用大小就降低成原来的一半，而且在存活率较高的时候，复制操作就比较吃亏了

注

> 现在商业虚拟机都是用这种方法回收新生代。
>
> 将内存分为三部分，Eden，Survivor，Survivor。占比是8:1:1
>
> 一般只使用Eden和一块Survivor空间，在进行回收的时候，将所有存活的对象复制到另一块Survivor上。这样在下一次使用内存的时候，就使用这块Survivor和Eden继续创建对象
>
> 如何出现Survivor内存不够用，可以进行老年代的分配担保

![0ed581f95116ee21f1980dc4171d6041.png](en-resource://database/4197:0)

### 3.1.3 标记--整理算法

实现机制

> 和标记--清除基本一样，只是并不是直接清除，而是将存活的对象都向一边移动，这样清除的时候就可以防止出现内存碎片化的问题
> ![2a3a48f01dcb5a51b1fe2f42bd8b505d.png](en-resource://database/652:1)



### 3.1.4 分代收集算法

现在的商业虚拟机的垃圾收集都采用“分代收集“算法。

实现机制

> 根据对象的存活周期的不同将内存划分成几块，一般将java堆分成新生代和老年代。这样就可以根据各个年代的特点采用最适当的收集算法。
>
> 新生代，由于每次都是大部分对象死去，少量存活，所以使用复制算法
>
> 老年代，对象存活率较高，所以使用“标记--清除”或者“标记--整理”



## 3.2 垃圾收集器（回收的具体体现）

这里垃圾收集器的种类有很多（Serial收集器，ParNew收集器，Parallel Scavenge收集器，Serial Old收集器，Parallel Old收集器，CMS收集器，G1收集器），我们只详解两种使用很多的垃圾收集器

1. CMS收集器
2. G1收集器

现在的商界版本，一般来说这两种收集器都可以，但是如果你目的是比较单一的追求低停顿，那么可以选择使用G1收集器

### 3.2.1 CMS收集器

目标：获取最短回收停顿时间

使用场景：目前大部分javaWeb项目，以性能为主，就要求服务的响应速度。所以这里就希望系统停顿时间短。这就附合了需求

实现机制

> 基于**标记--清除算法**
>
> 四步骤
>
> 1. 初始标记
> 2. 并发标记
> 3. 重新标记
> 4. 并发清除
>
> 初始标记：就是使用标记一些可达性分析确定可以回收的对象内存
>
> 并发标记：就是进行`GCRoots Tracing`的过程。这个时间会有些长
>
> 重新标记：就是针对并发标记期间有可能产生（用户产生的其它可达性分析认为可以标记的内存）的对象
>
> 并发清除：就是做清除。时间也比较长
>
> ![70fe9d6f3c81a7f40b43dd5ea6073a08.png](en-resource://database/653:1)
>
> 由于时间消耗比较长的**并发标记**和**并发清除**都可以和用户的操作并发执行。所以可以认为整个操作和用户线程是并发的

优点：并发收集，低停顿

缺点

> 1. 对CPU资源非常敏感（面向并发设计都敏感）
> 2. 无法处理浮动垃圾
> 3. 基于“标记--清除算法”，所以会产生内存碎片



### 3.2.2 G1收集器

优点

> 1. 并行和并发：利用计算机多核的特性，大大降低停顿时间。可以做到和java程序并发执行
> 2. 分代收集：也就是上面说的分代收集的算法
> 3. 空间整合：优化了CMS中内存碎片化的问题
> 4. 可预测的停顿：可以让使用者明确指定在某个时间片段M内，消耗N毫秒进行垃圾回收

特点

> 不再是以前的新生代和老年代的概念
>
> 现在是将整个java堆划分成多个大小相等的独立区域（Region），然后新生代和老年代各占一部分的Region，而不是之前的物理隔离
>
> 这也是为什么G1可以进行预测的原因

执行机制

> 初始标记：只是标记一下GCRoots能直接关联到的对象，需要停顿线程，耗时很短
>
> 并发标记：找出存活的对象，耗时很长，可与用户程序并发执行
>
> 最终标记：也和CMS中的重复标记一个道理，都是检查是不是有更新
>
> 筛选回收：这里比较重要，也是实现可预测停顿的重点。首先对各个Region的回收价值和成本进行排序，再根据用户期望的GC停顿时间来指定回收计划。虽然耗时很长，但是可以与用户程序并发执行
>
> 所以基本上可以实现和用户程序的并发执行
> ![78b685d05d40fef992258c6b84c5a90a.png](en-resource://database/654:1)