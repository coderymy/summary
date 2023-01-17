# **如何理解基础数据类型还是引用数据类型**

基础数据类型中对应的内存空间储存的是具体的值

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/GN1CL3.jpg)

引用数据类型中对应的内存空间存储的是new对象的地址

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/EGgrxw.jpg)





# **如何理解引用和对象**

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/wCAGAI.jpg)

引用还是存储的是地址，new对象是本体。



# **如何理解局部变量成员变量以及静态变量**

成员变量在堆上

局部变量在栈上

静态变量在方法区中

```java
public class Test01 {
    //成员变量
    Test01 t1=new Test01();
    //静态变量
    static Test01 t2=new Test01();
    public static void main(String[] args) {
        //局部变量
        Test01 t3=new Test01();
    }
}
```

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/6S2PIt.jpg)

# GC

## GC回收的特点

GC中主要回收的是**堆和方法区**中的内存，栈中内存的释放要等到线程结束或者是栈帧被销毁，而程序计数器中存储的是地址不需要进行释放。

**回收对象的基本单位：**

对于GC中回收的基本单位不是字节而是**对象**

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/mXKopM.jpg)

GC回收的一般是已经不使用的位置的内存

**回收对象的基本思路：**

**1）标记：找到这个对象是否需要回收，并且标记出来**

**2）回收：将这个对象回收回去**

## 标记

1）引用计数法

每个对象都会分配一个专门的计数器变量当有一个新的引用指向这个变量的时候计数器就会加一，当有一个引用不指向这个变量计数器就会减一，当引用计数器为0时就会让这个对象标记回收。

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/CXng5n.jpg)

但是这就引用出**循环引用**问题不能解决：

想要使用对象a，找到a的引用，这个引用在对象b中，想找对象b的引用在a中

2）可达性分析
在java中GC采用可达性分析来描述

代码中的对象之间是有一定的关联的，他们构成的一个“有向图”，然后我们去遍历这个“有向图”如果对象遍历的到就不是垃圾，反之就是垃圾。

一般从什么地方开始遍历？

1、每个栈中栈帧的局部变量表

2、常量池中引用的对象

3、方法区中静态变量引用的对象

遍历的时候不是像二叉树一样从一个地方开始遍历，而是从多个地方遍历，这样的我们统称为GCRoot。

3）方法区类对象的回收规则

1、该类的所有实例都已经被回收

2、加载该类的ClassLoader也已经被回收了

3、该类对象没有在代码中使用

## 引用的类型

+ 强引用：只要强引用的关系还存在，那么垃圾回收器就永远不会回收掉这中引用对应的对象。百分之九十九

+ 软引用（内存不够才会回收）：用来描述一些还有用，但并非必须的对象。这种对象会在OOM之前的GC回收的时候被回收掉。jdk1.2之后使用`SoftReference`类创建

+ 弱引用（内存足够也会回收）：描述非必须的对象，这种对象会直接被下一次的垃圾回收回收掉。也就是说无论内存是否足够都会被回收。jdk1.2之后使用`WeakReference`类创建

+ 虚引用：这是一种比较特殊的存在，他的目的是**能在这个对象被收集器回收的时候收到一个系统通知**。jdk1.2之后使用`PhantomReference`类创建

## 回收

1）标记清除

![img](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/ieaJuT.jpg)

 标记清除指的是直接释放将标记的区域中的内存释放

**优点：简单高效**

**缺点：容易造成内存的碎片问题**

2）标记复制

![img](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/KbzP0T.jpg)

将内存划分为两个区域直接拷贝不是垃圾的对象放到另一个区域

**优点：可以很好的解决内存的碎片问题，不会存在碎片**

**缺点： 需要额外的内存空间（如果生存的对象比较多这时就比较低效）**

3）标记整理

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/uqu4ey.jpg)

类似于数组删除数据

**优点：不想复制一样需要额外的内存空间也没有内存碎片**

**缺点：搬运的效率较低不适合频繁使用**

## 分代回收

年轻代：使用复制算法，效率高，同时使用survivor来缓解内存浪费的情况

老年代：标记清除和标记整理的混合使用。也就是通常使用标记—清除，一段时间之后使用标记—整理算法

CMS回收器：使用标记清除来实现。当内存回收不佳（碎片空间导致 ）则使用Serial Old执行Full GC来运行标记整理

为了解决每种回收算法的侧重点不同，所以将对的内存空间分为新生代和老年代两种，然后针对这两种使用不同的回收算法

新生代内存回收：复制算法

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/新生代垃圾回收.drawio.png)

老年代回收：标记清除算法，时间长了使用一次标记整理算法来解决内存碎片化问题

**新生代->老年代**每次回收针对未回收的对象进行记录，一旦记录次数到达阀值就会将新生代的未回收对象引用转移到老年代中。

## 垃圾回收器的介绍

回收情况不同：

只能回收新生代：Serial（串行） 、Parallel（并行） Scavenge 、ParNew （并行）

只能回收老年代：Serial Old 、Parallel Old 、CMS（并发） 

都可以：G1（并发）

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/9fLp6n.jpg)



不同垃圾回收器组合关系



![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/0d713Z.jpg)





|          | Serial                                              | Serial Old                                                   | ParNew                                                       | Parallel Scavenge                                            | Parallel Old                                                 | CMS            |
| -------- | --------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | -------------- |
| 特点     | 1、串行<br>2、单线程单核                            | 1、串行<br/>2、单线程单核                                    | 1、并行<br>2、多线程<br>3、par是parallel缩写，new指只回收新生代 | 1、并行<br>2、自适应调节策略                                 |                                                              | 面向停顿时间   |
| 回收算法 | 复制算法                                            | 标记整理算法                                                 | 复制算法                                                     | 复制算法                                                     | 标记整理                                                     | 标记清除       |
| 回收范围 | 新生代                                              | 老年代                                                       | 新生代                                                       | 新生代                                                       | 老年代                                                       | 老年代         |
| 使用情况 | 目前针对一些单CPU使用（嵌入式设备）                 | 单CPU使用、server模式下与CMS配合作为补充使用（CMS是标记清除算法，隔一段时间需要标记整理一下） | 针对多CPU比Serial好写，单CPU不如Serial                       | parallel相对于ParNew<br>1、Parallel目标是达到可控制的吞吐量<br>2、自适应调节策略<br>3、吞吐量优先 | JDK1.6                                                       |                |
| 配置方式 | `-XX:+UseSerialGC`                                  | `-XX:+UseSerialGC`                                           | 启动：`-XX:+UseParNewGC`<br>限制线程数量：`-XX:ParallelGCThreads` | 1、JDK8中默认`-XX:+UseParallelGC`<br>2、`-XX:ParallelThreads`设置并行收集器的线程数（CPU>8则`3+(5*CPU_COUNT)/8`）<br>3、`-XX:MaxGCPauseMillis`设置最大停顿时间<br>4、`-XX:GCTimeRatio`垃圾收集占总时间的比例<br>5、`-XX:+UseAdaptiveSizePolicy`自适应调节策略 | JDK8中默认`-XX:+UseParallelOldGC`与UseParallelGC互相激活<br> |                |
| 优点     | 简单高效（相对于单CPU其他垃圾回收器）               | 简单高效（相对于单CPU其他垃圾回收器）                        | 相对于单线程来说STW暂停时间稍短一些                          | 自适应调节<br>基于吞吐量优先                                 | 并行执行性能更好<br>补充了Parallel Scavenge的老年代回收      | 标记整理的优点 |
| 问题     | 串行执行导致STW时间较长。一般BS模式不会使用该收集器 | 串行执行导致STW时间较长。一般BS模式不会使用该收集器          |                                                              |                                                              |                                                              | 标记整理的缺点 |
| 使用场景 | 最小化的使用内存和并行的开销                        | 最小化的使用内存和并行的开销                                 |                                                              | 注重吞吐量                                                   | 注重吞吐量                                                   | 注重停顿时间   |

CMS：Concurrent-Mark-Sweap，并发标记清除。

+ 针对停顿时间
+ 回收线程和用户线程同时工作
+ 并发标记清除
+ B/S使用较多
+ 老年代

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/hNpvy4.jpg)

1. 初始标记（STW）但是时间短。

   标记出GCRoots**直接关联**的对象

2. 并发标记

   从GCRoots出发遍历关联到的所有对象

3. 重新标记（STW）

   修正并发标记期间产生变化的对象的标记记录（这个时候产生变动的对象不多）

4. 并发清理

   清除算法，也就是只是记录一个内存空闲列表

**弊端**

1. 由于是并发清理，所以CMS不能等到没有内存了再去回收，因为执行期间**需要拥有空闲内存给用户线程使用**。如果出现执行期间没有足够内存给用户使用，就会抛出`Cocurrent Mode Failure`这时就会启动Serial Old来进行垃圾回收，停顿时间就很长了
2. 产生碎片化内存空间。会导致提前触发Full GC。触发会使用Serial 这种性能较低的
3. 对CPU资源很敏感，虽然并发阶段不会停顿，但是对CPU有功能消耗，所以这个时候必然其他线程还是有一定影响的
4. 标记的不完整

JDK9的时候标记为Deprecate。JDK14删除了CMS

CMS：低延时

Parallel+Parallel Old：高吞吐量



# 类加载器

## 类加载的基本过程

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/类加载流程.drawio.png)



## 什么时候触发类加载

**1）构造该类的实例**

**2）调用该类的静态属性和静态方法**

**3）使用子类时会触发父类的加载**

## 常见的类加载器

1. 启动类加载器（**BootStrap** classLoader）：最底层的加载器，加载/jre/lib/rt.jar和charset.jar包下的class文件。
2. 扩展类加载器（Extension classLoader）：可以支持一些扩展的拦截类，加载/jre/lib/ext下的class文件。
3. 应用（系统）类加载器（System/Application classLoader）：也就是加载我们日常写的Class文件。
4. 自定义类加载器（Custome ClassLoader）

所有加载加载器的加载器都是BootStrap加载器，也就是说这四者之间并不是父子关系的

bootstrap是C++语言执行的加载操作（Native接口）Java是获取不到的



## 双亲委派模型

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/四个类加载器实现流程.drawio.png)



是什么：进行类加载操作的时候，先让父加载器进行加载，只有父加载器不能加载才进行加载，也就是从上至下进行加载

目的：保证内置java类的安全。如果用户无意中创建了一个同样名称同样路径的类，那么没有双亲委派就会倾入损害jvm的基本功能了（当然有意的就另当别论）

**检查缓存是否加载过顺序**是：Application->Extension->BootStrap

**加载顺序**是：BootStrap->Extension->Application

 当一个类开始加载时，会先从AppClassLoader开始，但是它不会立刻查找会先交给自己的父类，ExtClassLoader也会交给自己的父类，然后BootstrapClassLoader拿到类名之后在rt.jar中开始查找，找到就返回，没找到就会在ExtClassLoader中的ext目录中开始查找，找到就返回，没有找到就会在AppClassLoader中的CLASS——PATH环境变量中、-cp指定目录中、当前目录中三个地方去查找，如果找到就加载，没有找到就抛出一个ClassNotFoundException异常。





