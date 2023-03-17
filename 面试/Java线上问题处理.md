# 问题

[Java各种问题](https://blog.csdn.net/JavaShark/article/details/125300646)

## CPU资源占用满了

**Java-CPU过满**

原因：

+ 死循环     jstack
+ 频繁GC     jstat
+ 上下文切换过多 vmstat

解决方案

第一步、使用top命令看到是哪个进程ID占用cpu资源过多

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/68f185214b827072bd351b627993bb65.png)

第二步、使用`top -Hp pid`，"top -Hp 29706"获取线程占用情况的PID。

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/6f04b6a0611cb81c3e9e2f45e02349d3.png)

第三步、将占用最高的线程tid转换成16进制`printf '%x\n' nid`printf '%x\n' 30309

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/4667794917dac5464a08a26329e74f08.png)

第四步、使用jstack将对应线程的堆栈信息输出出来`jstack pid |grep 'nid' -C5 –color`（16进制是四位，不够前面补充0x）

```
 # 将该进程的信息输出到txt文件中
 jstack -l 进程ID > ./jstack_result.txt
 # 使用线程号定位到代码
 cat jstack_result.txt |grep -A 100  7665
```

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/303f28318244ce3fb05f18f0d91e7c75.png)

然后就是分析代码问题。解决问题重启服务

**Mysql-CPU过满**

原因：

1、并发大

2、Sql查询性能低，没使用索引

3、开启慢查询日志记录

解决方案：

1、在mysql客户端中使用`show processlist;`查看正在运行的线程，同时可以看到操作的语句等

2、对语句进行分析，是否没有建立索引，是否需要建立缓存。进行操作即可

## 磁盘问题

`df -hl`

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203102805.png)



## 内存问题

+ OOM。每次请求都 new 对象，导致大量重复创建对象；进行文件流操作但未正确关闭；手动不当触发 gc；ByteBuffer 缓存分配不合理等都会造成代码 OOM。
+ GC 问题
+ 堆外内存

`Exception in thread "main" java.lang.OutOfMemoryError: unable to create new native thread`

没有足够的内存用于栈的分配。一般是代码未进行shutdown等。使用jstack、jmap定位到代码进行查看修改

`Exception in thread "main" java.lang.OutOfMemoryError: Java heap space`

堆内存已经达到最大，可能有内存泄漏。从代码层面查找问题jstack、jmap。

**Caused by: java.lang.OutOfMemoryError: Meta space**

元空间不足，可能的原因是资源未关闭，数组引用使用异常等（类加载的太多了）

**Exception in thread "main" java.lang.StackOverflowError**

栈溢出，方法内的常量，局部变量等有使用问题。死循环等。jmap -dump:format=b,file=filename pid进行查看



在启动参数中指定-XX:+
HeapDumpOnOutOfMemoryError来保存 OOM 时的 dump 文件。但是主要要定时删除，防止磁盘被压满

## 方法区“内存溢出”OOM

方法区的内存就是使用的主机内存，所以查看主机内存发现使用率特别高的时候，就说明Jvm的方法区占用了太多。

一般是因为内存泄漏（用了内存没有释放），导致的频繁full GC（会产生STW），继而导致系统响应慢。最后主机内存使用完毕，系统崩溃。

排查方法（找到Full GC的dump文件）：

（1）通过`jps`查找java进程id。
（2）通过`top -p [pid]`发现内存占用达到了最大值
（3）`jstat -gccause pid 20000` 每隔20秒输出`Full GC`结果
（4）发现`Full GC`次数太多，基本就是内存泄露了。生成`dump`文件，借助工具分析是哪个对象太多了。基本能定位到问题在哪。

产生原因实例：

1、使用流资源（socket流、文件流），未释放

```java
try {
    BufferedReader br = new BufferedReader(new FileReader(inputFile));
    ...
    ...
} catch (Exception e) {
    e.printStacktrace();
}
```

## JVM调优

### IO密集型和CPU密集型

第一步：合理调整年轻代和老年代的分配比例

对于【IO密集型】可以将【年轻代】空间加大些，因为大多数对象都是在年轻代灭亡。

【CPU密集型】可以将【老年代】空间加大，对象的存活时间会更长些。

> CPU密集，表示一个逻辑需要进行大量的计算和上下文切换等，这个时候对象存活时间长。
>
> IO密集，表示接口请求量很大，但是不关注业务处理时间。这个时候对象的存活时间短，但是对象量大

第二步：合理使用各种垃圾回收期。

主要还是在G1上，如果说机器是多核CPU，使用G1垃圾回收器的效率更高，STW的时间也更低。



























# 常见linux系统查看信息命令

[常见问题及各个查看命令](http://www.senlt.cn/article/411974217.html)

free：查看内存

```bash
free -m 
-m 的意思是M字节来显示内容。
```

top：查看CPU运行情况

df：查看磁盘使用情况

dstat：查看网络占用情况

jvm工具

```shell
jps：查询当前机器所有JAVA进程信息
jmap：输出某个 Java 进程内存情况（如产生那些对象及数量等）
jstack：打印某个 Java 线程的线程栈信息
jinfo：用于查看 jvm 的配置参数
```



