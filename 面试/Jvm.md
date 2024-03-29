# 问题

1、类加载流程

> 第一步：加载，将.class文件加载到内存中去
>
> 第二步：
>
> 1. 验证，验证这个.class文件是否符合jvm的规范，是否会对jvm产生错误的影响
> 2. 准备，对静态变量附默认值
> 3. 解析，将常量池中的符号引用转换为直接引用
>
> 第三步：初始化，对静态变量进行初始化，赋予初始值‘



2、有哪些类加载器

> 核心类加载器（Bootstrap），加载java的核心文件
>
> 扩展类加载器，加载ext包下的类
>
> 应用类加载器，加载我们写的java程序的类信息
>
> 自定义类加载器。
>
> 双亲委派机制：为了防止，修改了一些基本的类，会被我们自定义的加载器进行加载。所以同包同名的核心java类是会一层一层往上找，找到核心类加载器去加载。只有上层的加载器加载不了，才会让下层的类加载器去加载

3、运行时数据区包括哪些部分，分别是存储什么的

> 线程私有的：
>
> 1、虚拟机栈，用来存放方法的局部变量，方法的一些出口等信息。每个线程都会有一个虚拟机栈，一个栈怔对应一个方法
>
> 2、本地方法栈，其本质含义和虚拟机栈很类似，只是存储的是本地native方法。用于和系统硬件交互等调用C语言执行函数的
>
> 3、程序计数器，用于记录程序执行的位置，方便方法调用进行位置定位转换等
>
> 线程共有的：
>
> 1、堆，存储了几乎所有的对象实例，数组信息等。其中也有线程缓冲区，只存储对应线程的一些常量信息，以及jit编译的热点代码等。
>
> 2、方法区：存储类的一些元数据，类的静态常量信息等。

4、简述一些垃圾回收算法

> 首先，需要确定哪些是垃圾，主要有两种算法模式
>
> 1、引用计数法：有一个专门的数组空间用户存储对象被引用的数量。就通过这个来判断当前对象是否还有存活的必要
>
> 2、可达性分析法：通过创建一个GCRoots的根节点数组，每个对象的都最终链接到这个根节点上去，当通过根节点遍历到的对象都认为是还需要保证存活的对象
>
> 垃圾确定之后，进行回收。几种算法
>
> 1、复制算法：将原本还认定存活的对象复制到另外一块内存空间去，然后对原本的那个内存空间进行全部的清楚
>
> 2、标记清除算法：对存活的对象进行标记，其他对象进行删除，问题是会产生碎片空间
>
> 3、标记整理算法：将标记的对象整理到当前内存空间的另一部分连续区域去。然后对原本的区域进行清楚。效率会很低
>
> 所以针对集中垃圾回收机制各个的优缺点，设计的分代回收机制
>
> 将整个堆内存设置成几个区域。
>
> Eden区、survive0、survie1和老年代。当有对象创建的时候，判断对象的大小，大对象直接存入老年代。初始化的对象一般进入eden区。
>
> 当进行垃圾回收的时候，将Eden区和From区中判定还需要存活的对象复制到To区，且判断当前From区的对象的岁数（回收轮次）当达到某一个节点的时候，就复制到old区。
>
> 然后对Eden区和From区使用复制算法进行垃圾回收。
>
> 当老年代的空间超过阈值，就对老年代进行标记清除算法进行垃圾回收。

5、G1垃圾收集器

> 将整个堆内存空间划分成一个一个的小空间Regions（对于大对象使用多个连续的小空间存储）。对每个小空间标记Eden、survive、old区域，每次回收机制和之前一样。只是G1的这种概念，方便多核CPU发挥并行垃圾回收的效率，降低STW的时间。

6、介绍一些各种垃圾回收器

>只能回收新生代：Serial（串行） 、Parallel（并行） Scavenge 、**ParNew** （并行）
>
>只能回收老年代：Serial Old 、Parallel Old 、**CMS**（并发） 
>
>都可以：G1（并发）

7、简述CMS的工作原理

>![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/hNpvy4.jpg)
>
>1. 初始标记（STW）但是时间短。
>
>   标记出GCRoots**直接关联**的对象
>
>2. 并发标记
>
>   从GCRoots出发遍历关联到的所有对象
>
>3. 重新标记（STW）
>
>   修正并发标记期间产生变化的对象的标记记录（这个时候产生变动的对象不多）
>
>4. 并发清理
>
>   清除算法，也就是只是记录一个内存空闲列表

8、String、StringBuilder、StringBuffer区别

String对象是不可变的，也就是进行字符串拼接实际上是在进行对象创建的过程

StringBuffer是线程安全的，加了synchronize关键字

StringBuilder线程不安全但是性能较好



9、各种垃圾收集器

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/9fLp6n.jpg)

---

10、Jvm调优的方式

> 1. 堆内存调优：可以通过设置JVM的-Xms和-Xmx参数来控制JVM堆内存的初始大小和最大大小，从而避免频繁的垃圾回收。另外，可以使用一些工具来分析堆内存使用情况，如jstat、jmap、jvisualvm等。
> 2. GC（垃圾回收）调优：可以通过调整JVM的垃圾回收算法和参数，来优化GC性能。比如可以选择不同的垃圾回收器（如Serial、Parallel、CMS、G1等），或调整垃圾回收器的参数（如新生代和老年代的比例、GC线程数等）。
> 3. 类加载优化：可以通过使用类加载器缓存、预加载、动态类生成等技术，来提高类加载速度和降低内存占用。
> 4. JIT（即时编译器）优化：可以通过调整JVM的JIT参数，来优化即时编译器的性能和编译代码的质量。比如可以设置编译器的级别、调整编译阈值等。
> 5. 线程调优：可以通过使用线程池、调整线程数、使用可重入锁、避免死锁等技术，来提高Java应用程序的并发性能和稳定性。
> 6. 其他优化：可以使用Java的并发集合类、Lambda表达式、Stream API等新特性，来提高Java应用程序的代码质量和性能。

10、调优参数

-Xss：虚拟机栈的大小

-Xms：堆的初始值

-Xmx：堆的最大值

-XX:NewRatio=4：设置年轻的和老年代的内存比例为 1:4；
-XX:SurvivorRatio=8：设置新生代 Eden 和 Survivor 比例为 8:2；
–XX:+UseParNewGC：指定使用 ParNew + Serial Old 垃圾回收器组合；
-XX:+UseParallelOldGC：指定使用 ParNew + ParNew Old 垃圾回收器组合；
-XX:+UseConcMarkSweepGC：指定使用 CMS + Serial Old 垃圾回收器组合；
-XX:+PrintGC：开启打印 gc 信息；
-XX:+PrintGCDetails：打印 gc 详细信息。



Java最初名字被戏称为C++--，也就是将C++去除指针和内存管理机制

以下内容仅限HotSpot

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/JVM内存结构.drawio.png)

# 1. 类加载器

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/Jvm内存模型第一版.drawio.png)

## 1.1 类加载和初始化

类加载的时机：任何用到这个类的时候，比如new对象、反射该类、调用类的静态方法

流程其实和我们开发的时候的写代码顺序是一样的

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/类加载流程.drawio.png)



## 1.2 第一步：加载

该步骤的目的就是将磁盘中的class文件加载到内存中

加载之后，生成两个文件

1. 本身的字节码文件
2. 生成了一个指向该文件的一个Class对象（用于后续使用的时候能够找到该字节码文件并使用。一个间接访问的操作`nginx`）

### 1.2.1 类加载器分类

1. 启动类加载器（**BootStrap** classLoader）：最底层的加载器，加载/jre/lib/rt.jar和charset.jar包下的class文件。
2. 扩展类加载器（Extension classLoader）：可以支持一些扩展的拦截类，加载/jre/lib/ext下的class文件。
3. 应用（系统）类加载器（System/Application classLoader）：也就是加载我们日常写的Class文件。
4. 自定义类加载器（Custome ClassLoader）

所有加载加载器的加载器都是BootStrap加载器，也就是说这四者之间并不是父子关系的

bootstrap是C++语言执行的加载操作（Native接口）Java是获取不到的



> 双亲委派是什么（从子到父，从父到子的过程。双向亲属委派）

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



> 懒加载

jvm虚拟机中对类的加载是只有用到某个类的时候才会进行这个类的加载

懒加载时机：

+ new/访问静态实例/访问静态方法时，访问final变量
+ 反射时
+ 初始化子类，父类先初始化
+ 虚拟机启动，被执行的主类初始化
+ xxx

## 1.3 第二步：连接

### 1.3.1 验证

验证加载的class文件

1. 文件格式验证：验证是否为class文件的格式
2. 元数据验证：对类的元数据进行语义的验证，比如是否有不允许的父类（循环继承等）
3. 字节码验证：分析方法的代码逻辑是否正确，比如本来定义的是个int类型，结果计算的时候使用long类型
4. 符号引用验证（符号的定义是java实现的，所以其每个符号的使用方式在jvm中都有一块内存空间对应着），比如Java中没有类似`......`的符号使用方式，这个地方就会报错



将加载进来的class文件进行格式验证，其中的字节码规范验证，符号引用的验证（符号的定义是java实现的，所以其每个符号的使用方式在jvm中都有一块内存空间对应着）

### 1.3.2 准备

对类的静态变量分配内存并赋予其默认值

### 1.3.3 解析

将类中的符号引用替换成直接引用。举个例子，SpringBoot的资源文件我们可能在Java代码中使用的是`${"aaa.xxx"}`来获取。这个时候就是将这个符号转换成具体的存储数据的直接引用（只是举个例子方便理解，具体不是这样的哦）

## 1.4 第三步：初始化

对类的静态变量进行赋值



## 1.5 自定义类加载器

第一步，继承ClassLoader

第二步，重写findClass方法，在该方法中进行指定加载类就可以实现自己的类的加载

第三步，找到二进制类的内容，转换成Class对象，用defineClass方法

```java
public class UserDefinedClassLoader extends ClassLoader {

    @Override
    public Class<?> loadClass(String name) throws ClassNotFoundException {
        FileInputStream fileInputStream = null;
        ByteArrayOutputStream byteArrayOutputStream = null;
        try {
            //加载文件
            File file = new File(name);
            fileInputStream = new FileInputStream(file);
            byteArrayOutputStream = new ByteArrayOutputStream();
            int a = 0;
            while ((a = fileInputStream.read()) != 0) {
                byteArrayOutputStream.write(a);
            }
            //转换为字节数组
            byte[] bytes = byteArrayOutputStream.toByteArray();
            //加载Class文件返回Class对象
            return defineClass(name, bytes, 0, bytes.length);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                byteArrayOutputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
            try {
                fileInputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return super.loadClass(name);
    }
    public static void main(String[] args) {
        //调用上面的加载器指定路径就好了
    }
}
```

---



# 2. 运行时数据区



执行引擎使用运行时数据区中的数据来将其翻译成机器指令，CPU解释执行，最后进行内存的回收

就像是做饭的时候厨师（执行引擎）使用厨台上（运行时数据区）的各种蔬菜鱼肉（数据）做成饭菜，最后还需要清理厨台（GC）



![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/jvm1.png)

线程私有的:`虚拟机栈`、`本地方法栈`、`程序计数器`

线程共享的:`方法区`、`堆`


| 区域             | 共享 | 作用                                                         | 异常                                                         | 备注                                            |
| ---------------- | ---- | ------------------------------------------------------------ | ------------------------------------------------------------ | ----------------------------------------------- |
| **程序计数器**   | 私有 | 记录当前线程的执行字节码文件的行号信息                       | Java虚拟机规范中唯一一个没有规定OutOfMemoryError(内存不足错误)的区域。 | --                                              |
| **Java虚拟机栈** | 私有 | 存放局部变量（基础数据类型和引用数据类型的引用）、操作数据栈、方法出口、动态链接 | 栈深大于允许的最大深度，抛出StackOverflowError(栈溢出错误)。<br/>内存不足时，抛出<br/>OutOfMemoryError(内存不足错误)。 |                                                 |
| **本地方法栈**   | 私有 | 和Java虚拟机栈类似，不过是为JVM用到的本地方法服务。          | 同上                                                         |                                                 |
| **堆**           | 共享 | 对象实例,数组等                                              | 内存不足时，抛出<br>OutOfMemoryError(内存不足错误)。         | 通过-Xmx和-Xms控制大小。<br/>GC的主要管理对象。 |
| **方法区**       | 共享 | 存放类本身信息（版本、字段、方法、接口等）、常量、静态变量、即时编译后的代码等数据。 | 内存不足时，抛出OutOfMemoryError(内存不足错误)。             |                                                 |



## 2.1 程序计数器（PC寄存器）

**作用**：用来存储指向下一条指令的地址。由执行引擎读取来确定下一条指令

存储的必然是**当前方法**的指令地址，如果是Native方法则为undefined



## 2.2 虚拟机栈

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/虚拟机栈结构.drawio.png)

### 2.2.1 概述

栈管运行，堆管存储。（栈就像菜板，堆就像菜蓝子）

每个线程在创建的时候都会创建一个虚拟机栈，其中保存着一个一个的栈帧。一个栈帧就对应着一个Java方法

保存方法的局部变量、部分结果以及方法的调用和返回信息

### 2.2.2 结构

每个线程运行时都会创建一个虚拟机栈

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/虚拟机栈.drawio.png)





### 2.2.3 原理

通过-Xss参数设置栈内存大小`-Xss1024k`

每个线程都有自己的栈，每个方法都对应着一个栈帧，每个方法的执行都对应着这个栈帧的入栈

栈帧的入栈：调用一个新的方法时

栈帧的出栈：当前方法执行结束/出现异常且自身未捕获



+ **局部变量表**：其中保存该栈帧（方法）的局部变量。<br/>使用数组来实现

  该局部变量包含

  1. 基础数据类型（八大基础数据类型）
  2. 引用数据类型的引用（实例存放在堆中）

  > Slot
  >
  > 局部变量表中存储单元是Slot（变量槽）是32位的
  >
  > 针对基础类型中的long和double是64位的所以需要两个槽，其他都是一个槽
  >
  > 存放`引用数据类型的引用`是指存放在堆中的对象的地址信息

  局部变量包括基础数据类型和引用数据类型的引用。局部变量表的大小决定这个栈帧的大小，其中最基本的存储单元是Slot（变量槽）。

  > 栈的调优主要就是在针对局部变量表做的
  >
  > 1. 局部变量表中保存着**对象的引用**（GC的时候只有对象没有再使用才会进行回收）
  > 2. 局部变量表的大小决定着栈帧的大小。当栈的大小固定的时候，局部变量表越大对应的栈帧就越少

+ **操作数栈**：主要用来保存计算过程中的**中间结果**，同时作为计算过程中需要的变量的临时存储

  ```
  int i=1;
  int j=2;
  int x=i+j;
  
  这个时候i+j从局部变量表中取出来之后就在操作数栈中存储着，并将计算的3也存储在这里面。只是进行int x=3之后才又存储在了局部变量表中
  ```

+ 动态链接：**指向运行时常量池的方法引用**，也就是动态这个思想（只记录名字不记录人）方便Java开发中进行一方编写多方调用。所以这个地方**记录的就是运行时常量池中的该方法需要的其他方法/属性的引用**

  每个类的字节码文件中都有一个`Constant pool`常量池，这里面记录了所有的方法、字段等的符号引用和对应的真实地址存储结构等。符号引用在字节码中就是类似#27之类

  - 部分符号引用在类加载阶段的时候就转化为直接引用，这种转化就是静态链接
  - 部分符号引用在运行期间转化为直接引用，这种转化就是动态链接

+ 方法出口：方法返回地址，存放调用该方法的程序计数器的值。只针对正常退出该方法的时候这个时候需要给上层返回具体的信息，所以需要找到上层的调用





### 2.2.4 虚拟机栈的异常

主要就是栈内存的溢出异常

+ 固定栈大小，如果递归调用方法出现栈帧数量超过栈的大小，则会抛出StackOverflowError
+ 动态栈大小，如果超过栈的大小就进行扩充栈，如果没有申请到内存就会抛出OutOfMemoryError（OOM）

## 2.3 本地方法栈

区别于虚拟机栈是管理的Java方法的调用，本地方法栈是管理的本地方法的调用（别的语言的方法调用）

当某个线程调用了本地方法的时候，就会完全脱离虚拟机的掌控，而使用本地处理器的寄存器等进行管理（就完全和Java无关了，而是使用C来管理）。权限也更高



## 2.4 <font color='red'>堆</font>

### 2.4.1 特点

1. 线程：Java的堆区在Jvm启动的时候就创建，是线程共享的。
2. 空间：物理上是不连续的内存空间，但是在逻辑上需要理解成连续的（虚拟内存，将物理内存的地址进行连续的存储）
3. TLAB：将整个的堆空间按照每个线程区分出来，每个线程独有一块私有的缓冲区TLAB
4. 存储：几乎所有的实例对象和数组都存储在堆上



### 2.4.2 堆空间调优参数

-Xms，初始堆空间大小。-XX:InitialHeapSize。例-Xms1024m

-Xmx，最大堆空间大小。-XX:MaxHeapSize。例-Xmx1024m。一旦堆内存大小超过Xmx设置的值就会抛出OOM异常。线上环境中建议将初始堆内存和最大堆内存设置成相同的值



-XX:NewRatio=2，表示新生代占1，老年代占2，即新生代和老年代占堆大小比例是1:2。（-XX:NewRatio=4，表示新生代占1，老年代占4，比例是1:4）一般不调整该参数，除非是明确知道该程序中会有很多的存活对象的时候。

-XX:SurvivorRatio=8，设置新生代内存分配大小中Eden:Suvivor0:Suvivor1=8:1:1

-XX:+PrintGCDetails，表示将GC处理日志输出出来

-Xmn，设置新生代的空间大小（NewRatio同时存在时候，以-Xmn为准）



-XX:MaxTenuringThreshold=<N>进行设置新生代垃圾的最大年龄，默认情况下是15

> -X是Jvm的运行参数
>
> ms：memory start
>
> 默认单位为字节，可以指定K、M、G等
>
> 默认初始大小=机器物理内存/64
>
> 最大堆大小=机器物理内存/4
>
> 真实在存储数据的时候，堆的内存是一个surivor区+eden+老年代。也就是两个surivor在同一时间，实际上只有一个起效用
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/9SIWD4.png)
>
> 这里S0C/S1C+EC+OC=真实堆能使用的空间。但是设置的-Xms是S0C+S1C+EC+OC
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/UoEKMW.png)

其他

```
-XX:+PrintFlagsInitial：查看所有的参数的默认初始值
-XX:+PrintFlagsFinal：查看所有的参数的最终值（可能会存在修改，不再是初始值）
-XX:+PrintGC 或 -verbose:gc ：打印gc简要信息
-XX:HandlePromotionFalilure：是否设置空间分配担保
```



### 2.4.4 OOM(OutOfMemoryError: Java heap space)

> Error是错误
>
> Exception是异常。
>
> 两者都是Throwable的子类。广义上都是异常

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/wJkOo3.png)

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/C4kX0X.png)



### 2.4.5  年轻代和老年代

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/年轻代和老年代1.png)

### 2.4.6 对象分配过程

对象分配规则

1. 优先分配到Eden
2. 大对象直接分配到老年代（比如一次从数据库中取出来几百条几万条数据可能直接造成FullGC或者OOM）
3. 动态对象年龄判断，一些细小的规则及空间分配担保

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/新生代垃圾回收.drawio.png)

学习自宋老师的图片：![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/f8Wq8h.jpg)

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/lhasNA.png)

### 2.4.6 MinorGC、MajorGC和FullGC

|                | MinorGC                                                      | MajorGC                                                      | FullGC                                                       |
| -------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 别名           | YGC                                                          | FGC                                                          |                                                              |
| 简述           | 新生代收集                                                   | 老年代收集-CMS收集器特有<br>（还有一种MixedGC混合收集针对新生代和老年代G1收集器使用） | 整堆收集，包括方法区                                         |
| 触发条件       | Eden满了                                                     | 老年代满了（一般是在一次MinorGC之后导致老年代满了进行MajorMC） | 1. System.gc()<br>2. 老年代空间不足<br>3. 方法区空间不足<br>4. 其他操作导致老年代空间不足 |
| 处理           | 1. 将Eden和From中不满足阀值的对象未回收对象实例<br>使用**复制算法**复制到To。将原本的内存空间清除<br> 2. 超过阀值则复制到老年代 | 1. MinorGC之后发现老年代空间满了就进行MajorGC<br>2. 进行MajorGC之后如果发现老年代空间还是不足，就抛出OOM |                                                              |
| 对用户线程影响 | 🌟，会触发STW，暂停其他用户线程                               | 🌟🌟🌟执行速度相对于MinorGC慢十倍以上。所以STW时间更长          | 🌟🌟🌟🌟🌟                                                        |
| 频率           | 最高，<br>Java大部分对象都是朝生夕死                         | 一般会在很多次MinorGC之后才进行一次                          |                                                              |

在Java虚拟机中，Minor GC、Major GC 和 Full GC 是垃圾收集器在不同的情况下触发的。

1. Minor GC： Minor GC 通常发生在**新生代空间**中，当新生代空间不足以分配新对象时触发。在新生代空间中，对象分配的速度比老年代空间中的速度快，所以新生代空间很容易被填满。Minor GC 可以清理掉没有被引用的对象，同时将存活的对象复制到老年代空间中。在执行 Minor GC 的过程中，应用程序线程会被暂停。
2. Major GC： Major GC 通常发生在**老年代空间**中。当老年代空间不足以分配新对象时触发。由于老年代空间中的对象寿命更长，所以需要更长时间才能被回收。在执行 Major GC 的过程中，应用程序线程会被暂停。
3. Full GC： Full GC 是指对整个 Java 堆进行垃圾回收，包括新生代和老年代空间。Full GC 通常由多种原因触发，例如**老年代空间已满、永久代空间已满、系统调用 System.gc()** 等。在执行 Full GC 的过程中，应用程序线程会被暂停。由于 Full GC 涉及到整个 Java 堆的垃圾回收，所以它的执行时间通常比 Minor GC 和 Major GC 更长。

### 2.4.7 堆空间是分配对象存储的唯一选择嘛（逃逸分析）

答：现有虚拟机是对象只有分配在堆上的。只是逃逸分析这个技术可以做到将对象分配到栈上

如果一个实例对象通过**逃逸分析**判断是只有这个方法使用的。那么这个实例对象就可以将内存分配到栈上。

**逃逸分析**条件：一个对象在方法中定义之后，只在方法内部使用，则认为没有发生逃逸

```
public void aaa(){
	A a=new A();
	...
	...
	a=null;
}
```

在Java8及其以后，默认开启逃逸分析。在编译过程中JIT编译器根据分析结果，将对应的对象优化成**栈上分配**

> ```java
> /**
>  * 逃逸分析
>  *
>  * 如何快速的判断是否发生了逃逸分析，大家就看new的对象实体是否有可能在方法外被调用。
>  */
> public class EscapeAnalysis {
> 
>     public EscapeAnalysis obj;
> 
>     /*
>     方法返回EscapeAnalysis对象，发生逃逸
>      */
>     public EscapeAnalysis getInstance(){
>         return obj == null? new EscapeAnalysis() : obj;
>     }
> 
>     /*
>     为成员属性赋值，发生逃逸
>      */
>     public void setObj(){
>         this.obj = new EscapeAnalysis();
>     }
>     //思考：如果当前的obj引用声明为static的？ 仍然会发生逃逸。
> 
>     /*
>     对象的作用域仅在当前方法中有效，没有发生逃逸
>      */
>     public void useEscapeAnalysis(){
>         EscapeAnalysis e = new EscapeAnalysis();
>     }
> 
>     /*
>     引用成员变量的值，发生逃逸
>      */
>     public void useEscapeAnalysis1(){
>         EscapeAnalysis e = getInstance(); //这个e对象，本身就是从外面的方法逃逸进来的
>         //getInstance().xxx()同样会发生逃逸
>     }
> }
> 
> ```

逃逸分析的代码优化

1. **栈上分配**，就是没有发生逃逸的对象，在栈上进行内存的分配，这样在方法结束的时候出栈就释放了这个对象的内存空间

2. **同步省略**，逃逸分析的对象实例进行了栈上分配，那么这个对象就是线程私有的。那么如果原本对这个线程进行了**加锁操作就是多余的**。所以这个时候就不用进行线程数据同步了。

   JIT编译器分析该锁对象只有在该线程有效，不会影响到其他线程的数据。就不需要这个锁了，就进行了**锁消除**

   ```java
   public void f() {
       Object hellis = new Object();
       synchronized(hellis) {
           System.out.println(hellis);
       }
   }
   这个锁本身针对的这个hellis就是一个会被逃逸分析认定为栈上分配的。所以这个线程的对象就不会出现线程共享的问题。所以这个锁就没有必要
   ```

3. **分离对象/标量替换**

   什么是标量：无法分解的数据，比如对象就是一个聚合量，但是一个int类型属性就是一个标量

   ```java
   class Point {
       private int x;
       private int y;
   }
   private static void alloc() {
       Point point = new Point(1,2);
       System.out.println("point.x" + point.x + ";point.y" + point.y);
   }
   ```

   如果逃逸分析一个对象不会逃逸，那么就将这个对象（聚合量）分解成所有的标量。**标量（基础数据类型）肯定是分配在栈上的。所以就不需要分配堆内存**



### 2.4.8 总结

1. 区分年轻代和老年代，以及**对象分配过程**
2. Eden和survivor区
3. 分代的原因
4. GC的三种区分



## 2.5 <font color="red">方法区</font>

### 2.5.1 方法区、栈和堆的关系

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/堆、方法区和栈的关系.drawio.png)



**一个对象的创建，对象的实例存储在堆中，这个方法使用了这个对象，那么就存储这个对象的引用。而这个对象他所代表的类的各个信息都在方法区中存储**

A a=new A()

+ A，类的基本信息，存储在方法区中
+ a，对象的引用，在方法调用时候存储在虚拟机栈中 
+ new A()，对象的实例，存放在堆中



### 2.5.2 简述、特点和演进过程

1. **线程共享**，启动时创建
2. **大小**可以固定不变也可以设置可扩展。大小取决于加载的类的多少。如果类过多会抛出OOM异常（加载的jar文件类过多，tomcat部署的应用程序过多）
3. 使用的是本地内存，也就是系统内存
4. **演进**：**hotspot**中方法区的实现在1.8之前是永久代，1.8及其之后是metaspace。**metaSpace和方法区**。metaSpace是方法区在hotSpot中的实现

### 2.5.3 方法区参数设置及OOM

Java7之前：

+ `-XX:PermSize`来设置永久代的初始大小，默认20.75M

+ `-XX:MaxPermSize`来s何止永久代最大可分配空间大小，32位机默认是64M，64位默认是82M

  超过就会OOM

Java8之后：

+ `-XX:MetaspaceSize`，默认21M，例如：`-XX:MetaspaceSize=21M`
+ `-XX:MaxMetaspaceSize`，默认-1，表示**上限没有限制**，即虚拟机会一直使用系统内存，直到耗尽抛出OutFlowOfMemoryError: metaspce，例如：`-XX:MaxMetaspaceSize=1024M`

Java8之后，一般MetaspaceSize是一个高水平线，如果超过这个高水平线就会触发一个FullGC进行卸载没用的类。**然后这个高水位线将会重置**。新的高水位线的值取决于GC后释放了多少元空间。

+ 如果FullGC释放的空间不足，就会提高metaSpace空间（不会超过maxMetaspaceSize）
+ 如果FullGC释放的空间足够，就会下调metaSpace空间



造成方法区OOM的情况

+ 反射的方式持续创建类
+ 动态加载的类过多



### **2.5.4 <font color="red">方法区内部结构</font>**

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/eAdpxS.png)

一般包含以下几部分

+ **类信息**：类的名称，字段，方法，常量，修饰符，接口注解等等

  ```java
  public class A extends Params{
    public int num=1;
    
    public void setA(A a){
      this.num=a.num;
    }
  }
  ```

+ 静态变量

  new byte[1024*1024*100]这个对象是放在堆空间中的。但是这个bytes的引用是在jdk7之后从方法区移到了堆中

  ```java
  public static byte[] bytes=new byte[1024*1024*100];
  ```

+ **运行时常量池**

  > 常量池，其中存放着经过编译后的各种字面量，以及类型、字段和方法的符号引用（符号引用可以理解成就是一种引用）
  >
  > 为什么使用常量池，因为需要存放各种引用，如果直接将对应的类或者对应类的方法加载进来就会很大很麻烦。（我表上记个身份证号就好，我没必要将这个人挂表上）
  >
  > + 数量值
  > + 字符串值
  > + 类引用
  > + 字段引用
  > + 方法引用
  >
  > 字节码中的常量池
  >
  > ```java
  > Constant pool:
  >    #1 = Methodref          #18.#52        // java/lang/Object."<init>":()V
  >    #2 = Fieldref           #17.#53        // cn/sxt/java/MethodInnerStrucTest.num:I
  >    #3 = Fieldref           #54.#55        // java/lang/System.out:Ljava/io/PrintStream;
  >    #4 = Class              #56            // java/lang/StringBuilder
  >    #5 = Methodref          #4.#52         // java/lang/StringBuilder."<init>":()V
  >    #6 = String             #57            // count =
  >    #7 = Methodref          #4.#58         // java/lang/StringBuilder.append:(Ljava/lang/String;)Ljava/lang/StringBuilder;
  >    #8 = Methodref          #4.#59         // java/lang/StringBuilder.append:(I)Ljava/lang/StringBuilder;
  >    #9 = Methodref          #4.#60         // java/lang/StringBuilder.toString:()Ljava/lang/String;
  >   #10 = Methodref          #61.#62        // java/io/PrintStream.println:(Ljava/lang/String;)V
  >   #11 = Class              #63            // java/lang/Exception
  >   #12 = Methodref          #11.#64        // java/lang/Exception.printStackTrace:()V
  >   #13 = Class              #65            // java/lang/String
  >   #14 = Methodref          #17.#66        // cn/sxt/java/MethodInnerStrucTest.compareTo:(Ljava/lang/String;)I
  >   #15 = String             #67            // 测试方法的内部结构
  > ...
  > ```
  >
  > 

  通过ClassLoader将classFile中的常量池信息加载到方法区之后就是放到了运行时常量池中。在加载的过程中将这些**带#的符号引用，转换成真实的内存地址引用存放在运行时常量池中**

+ JIT编译代码缓存

大佬的博文中有介绍关于**<font color="red">方法区的执行过程</font>**[方法区4.3](https://blog.csdn.net/sj15814963053/article/details/110371508?spm=1001.2014.3001.5502)

或者[宋老师](https://www.bilibili.com/video/BV1PJ411n7xZ?p=96)

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/oi50AI.jpg)

<font color="red">**jdk7之后将原本放在方法区中的字符串常量和静态变量的引用放到了堆空间中**</font>

### 2.5.5 方法区的垃圾回收

可以回收可以不回收。Jdk11的ZGC收集器不关注方法区的内存空间回收

方法区的垃圾回收主要就是进行**类卸载**和**废弃常量**

**废弃常量**：和对象的回收很类似，都是没有了引用就可以回收内存

**类卸载**条件：

+ 该类的所有实例对象全部都被回收
+ 该类的类加载器已被回收，通常可能性不大
+ 该类的Class对象已被回收（防止再通过反射访问该类）

只有满足上面三个条件才会被回收。



# 3. 对象实例化的内存布局和访问定位

## 3.1 对象的实例化

### 3.1.1 创建对象的方式

+ new，构造器的方式
+ Class的newInstance()，只能调用空参的构造器，且构造器权限是public
+ Constructor的newInstance()，可以调用空参/带参的，权限没有限制
+ 使用clone()，对象的复制
+ 使用反序列化，从文件中或者网络中获取二进制字节流
+ 第三方库Objenesis

### 3.1.2 创建对象的具体步骤

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/对象创建的步骤.drawio.png)



### 3.1.3 对象的内存布局

![](/Users/kaochong/Library/Application Support/typora-user-images/image-20220211173658002.png)

+ **对象头**：运行时需要的元数据，该对象的类类型指针
  + HashCode
  + GC分代年龄
  + 锁状态标志
  + 线程持有的锁
  + 其他锁相关的信息

+ 实例数据，实际上该对象有的各种字段、方法等
+ 对齐填充，保证Java对象大小是8bit的倍数

### 3.1.4 对象的访问

**直接指针（HotSpot使用）**：



![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/对象的访问（对象的使用）.drawio.png)



**句柄访问**：在堆中开辟一个空间，存储两个数据，到**对象实例数据的指针**和**到对象类型数据的指针**。

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/IcIcYE.png)

# 4. 执行引擎和本地方法库

## 4.1 执行引擎

### 4.1.1 概述

作用：将字节码指令解释/编译为对应平台上的本地机器指令（将字节码翻译成机器语言）。并按照程序计数器来操作堆栈中的数据，并在虚拟机栈中进行对应的操作计算等



### 4.1.2 JIT编译器

Hotspot执行代码有两种方式（协作执行）

+ 针对常用的代码，使用JIT技术编译成机器码直接执行。
+ 将源代码编译成字节码，在运行的时候通过解释器将字节码转换成机器码执行

JIT（just in time）即使编译技术。

只使用JIT的问题：程序启动需要耗时很长时间才能使用（启动需要编译所有代码	）

整合两者：虚拟机刚启动时，解释器先发挥作用，不用等待即使编译器全部编译完成，可以省去需要不必要的编译时间。随着程序时间的推移，即使编译器逐步发挥作用，根据**热点探测**功能，将有价值的字节码编译成机器码，来换取更高的程序执行效率



### 4.1.3 JIT什么时候使用（热点探测）

+ 前端编译器：即在使用代码前就将代码编译好。比如将.java编译成.class的过程
+ 后端运行期编译器：就是JIT，在代码执行期间即时的将字节码转变成机器码的过程
+ 静态提前编译器：就是将.java直接编译成机器码。运行期间就没有编译的操作了（AOT编译器）



**什么时候使用JIT**

根据代码的执行频率。（一个多次调用的方法，或者方法体中循环较多次的方法体）执行较多的就是**热点代码**。

**热点探测功能**：基于计数器的热点探测

+ 方法调用计数器来统计方法的调用次数。
+ 回变计数器来统计循环体的执行循环次数

**热点衰减**：在一定时间限度内，如果方法调用次数仍然不足提交进行编译器编译。就将调用次数减少一半。（这个一定时间限度使用就是-XX:-UseCounterDecay）



### 4.1.4 使用JIT

正常hotspot的默认模式是混合模式。也就是既有解释器也有JIT。

可以通过`java -Xint -version`，将修改成解释器模式之下

`java -Xcomp -version`修改成纯即时编译器的模式并打出信息。也就是第一次就进行编译进行之下

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/HllCGq.png)



### 4.1.5 JIT的分类（C1编译器和C2编译器）

+ C1编译器：Client Compiler 表示Java虚拟机运行在client模式下（桌面客户端等）

  会对字节码进行简单和可靠的优化，耗时短（开机时间短，但是开机后的运行速度稍微差点意思）

+ C2编译器：Server Compiler 表示Java虚拟机运行在server上（网页的CS模式下的后台应用程序）

  会进行耗时较长的优化以及激进优化，耗时长（开机时间长，但是开机后的运行速度稍微好一点）

> Graal编译器，JDK10之后的编译器，需要显式的去开启。效率和C2差不多

## 4.2 本地方法库

一个Native Method就是一个Java调用非Java代码的接口，主要就是C/C++。使用native修饰不需要实现，具体实现在别的代码中进行







# 5. 垃圾回收算法

## 5.1 概念

什么是垃圾：运行程序中没有指针指向的对象

早期的垃圾回收：开发人员需要再new之后进行delete将内存释放出来，这样压力在开发人员，如果忘记释放就会出现问题。

Java带有自动的内存管理机制。

缺点：弱化开发人员在程序内存溢出之后的问题解决能力



## 5.2 垃圾标记算法

|              | 引用计数法                                                   | <font color="red">可达性分析法<br>根搜索算法<br/>追踪性垃圾收集</font> |
| ------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 实现方式     | 对每个对象保存一个引用计数器属性，<br>用来记录对象被引用的次数 | 按照从下至上的方式搜索被**根对象集合**连接的目标对象是否可达（也就是只能标记出来是可达的即不可回收的，其他就都是可回收的） |
| 优点         | 实现简单；<br>判定效率高（只需要判断属性是否为0即可）        | 解决循环引用（Java、C#使用）                                 |
| 缺点         | 1. 资源浪费，计数器需要单独的空间存储<br>2. 时间浪费，每次操作都需要更新计数器<br><font color="red">3. 无法处理循环引用</font>：即根调用不用了，但是其他引用相互调用着导致计数器不为0一直无法回收 | 1. 检查性能相对于前者来说差一点<br>2. 需要快照，所以需要"Stop the world"，即使是CMS也在进行枚举根节点的时候需要停止 |
| 内存泄露例子 | 循环引用                                                     |                                                              |

![可达性分析法.png](https://upload-images.jianshu.io/upload_images/16196576-7dfa4d83bd9ac2f6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

GC Roots包括以下几类元素

+ **虚拟机栈/本地方法区中引用的对象**，说明正在使用
+ **方法区/堆空间中类静态属性引用的对象**，静态数据只要需要类就需要这些参数
+ **方法区/堆空间中常量引用的对象，字符串常量池中**
+ 同步锁持有的对象
+ 基本数据类型对应的Class对象，常驻的异常对象（NPE、OOM）系统类加载器

## 5.2.1 finalization 机制

调用时机：垃圾回收对象之前，会先调用这个对象的finalize()方法。

作用：为了进行一些垃圾回收之前的逻辑处理（资源释放，连接释放等），比如我本来开启了一些资源，想要在这个对象被销毁之前进行一些资源的关闭操作。

类似Servlet中的destory()方法

注意点：

1. 不要主动调用finalize()方法 
   1. 可能导致复活
   2. 执行时间是没有保障的，需要在GC环境下才能正常使用
2. 重新要谨慎，因为是在GC之前执行，如果出现性能问题会影响很大的GC性能



由于有该机制，所以虚拟机中对象有三种状态

+ 可触及：从根节点检查，没法到达这个对象（可达性分析法）
+ 可复活：该对象在调用finalize()方法中可以被复活
+ 不可触及：调用finalize()没有复活，且无法触及这个对象，这个对象就会被销毁

**判定一个对象是否可回收，需要两次标记**：

1. 引用计数法判定该对象不可被访问——标记一
2. 如果有finalize()方法，且执行之后该对象可以被触及。那么就不会被回收
3. 如果没有重写finalize()，或者重新的逻辑中不会复活该对象。那么就第二次标记——标记二

两次标记都满足才会被回收

### 5.2.2 GCRoots

可达性分析法：

1. 先确定GCRoots
2. 根据GCRoots的集合去找可触及标记为可存活的对象。其他的对象标记为可回收



> MAT：Memory Analyzer，可视化的内存监控工具。基于eclipse`https://www.eclipse.org/mat/`
>
> 通过解析jvm生成的dump文件来生成结果信息
>
> 生成dump文件：
>
> 1. jps获取进程id，`jmap -dump:format=b.live.file=test1.bin 12220`
> 2. 使用JVisualVM可视化的方式来生成dump文件
>
> 

## 5.3 垃圾清除算法

### 5.3.1 常见垃圾清除算法



|              | 标记—清除算法                                                | 复制算法                                                     | 标记—整理算法                                                |
| ------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 执行过程     | 1.  STW，停止主线程 <br>2. 标记：从根节点开始遍历，标记所有被引用的对象（标记在对象header中） <br>3. 清除：对堆内存从头到尾线性遍历，将没有被标记的对象进行清除 | 1. 遍历根节点，将关联到的对象复制到另外一片空间中 <br>2. 清除，将原本的空间全部清除 | 1、STW<br>2、标记<br>3、整理：将所有存活对象压缩到内存的一端<br>4、清除边界外其他所有空间 |
| 图解         | ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/QlQVw7.jpg) | ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/Keyovw.jpg) | ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/EmL5as.jpg) |
| 优点         | 实现简单，理解简单                                           | 1、不会产生碎片空间，分配对象适用指针碰撞即可<br>2、效率较高 | 1、不会产生内存碎片<br>2、内存利用率高                       |
| 缺点         | 1、效率较低，需要进行两次遍历<br>2、STW，影响用户线程<br>3、产生碎片空间，需要维护内存空闲列表 | 1、空间利用率低，只能适用一半<br>2、在对象存活比例较高时，消耗资源最大<br>3、STW | 1、效率最低<br>2、修改了存活对象的引用<br>3、STW             |
| 适用情况     | 不需要存活对象的内存调整                                     | 对象存活比例低的情况（Survivor区）                           | 内存空间较大，存活率较高（老年代）                           |
| 注意点       | 清除：清除并不是真的置空，只是将需要清除的对象地址保存在**空闲列表**中。后续帮忙放入新的对象 |                                                              |                                                              |
| 对象内存分配 | 内存空闲列表                                                 | 指针碰撞                                                     | 指针碰撞                                                     |
| 总结         | 速度：🌟🌟<br>内存利用率：🌟🌟<br>移动对象：🌟🌟                   | 速度：🌟🌟🌟<br/>内存利用率：🌟<br/>移动对象：🌟                  | 速度：🌟<br/>内存利用率：🌟🌟<br/>移动对象：🌟                   |

### 5.3.2 <font color="red">分代回收算法</font>

年轻代：使用复制算法，效率高，同时使用survivor来缓解内存浪费的情况

老年代：标记清除和标记整理的混合使用。也就是通常使用标记—清除，一段时间之后使用标记—整理算法

CMS回收器：使用标记清除来实现。当内存回收不佳（碎片空间导致 ）则使用Serial Old执行Full GC来运行标记整理

为了解决每种回收算法的侧重点不同，所以将对的内存空间分为新生代和老年代两种，然后针对这两种使用不同的回收算法

新生代内存回收：复制算法

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/新生代垃圾回收.drawio.png)

老年代回收：标记清除算法，时间长了使用一次标记整理算法来解决内存碎片化问题

**新生代->老年代**每次回收针对未回收的对象进行记录，一旦记录次数到达阀值就会将新生代的未回收对象引用转移到老年代中。



> <font color="green">增量收集算法</font>：解决STW的问题
>
> 垃圾收集线程和用户线程**交替执行**。每次只收集一小片区域的内存空间，然后切换成用户线程执行
>
> 优点：低延时的解决STW；
>
> 缺点：增加消耗线程切换和上下文切换。
>
> 
>
> <font color="green">分区算法</font>：将一个大的堆分成若干个小区region，然后每次针对设置的目标停顿时间（按照业务配置）去回收若干个小区。从而减少一次GC所产生的停顿时间的限制



### 5.3.3 分区算法

G1垃圾回收器使用的算法

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/G6Za7g.jpg)

H表示巨型对象，用来存储大对象（使用多个连续的region存储）

youngGC和mixedGC、FullGC。

1. youngGC主要回收Eden到Survivor中或到old中
2. 当Old越来越多超过某个阈值的时候，触发一次mixedGC，回收整个young区域和部分old区域
3. 当老年代被填满的时候，触发FullGC将整个空间回收

## 5.3 垃圾回收的概念性问题

### 5.3.1 System.gc()

开发通过`System.gc()`会触发Full GC。不一定立刻执行。

用处：做性能测试的时候的准备工作

### 5.3.2. 内存溢出和内存泄露

**内存溢出（OOM）**：针对堆空间。没有空闲内存且垃圾收集器无法提供更多的内存。

原因：

1、设置的堆内存不够

2、创建的大对象，长时间不能被垃圾收集器回收。比如从数据库中一次性查询出来几万条数据。循环创建了大量的对象。

OOM之前一定会触发一次GC。会尝试回收**软引用**的对象



**内存泄露**：对象不会被使用，但是GC又不能回收他们。

内存泄露并不会直接导致程序崩溃，而是泄露的内存越来越多最终导致OOM来导致程序崩溃 

例子：1. 代码中将单例对象关联了另外的业务对象数据。2. 一些资源没有关闭

### 5.3.3. STW

因为GC的原因导致用户线程暂停下来

情况：可达性分析算法，在分析哪些属于GCRoots的时候需要停顿下来（针对一个快照），确保计算的时候不会有新的对象产生——确保数据的一致性。



### 5.3.4 垃圾回收的并行和并发

并行：多个CPU针对多个进程。就是一直在一起执行。不会有资源的抢占

并发：一个CPU执行多个进程，频繁的切换进程执行，一个时刻只有一个进程在执行

### 5.3.5 安全点和安全区域

**安全点**：程序执行过程中，并不是所有的地方都能停下来进行GC，只有特定的位置才能停顿

一般选择在`方法调用`、`循环跳转`、`异常跳转`这种本身就会执行时间较长的时候

如何保证所有线程都在最近的安全点停顿：

+ **抢先式中断**：先中断所有线程，如果有线程不在安全点就继续该线程直到运行到安全点（虚拟机不使用）
+ **主动式中断**：设置一个中断标志，各个线程运行到自动停下来。



**安全区域**：一块区域都可以让当前用户线程停下来。该区域内对象的引用状态不会发生变化就可以进行GC。例如sleep等

### 5.3.6 四种引用（强软弱虚）

+ 强引用：只要强引用还存在，那么垃圾回收器就永远不会回收掉这中引用对应的对象

+ 软引用：用来描述一些还有用，但并非必须的对象。这种对象会在内存溢出异常之前，也就是第二次回收的时候被回收掉。jdk1.2之后使用`SoftReference`类创建

+ 弱引用：描述非必须的对象，这种对象会直接被下一次的垃圾回收回收掉。也就是说无论内存是否足够都会被回收。jdk1.2之后使用`WeakReference`类创建

+ 虚引用：这是一种比较特殊的存在，他的目的是**能在这个对象被收集器回收的时候收到一个系统通知**。jdk1.2之后使用`PhantomReference`类创建

> 介绍一下强引用、软引用、弱引用、虚引用的区别？

> 思路： 先说一下四种引用的定义，可以结合代码讲一下，也可以扩展谈到ThreadLocalMap里弱引用用处。
>
> 参考答案：
>
> 1）强引用
>
> 我们平时new了一个对象就是强引用，例如 Object obj = new Object();即使在内存不足的情况下，JVM宁愿抛出OutOfMemory错误也不会回收这种对象。
>
> 2）软引用
>
> 如果一个对象只具有软引用，则内存空间足够，垃圾回收器就不会回收它；如果内存空间不足了，就会回收这些对象的内存。
>
> ```
> SoftReference<String> softRef=new SoftReference<String>(str);     // 软引用
> ```
>
> 用处： 软引用在实际中有重要的应用，例如浏览器的后退按钮。按后退时，这个后退时显示的网页内容是重新进行请求还是从缓存中取出呢？这就要看具体的实现策略了。
>
> （1）如果一个网页在浏览结束时就进行内容的回收，则按后退查看前面浏览过的页面时，需要重新构建
>
> （2）如果将浏览过的网页存储到内存中会造成内存的大量浪费，甚至会造成内存溢出
>
> 如下代码：
>
> ```
> Browser prev = new Browser();               // 获取页面进行浏览
> SoftReference sr = new SoftReference(prev); // 浏览完毕后置为软引用        
> if(sr.get()!=null){ 
>  rev = (Browser) sr.get();           // 还没有被回收器回收，直接获取
> }else{
>  prev = new Browser();               // 由于内存吃紧，所以对软引用的对象回收了
>  sr = new SoftReference(prev);       // 重新构建
> }
> ```
>
> 3）弱引用
>
> 具有弱引用的对象拥有更短暂的生命周期。在垃圾回收器线程扫描它所管辖的内存区域的过程中，一旦发现了只具有弱引用的对象，不管当前内存空间足够与否，都会回收它的内存。
>
> ```
> String str=new String("abc");    
> WeakReference<String> abcWeakRef = new WeakReference<String>(str);
> str=null;
> 等价于
> str = null;
> System.gc();
> ```
>
> 4）虚引用
>
> 如果一个对象仅持有虚引用，那么它就和没有任何引用一样，在任何时候都可能被垃圾回收器回收。虚引用主要用来跟踪对象被垃圾回收器回收的活动。

> 终结器引用：



# 6. 垃圾回收器

评估GC的性能指标：

+ **吞吐量**：运行用户代码时间/总运行时间
+ **暂停时间**：执行GC时，用户线程被暂停的时间
+ 内存占用：Java堆所占的内存大小。但是随着硬件的发展，该项慢慢的不被重视

在最大吞吐量优先的情况下，降低停顿时间

## 6.1 不同垃圾回收器的概述

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

## 6.3 CMS

CMS：Concurrent-Mark-Sweap，并发标记清除。

+ 针对停顿时间
+ 回收线程和用户线程同时工作
+ 并发标记清除
+ B/S使用较多
+ 老年代



### 6.3.1 工作原理

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/hNpvy4.jpg)

1. 初始标记（STW）但是时间短。

   标记出GCRoots**直接关联**的对象。STW

2. 并发标记

   从GCRoots出发遍历关联到的所有对象

3. 重新标记（STW）

   修正并发标记期间产生变化的对象的标记记录（这个时候产生变动的对象不多）。STW，但是时间不长

4. 并发清理

   清除算法，也就是只是记录一个内存空闲列表

### 6.3.2 弊端

1. 由于是并发清理，所以CMS不能等到没有内存了再去回收，因为执行期间**需要拥有空闲内存给用户线程使用**。如果出现执行期间没有足够内存给用户使用，就会抛出`Cocurrent Mode Failure`这时就会启动Serial Old来进行垃圾回收，停顿时间就很长了
2. 产生碎片化内存空间。会导致提前触发Full GC。触发会使用Serial 这种性能较低的
3. 对CPU资源很敏感，虽然并发阶段不会停顿，但是对CPU有功能消耗，所以这个时候必然其他线程还是有一定影响的
4. 标记的不完整



### 6.3.3 发展

JDK9的时候标记为Deprecate。JDK14删除了CMS

CMS：低延时

Parallel+Parallel Old：高吞吐量



## 6.4 G1 区域分代化

### 6.4.1 为什么有G1？

随着业务的发展，内存和处理器的优化。进而在延迟可控的情况下提升高吞吐量，实现一个全功能的收集器（新生代和老年代）

G1能使用多核的性能降低STW的时间

### 6.4.2 工作模式

垃圾优先（Garbage First）

1、将整个堆分成不同的Region。并将其分配给Eden、Survivor0、Survivor1、老年代。

2、G1监控每个Region中垃圾堆积（回收能释放的空间和回收所需要的时间等）。在后台维护一个优先列表

3、每次需要回收的时候，根据允许的收集时间来计算出合理的回收方式使回收能获取收益最大的Region。



### 6.4.3 优势

+ 并行和并发：

  并行：多个CPU可以一起进行GC来加快GC的速度。会短暂STW

  并发：有些操作可以和用户线程一起执行。

+ 分代收集：

  虽然还是分成老年代和年轻代。但是已经和之前的分代不一样，每个区域都可以不是连续的空间了。而是划分成不同的Region

  ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/G6Za7g.jpg)

+ 空间整合：

  空间上因为是分区，每次回收最小单位都是Region。所以针对每个Region的回收可以是复制算法。而整个大的堆可以看成是标记整理算法

+ 可限制的停顿时间：

  使用者可以指定在某个时间范围内，消耗在GC上的时间不超过多少

缺点：

1. 相对于CMS，G1比不上最好回收时间的CMS。但是整体来看会更优一些
2. 从经验上来看，**更大的内存G1的性能就更好**，平衡点在6～8GB。



### 6.4.4 参数设置

+ `-XX:UseG1GC`，设置使用G1
+ `-XX:G1HeapRegionSize`：设置每个Region的大小。需要是2的N次幂。一般1～32M
+ `-XX:MaxGCPauseMillis`设置期望达到的最大GC停顿时间指标，默认值是200ms
+ `-XX:ParallelGCThread`设置STW工作线程数的值，最大的是8
+ `-XX:ConcGCThreads`：设置并发标记的线程数。将 n 设置为并行垃圾回收线程数（ParallelGCThreads）的 1/4 左右。
+ `-XX:InitiatingHeapOccupancyPercent`：设置触发并发 GC 周期的 Java 堆占用率阈值。超过此值，就触发 GC，默认值是 45。

调优方式：

+ 开启G1垃圾回收器
+ 设置堆的最大内存
+ 设置最大的允许停顿时间
+ 测试来检测性能

JDK7开始允许正常使用，JDK9及其之后都默认使用。

### 6.4.5 分析

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/V0JJNh.jpg)



1. G1将整个堆划分成约2048个Region，每个Region的大小都是相同的，根据参数设置可能是1M、2M、4M、8M、16M、32M。每个Region只有一个角色（空了之后可以转变成其他角色）
2. 如果一个大对象的大小超过了1.5Region，就会被保存在Humongous中。如果一个H保存不下一个大对象，会找一个连续的H区域来存储。这个时候有可能会触发Full GC



**Remembered Set**记忆集，记录当前Region被哪些Region所引用，免除了YoungGC回收的时候还需要遍历Old区等情况

为了解决，堆中不同Region相互引用的时候（Eden被Old引用），进行YoungGC只回收Eden中的对象，但是这个对象被Old区引用着。不知道能不能回收。就又需要去检查Old区。

RSet就是记录每个Region中被其他Region的引用信息。所以回收的时候，就只用看看RSet中的引用信息就好了。



### 6.4.6 回收过程

回收过程包括四个环节

1. 年轻代GC（Young GC（MinorGC））并行独占

2. 年轻代GC+老年代并发标记过程（当堆内存使用达到一定值（默认 45%）时，开始老年代并发标记过程。）

3. 混合回收（Mixed GC）

4. Full GC也存在（单线程，独占式），提供一种GC的保护机制防止OOM

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/PsPpw3.jpg)



每个环节的具体实现[大佬的blog](https://blog.csdn.net/sj15814963053/article/details/122685365)



# 总结

1. 运行时数据区的总结：[宋老师的总结](https://www.bilibili.com/video/BV1PJ411n7xZ?p=101&spm_id_from=pageDriver)

---

# 面试题

1. JVM内存模型及每块的作用，其中更小的划分及作用分析？
2. Java8内存分代改进？
3. 堆和栈的区别，堆的结构，为什么使用两个survivor区？
4. Eden和Survior的比例分配？
5. 为什么要有老年代和新生代？
6. 什么时候会进入老年代？
7. 永久代中是否会有垃圾回收？

<br/><br/><br/><br/><br/><br/><br/><br/>

# 问题

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



# 附

JVM调优
说一下 JVM 调优的工具？
JDK 自带了很多监控工具，都位于 JDK 的 bin 目录下，其中最常用的是 jconsole 和 jvisualvm 这两款视图监控工具。

jconsole：用于对 JVM 中的内存、线程和类等进行监控；
jvisualvm：JDK 自带的全能分析工具，可以分析：内存快照、线程快照、程序死锁、监控内存的变化、gc 变化等。
常用的 JVM 调优的参数都有哪些？
-Xms2g：初始化推大小为 2g；
-Xmx2g：堆最大内存为 2g；
-XX:NewRatio=4：设置年轻的和老年代的内存比例为 1:4；
-XX:SurvivorRatio=8：设置新生代 Eden 和 Survivor 比例为 8:2；
–XX:+UseParNewGC：指定使用 ParNew + Serial Old 垃圾回收器组合；
-XX:+UseParallelOldGC：指定使用 ParNew + ParNew Old 垃圾回收器组合；
-XX:+UseConcMarkSweepGC：指定使用 CMS + Serial Old 垃圾回收器组合；
-XX:+PrintGC：开启打印 gc 信息；
-XX:+PrintGCDetails：打印 gc 详细信息。
调优命令有哪些？
Sun JDK监控和故障处理命令有jps jstat jmap jhat jstack jinfo

jps，JVM Process Status Tool,显示指定系统内所有的HotSpot虚拟机进程。
jstat，JVM statistics Monitoring是用于监视虚拟机运行时状态信息的命令，它可以显示出虚拟机进程中的类装载、内存、垃圾收集、JIT编译等运行数据。
jmap，JVM Memory Map命令用于生成heap dump文件
jhat，JVM Heap Analysis Tool命令是与jmap搭配使用，用来分析jmap生成的dump，jhat内置了一个微型的HTTP/HTML服务器，生成dump的分析结果后，可以在浏览器中查看
jstack，用于生成java虚拟机当前时刻的线程快照。
jinfo，JVM Conﬁguration info 这个命令作用是实时查看和调整虚拟机运行参数
调优工具
常用调优工具分为两类,jdk自带监控工具：jconsole和jvisualvm，第三方有：MAT(Memory AnalyzerTool)、GChisto。

jconsole，Java Monitoring and Management Console是从java5开始，在JDK中自带的java监控和管理控制台，用于对JVM中内存， 线程和类等的监控
jvisualvm，jdk自带全能工具，可以分析内存快照、线程快照；监控内存变化、GC变化等。
MAT，Memory Analyzer Tool，一个基于Eclipse的内存分析工具，是一个快速、功能丰富的Javaheap分析工具，它可以帮助我们查找内存泄漏和减少内存消耗
GChisto，一款专业分析gc日志的工具
说说你知道的几种主要的JVM参数
思路： 可以说一下堆栈配置相关的，垃圾收集器相关的，还有一下辅助信息相关的。

参考答案：

1）堆栈配置相关

java -Xmx3550m -Xms3550m -Xmn2g -Xss128k -XX:MaxPermSize=16m -XX:NewRatio=4 -XX:SurvivorRatio=4 -XX:MaxTenuringThreshold=0
1
-Xmx3550m： 最大堆大小为3550m。

-Xms3550m： 设置初始堆大小为3550m。

-Xmn2g： 设置年轻代大小为2g。

-Xss128k： 每个线程的堆栈大小为128k。

-XX:MaxPermSize： 设置持久代大小为16m

-XX:NewRatio=4: 设置年轻代（包括Eden和两个Survivor区）与年老代的比值（除去持久代）。

-XX:SurvivorRatio=4： 设置年轻代中Eden区与Survivor区的大小比值。设置为4，则两个Survivor区与一个Eden区的比值为2:4，一个Survivor区占整个年轻代的1/6

-XX:MaxTenuringThreshold=0： 设置垃圾最大年龄。如果设置为0的话，则年轻代对象不经过Survivor区，直接进入年老代。

2）垃圾收集器相关

-XX:+UseParallelGC-XX:ParallelGCThreads=20-XX:+UseConcMarkSweepGC -XX:CMSFullGCsBeforeCompaction=5-XX:+UseCMSCompactAtFullCollection：
1
-XX:+UseParallelGC： 选择垃圾收集器为并行收集器。

-XX:ParallelGCThreads=20： 配置并行收集器的线程数

-XX:+UseConcMarkSweepGC： 设置年老代为并发收集。

-XX:CMSFullGCsBeforeCompaction：由于并发收集器不对内存空间进行压缩、整理，所以运行一段时间以后会产生“碎片”，使得运行效率降低。此值设置运行多少次GC以后对内存空间进行压缩、整理。

-XX:+UseCMSCompactAtFullCollection： 打开对年老代的压缩。可能会影响性能，但是可以消除碎片

3）辅助信息相关

-XX:+PrintGC-XX:+PrintGCDetails
1
-XX:+PrintGC 输出形式:

[GC 118250K->113543K(130112K), 0.0094143 secs] [Full GC 121376K->10414K(130112K), 0.0650971 secs]

-XX:+PrintGCDetails 输出形式:

[GC [DefNew: 8614K->781K(9088K), 0.0123035 secs] 118250K->113543K(130112K), 0.0124633 secs] [GC [DefNew: 8614K->8614K(9088K), 0.0000665 secs][Tenured: 112761K->10414K(121024K), 0.0433488 secs] 121376K->10414K(130112K), 0.0436268 secs

怎么打出线程栈信息。
思路： 可以说一下jps，top ，jstack这几个命令，再配合一次排查线上问题进行解答。

参考答案：

输入jps，获得进程号。
top -Hp pid 获取本进程中所有线程的CPU耗时性能
jstack pid命令查看当前java进程的堆栈状态
或者 jstack -l > /tmp/output.txt 把堆栈信息打到一个txt文件。
可以使用fastthread 堆栈定位，fastthread.io/	



