# Exception和Error

都继承了Throwable类。顾都可以进行throw和catch类似的操作

含义上：

Error表示和虚拟机相关的异常，比如堆栈溢出，系统崩溃等

Exception表示业务性的异常，比如业务数据不对（Exception并不一定是坏事，一般开发期间exception会做一些兜底的工作）

用途不同：
Error用在检测系统异常的情况并进行通知的条件下。
Exception一般用在进行业务处理上

# try-with-resources 和 multiple catch

```java
try (BufferedReader br = new BufferedReader(…);
     BufferedWriter writer = new BufferedWriter(…)) {// Try-with-resources
// do something
catch ( IOException | XEception e) {// Multiple catch
   // Handle it
}

```

# 异常处理规范

+ 不输入业务性强的数据
+ 不捕捉太大的异常范围例如`Exception`


# final finally和finalize

+ final表示不可修改，修饰类的时候表示类不可以被继承扩展
+ finally表示异常的一种执行机制
+ finalize表示保证对象在被垃圾收集前完成特定资源的回收。已被废弃`@deprecated`


# 强引用、软引用和弱引用
这三个的作用就是来判断该对象是否可进行垃圾收集（可达性）

强引用就是还有引用的对象在活着，一定不能被回收的

软引用，只有在Jvm认为内存不足的时候才会去回收这部分

弱引用，可以收集该引用的对象

# String StringBuffer和StringBuilder


StringBuffer增加了类似append/add的方法可以拼接字符串到尾部，线程安全。

StringBuilder和前者的区别在于非线程安全的所以性能要高些


# 强类型和弱类型

就是不同类型的变量赋值的时候是否需要显示（强制）的进行类型转换

