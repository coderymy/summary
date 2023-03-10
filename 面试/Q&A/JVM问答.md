# GC

## 问题一：垃圾回收的时候如何实现扫描所有对象这个操作？

## 问题二：所有被创建的对象存在什么地方？

## 问题三：每次GC需要扫描整个堆嘛？

知识储备：（详解还是要看JVM篇章）

一、垃圾回收大致分为三大类别

|          | MinorGC            | MajorGC                      | FullGC                                                       |
| -------- | ------------------ | ---------------------------- | ------------------------------------------------------------ |
| 触发条件 | Eden满了           | 老年代满了                   | 1、OOM之前<br>2、System.gc()<br>3、老年代空间不足（大对象）<br>4、方法区（永久代）空间不足(后来使用matespace替换永久代之后就不会出现这种情况) |
| 作用空间 | 年轻代（复制算法） | 老年代（标记清除，标记整理） | 全堆空间                                                     |
| ...      | ...                | ...                          | ...                                                          |

二、可达性分析法的实现过程

1. 确定GCRoots。一般包含以下几个重要成分可能作为GCRoots
   1. 虚拟机栈和本地方法栈中引用的对象
   2. 堆中的字符串常量池和静态变量
   3. 。。。
2. 从GCRoots开始遍历整个引用链，并将其标记为可存活。之后回收其他未被标记的即可

三、一个对象在堆的各个代中的流转过程（特殊情况除外：大对象等）

1. 对象创建之初一般在年轻代的Eden区
2. 当Eden满了之后触发MinorGC来将Eden和From区中可活对象放入To区。如果满了放入老年代。如果From中对象生存周期超过阀值则放入老年代
3. 然后调转From区和To区的定义
4. 如果遇到老年代空间满了就进行一次MajorGC。如果MajorGC之后还是不足就触发FullGC

问题一：根据不同的GC方式，扫描的区域也不同，也区别于不同的垃圾收集器。

+ Parallel：严格的年轻代和老年代，在回收的时候扫描固定区域
+ G1：针对分区算法，以及启动时配置的参数来跟踪并计算，在这个不超过最大时间间隔内回收哪些区的空间能做到最优。

问题二：一般对象创建之后就会出现在Eden区域，但是对于一些字符串常量、静态变量，则会出现在堆空间的字符串常量池中（字符串常量池是在JDK7之后才在堆中的）。对于一些Eden中存放不在的大对象可能会出现在老年代，此间可能会触发FullGC等情况

问题三：根据上述知识储备，不同的GC方式和不同的垃圾收集器，扫描的地方是不一样的，具体可以看知识储备。



# 类加载过程

类加载的时机：任何用到这个类的时候，比如new对象、反射该类、调用类的静态方法

流程其实和我们开发的时候的写代码顺序是一样的

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/类加载流程.drawio.png)





# 类加载器分类

1. 启动类加载器（**BootStrap** classLoader）：最底层的加载器，加载/jre/lib/rt.jar和charset.jar包下的class文件。
2. 扩展类加载器（Extension classLoader）：可以支持一些扩展的拦截类，加载/jre/lib/ext下的class文件。
3. 应用（系统）类加载器（System/Application classLoader）：也就是加载我们日常写的Class文件。
4. 自定义类加载器（Custome ClassLoader）

所有加载加载器的加载器都是BootStrap加载器，也就是说这四者之间并不是父子关系的

bootstrap是C++语言执行的加载操作（Native接口）Java是获取不到的



# 什么是双亲委派机制

（从子到父，从父到子的过程。双向亲属委派）

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/四个类加载器实现流程.drawio.png)

是什么：进行类加载操作的时候，先让父加载器进行加载，只有父加载器不能加载才进行加载，也就是从上至下进行加载

目的：保证内置java类的安全。如果用户无意中创建了一个同样名称同样路径的类，那么没有双亲委派就会倾入损害jvm的基本功能了（当然有意的就另当别论）

**检查缓存是否加载过顺序**是：Application->Extension->BootStrap

**加载顺序**是：BootStrap->Extension->Application

如果有同样的路径同样的命名的class文件，会按照这个顺序来执行

1. 类加载器接收到加载请求
2. 类加载器向上委托到父类进行父类加载器加载一些父类。循环往复，直到到跟加载器（BootStrap）
3. 启动类加载器会检查是否能够加载当前这个类。能加载就结束并使用当前的加载器加载，否则抛出异常通知子类进行加载。循环往复直到最后报错“Class Not Found”（我们idea也是能写出来没有继承的类的，只是idea会报错来提示我们，在没有idea的时候这种操作会很频繁发生）

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/iCni7P.png)











# 什么是懒加载

jvm虚拟机中对类的加载是只有用到某个类的时候才会进行这个类的加载

懒加载时机：

+ new/访问静态实例/访问静态方法时，访问final变量
+ 反射时
+ 初始化子类，父类先初始化
+ 虚拟机启动，被执行的主类初始化
+ xxx

# 简述运行时数据区



执行引擎使用运行时数据区中的数据来将其翻译成机器指令，CPU解释执行，最后进行内存的回收

就像是做饭的时候厨师（执行引擎）使用厨台上（运行时数据区）的各种蔬菜鱼肉（数据）做成饭菜，最后还需要清理厨台（GC）

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/jvm1.png)



|            | 虚拟机栈                                                     | 本地方法栈                               | 程序计数器                                         | 堆                                                           | 方法区                                                       |
| ---------- | ------------------------------------------------------------ | ---------------------------------------- | -------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 是什么     | 是程序运行的基石                                             | 与虚拟机栈一样只是存储的是本地native方法 | 用来指引方法的执行                                 | 存放各种对象实例                                             | 从堆中拆分出来的结构                                         |
| 存的是什么 | 栈帧： <br/>1. 局部变量表<br>2. 操作数栈<br>3. 动态链接<br>4. 方法出口 | 与栈一样，只是存储的是专属于Native方法   | 存储下一条指令的地址（辅助执行引擎确定下一条指令） | 对象的实例、数组等结构                                       | 类的元数据、常量、静态变量、JIT后的代码和数据                |
|            | ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/虚拟机栈结构.drawio.png) |                                          |                                                    | ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/年轻代和老年代1.png) | ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/堆、方法区和栈的关系.drawio.png) |
|            | ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/虚拟机栈.drawio.png) |                                          |                                                    | ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/f8Wq8h.jpg) | ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/eAdpxS.png) |
|            |                                                              |                                          |                                                    |                                                              |                                                              |

## 类加载

### 类加载_不同的类加载器有什么区别

读取二进制流的动作和范围不一样

后续的加载逻辑是一样的。所以如果你非要用extension classloader加载自己写的class文件也是没有问题的，但是不建议

### 类加载_为什么要违背双亲委派机制

一些业务需要，比如

JDBC：连接数据库的Driver接口的定义是在jdk中的jre/lib/rt.jar，这个是由BootStrap进行类加载的。但是jdbc针对每个类型的数据库提供的jar文件和连接逻辑都不一样，所以需要自己实现。所以就不能让BootStrap去加载，而是由自定义的类加载器去加载。所以JDBC的出现就是违背了双亲委派机制。

Tomcat：



### 类加载_如何打破双亲委派模型

简而言之就是如何让本该bootstrap/extension classloader加载的类不让他们加载而让自定义的类加载器加载/application classloader加载

**jdbc**：jdk自带的lib/rt.jar/Driver.class进行的数据库连接，但是我们通常时候需要扩展这个类的方法来适配不同的厂商数据库（mysql/oracle/h2等）所以这个时候就不能主动的让bootstrap加载器加载了，就需要我们自己指定Application Classloader加载器加载这个Driver从而实现在我们的classpath中获取需要访问的静态资源文件（也就是对应的厂商jar文件）。

只需要使用`ServiceLoader.load(需要违背的类)`就可以让他使用当前的上下文对象去加载这个`需要违背的类`

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/PbaG2p.png)

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/f7GEGt.png)



### 类加载_什么时候不遵守双亲委派机制

实现热插拔，热部署等操作。只需要将这个模块和对应的类加载器一起换掉就好了



### 类加载_什么是SPI

Service Provider Interface，服务发现机制

Java实现的SPI就是去扫描classPath路径下的META-INF/services文件夹中的文件。

如何使用：

我们是去调用某个接口，具体的接口实现类我们通过导入的jar来决定，比如我们是调用Driver去创建数据库的连接，那么这个数据库连接的具体实现方式是通过我们导入的mysql-connect.jar文件来实现的

实现步骤：

1. 在META-INF下创建services文件夹，在这个文件夹中创建全路径的接口类的文件
2. 在该文件中写入具体服务类的全限命名
3. 将该项目打包成一个jar文件导入其他项目就好了。
4. 导入该jar的项目会在项目启动时扫描所有的jar文件的META-INF来查看是否有需要实现的实现类



举例子：

1. JDBC的具体数据库服务提供的jar
2. SpringBoot整合各种功能模块只需要导入需要的jar文件即可



### 类加载_热部署原理

热部署就是Java动态的去加载一个文件夹中的class文件的变动来重新加载到项目缓存中

所以用类加载的知识理解就是

1. 某个目录的class文件变动了
2. 类加载器将原本这个class文件的缓存信息删除
3. 类加载器重新加载这个class文件

那么实现方式就变成了

NACOS

1. 实现一个自定义的类加载器
2. 监听文件夹中的类文件的变动情况
3. 自定义的类加载器能根据输入的类删除其原本的缓存信息
4. 重新加载变动的类
5. 一个配置文件能动态的配置这个文件夹中的文件

### 类加载_什么是双亲委派机制、沙箱安全机制

### 类加载_三次破坏双亲委派机制

**<font color="red">第一次</font>**：JDK1.2之前有了ClassLoader的概念，但是没有双亲委派机制。这个时候的开发者如果已经有了一些自定义类加载器的代码就没法去强迫用户修改了。所以就只能妥协承认已出现的代码的破坏行为。

<font color="red">第二次</font>：越基础的类使用的加载器越上层。但是如果基础的类的实现是由用户编写的代码来实现也就是需要App加载器去加载如何处理呢？例如数据库连接的Driver对象SPI（就是一些接口是由启动类加载器加载，但是实现是需要app加载器加载）。

所以提出了一种**线程上下文加载器**这个加载器不属于任何一种加载器，但是是加载用户代码（所以也可以说是App加载器）。**当SPI接口需要具体的用户代码来实现，启动类加载器就委托线程上下文加载器去调用APP加载器加载用户代码来达到最终启动类加载器能加载SPI接口**（宋老师举例子）

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/第二次破坏双亲委派机制.drawio.png)

<font color="red">第三次</font>：热替换，热部署。每一个代码模块（Bundle）都有自己的类加载器。需要替换这个Bundle，就将其和其类加载器一起替换掉。重新加载的时候就不是从上至下的委托加载而是平行结构的直接加载。



## 程序计数器

### 程序计数器_为什么使用程序计数器记录执行地址

CPU需要不停的切换各个线程，所以每个线程都需要自己记录到底执行到哪了



## 虚拟机栈

### 虚拟机栈_栈溢出的情况？

方法的循环递归调用，导致栈帧在超过了栈的大小。如果是固定大小超过限制就会抛出StackOverflowError。如果是固定大小但是申请不到内存空间的时候OutOfMeroryError。

通过-Xss来调整虚拟机栈的大小

### 虚拟机栈_垃圾回收是否涉及虚拟机栈？

可以说涉及也可以不涉及。因为本身垃圾回收是针对无用的实例对象进行回收。而虚拟机栈其实是线程私有的，在线程结束的时候就会直接全部销毁掉该块的内存空间。

但是有一种情况可能需要考虑。有一个线程一直在挂着一直没结束运行，这个时候它内部的局部变量表中记录了一会引用数据类型的引用地址。这个时候是会影响到这个对象实例的回收的

需要涉及，因为在虚拟机栈的栈帧中的局部变量表中保存的有引用数据类型的引用。也就是这个实例的根目录，如果有该引用一直存在就会导致该实例对象无法被回收

### 虚拟机栈_方法中定义的局部变量是线程安全的嘛？

什么是线程安全，只有一个线程可以操作此数据，就一定是线程安全的。

看这个局部变量是否会在外部的调用中使用到。如果只是在该方法中使用，每个方法都是一个线程的栈帧，那么就是安全的。如果是作为方法参数或者方法的返回值，那么就可能是不安全的

### 虚拟机栈_栈顶缓存技术

原因：基于栈式架构的虚拟机，频繁的使用入栈出栈操作，所以CPU需要与内存进行频繁的IO操作。

目标：将栈顶的数据缓存在CPU的寄存器中。

## 堆

### 堆_对象的结构



### 堆_为什么生产环境中堆初始内存和最大内存设置成一样的值

为了防止不断的扩容和缩容对CPU造成一定的压力

服务器内存使用的时候，堆空间在系统繁忙时会进行扩容，这个扩容也对生产环境的CPU造成一定的压力，而在空闲时间的时候又需要释放对应的空闲堆内存，这个操作也是对CPU会有一定的压力的

### 堆_如何查看堆空间信息

第一种：在服务器上使用`jps`查看所有正在运行的JVM，然后使用`jstat -gc 进程ID`查看堆的内存信息

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/9SIWD4.png)

第二种：启动jvm的时候使用`-XX:+PrintGCDetails`参数即可在程序结束的时候输出	

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/tGtgtO.png)

### 堆_开发中遇到过什么异常

TODO

### 堆_jvisualvm

安装Visual GC插件，如果网络安装不了查看[大佬博文](http://www.javashuo.com/article/p-ebxflfxw-ru.html)进行离线安装

### 堆_为什么要将堆进行分代

可以不分代，但是分代是为了提高GC的性能。针对不同类型的对象进行不同类型的垃圾回收算法来提升性能，减少对用户线程的影响



### 堆_举例老年代的对象

数据库连接池对象



### 堆_什么是TLAB（私有缓存区域）

解决的问题：堆空间是所有线程共享的，但是这样就出现了**线程安全的问题**（虽然可以使用加锁来解决，但是会影响性能）。所以就在Eden区为每个线程分配了一个**私有缓存区域（TLAB）**

优点：分配首选，线程私有

缺点：空间小



### 堆_介绍下逃逸分析技术

目的：针对GC操作的一种优化，将一些本身是只有在一个方法中才会使用到的对象的分配到栈上，这样就可以在方法结束的时候随着栈的出栈而销毁。而不需要进行GC

优点：

+ **栈上分配**，减少了堆空间的占用，进而减少了GC的次数
+ **同步忽略**，由于分配的是在栈上，所以是线程私有的，所以不需要将这个对象的数据进行同步加锁等操作。
+ **分解标量替换**，将整个的大对象拆分成基础数据类型从而存放在栈的局部变量表中，从而完成栈上分配

缺点：

+ 技术不够成熟，逃逸分析本身需要JIT（即时编译器）消耗性能进行代码的分析。如果分析结果极端发现没有对象需要逃逸，那么这个操作就是多余的
+ HotSpot，使用的是标量替换来完成的栈上空间分配。完美实现只有阿里的自研虚拟机

实践：阿里自研的VM使用的GCIH技术就通过硬件的手段完成对逃逸分析的优化（钱解决了多余的操作）



### 堆_为什么JDK7要将原本放在永久代（方法区）中的字符串常量和静态变量的引用放到了堆空间中？

1. 永久代大小默认较小，字符串常量比较多
2. 永久代垃圾回收频率较低。字符串一般使用过就不用了

## 垃圾收集

### 垃圾收集_各种垃圾收集器的区别和优缺点

 

### 垃圾收集_GC算法有哪些，目前JDK采用哪种

### 垃圾收集_G1回收器讲下回收过程

### 垃圾收集_GC的两种判定方式

### 垃圾收集_CMS收集器和G1的区别



### 垃圾收集_分代回收

### 垃圾收集_如何搭配使用垃圾回收器

### 垃圾收集_回收算法的原理

### 垃圾收集_CMS讲解下

### 垃圾回收_回收停顿

### 垃圾回收_查看默认垃圾回收器

`-XX:+PrintCommandLineFlags`查看命令行相关参数



`jinfo -flag 相关垃圾回收器参数 进程ID`



### 垃圾回收_为什么不使用标记整理算法？

因为在清理的过程中是并发执行的。所以如果进行内存整理势必会和其他线程出现空间抢占的情况，或者说用户线程执行期间找不到原本的对象地址信息了。这样会对其他用户线程造成延时影响

所以说，标记压缩算法，必须在STW的情况下

## 其他

### 静态变量和局部变量的区别

按照数据类型分类：

```
基础数据类型
引用数据类型
```

按照在类中的声明位置分：

```
成员变量
	- 类变量（Static修饰，是类本身具有的属性），在类加载的linking的prepare阶段给类变量赋予初始值。在initial阶段进行赋予具体的值（还有静态代码块进行操作）。	
	- 实例变量（没有static修饰，是实例才有的属性），随着对象的创建，在堆中分配对应实例的内存空间，并进行默认的赋值。
局部变量，在使用前必须进行初始化赋值，否则编译不通过
```

### static{}，{}，普通方法的区别

TODO

### hotSpot的Java8和Java7的区别

**代码逻辑上**



**虚拟机**

1. 堆内存空间将原本的永久代变成了metaSpace
2. 默认开启逃逸分析来优化实例对象分配内存空间到栈上

### 讲一讲字符串常量

`int pre="abc"`表示的就是字符串常量

`int suf=a+"d"`表示的就是字符串变量

字符串常量：在编译过程中，就确定了知道这个`pre`的值，所以就直接放到了常量池中（最后在加载之后放到了方法区中的运行时常量池中）

字符串变量：需要在运行时通过运算才能得到，这个时候是运行结束之后在堆空间中创建了对应的String实例对象来存储这个`suf`。

所以有个面试题`==`和`equal`

```java
public void StringEqual(){
  String a="abc";
  String b=a+"";
  //表面上看起来两个值都是一样的，但是进行==比较时返回false。因为存储的地方不一样，前者存储在方法区的运行时常量池中，后者存放在堆的实例对象中
  //所以这个时候就需要进行equal比较，来比较两个值是否一样
}
```

jdk7的时候将字符串常量从永久代放到了堆空间中。因为永久代一般不进行回收，所以放在堆中

























![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/Jvm内存模型第一版.drawio.png)