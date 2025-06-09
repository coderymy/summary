# IO多路复用

用户态和内核态

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230207163551.png)

传输层之上是用户态（运行用户程序），传输层之下是内核态（运行操作系统程序，操作硬件）。

## BIO

服务端一般就是`读取数据` 然后 `处理数据` 最后`返回数据` `关闭链接`
但是 我们建立链接的时候 数据**还没有到达用户态**，也就是此时数据不一定传输完成了。那么我们服务端的读数据 也就被阻塞了（我们程序发起io调用，如果内核态 没有准备好，那么我们程序是在io 阶段被阻塞的，也就是我们平常说的系统卡了）。此时就引出我们第一个概念：`阻塞IO`

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230207160017.png)

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230207160030.png)

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230207160050.png)



**不理解可以看下面的链接中的动图**

blocking IO ，当我们的客户端发起请求的时候，服务端就会开启一个线程，专门为这个客户端提供对应的读写操作，只要客户端发起了，这个服务端的线程就一直保持存在，就算客户端啥也不干，那也在那里开着，就是玩。

同步阻塞IO，创建Socket链接之后，一直阻塞监听事件或者是read读事件。直到有客户端连接或事件发送数据。

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230207153848.png)

缺点：

1、每一个client建立链接之后，都需要创建一个线程与server进行业务处理。如果client有上千个，就需要上千个线程（jdk1.4之前就是这样的）

2、系统阻塞的时候，会造成资源的浪费。



## NIO

NoBlock IO，同步非阻塞IO，一个线程可以处理多个请求连接。适用于连接数目较多，但是连接较短。

简单来说，**BIO之前是一个线程处理一个请求（包括接受数据，处理业务逻辑等）。现在专事交给专人干**。

+ 服务端接收到请求之后，接受数据是一部分线程在处理。
+ 接受完数据之后交给业务线程去处理业务。
+ 再有其他的线程控制链接等。

BIO的时候将read （`系统`提供的`read`函数）展开来，可以发现这个read 分成`两个`部分：

1. 数据从外部流入网卡然后走到内核缓冲区
2. 然后用户缓冲区再去读取（服务端进行读取使用）

此时将这两部分拆成两个线程去处理。以防止后面的逻辑线程一直阻塞等待数据到内核缓冲区。

但是后面的业务处理还是需要数据，所以第二步还是一直轮训等待数据。这个时候还是大量的线程在等待

所以就创建了一个专门的线程来遍历所有的内存缓冲区数据，将其存储起来。后面的业务直接去取这里面的数据就行了。这就是多路复用器。

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230207154909.png)

缺点：

需要不停地遍历集合中有无事件在等待

## IO多路复用程序

多路复用的思想： 是 在 非阻塞 io 的基础上进行优化的，也就是对于 read 第一部分 `预处理阶段` 是`非阻塞`的。（可以理解为，我们告诉系统那些在等待，等系统处理好了 在通知 系统，我们再去调用io 读取）

**select函数模型和poll函数模型**

在NIO的基础之上，对预处理进行优化。所有的socket状态交给系统管理，程序仍然去遍历哪个socket的状态变更了，就去处理哪个socket。

进程通过告诉多路复用器（内核）（也就是select函数和poll函数）所有的socket号，多路复用器再去获取每一个socket的状态（是否准备好数据），当程序获取到某个socket数据准备好了，则去该socket号上进行处理对应的事件，read事件或者是recived事件。（补充select函数与poll函数的区别是，前者底层是数组，所以有最大连接数的限制，后者是链表，无最大连接数的限制）

缺点：

同样与NIO相同，需要遍历所有socket



**epoll函数模型**

**将用户轮训判断socket状态是否准备好。变成内核接收到数据之后，通过异步IO的方式将事件唤醒（通知用户态）**



![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230207161608.png)

总结：

+ BIO：一个socket链接一个线程全程处理
+ NIO：将socket链接、数据读取、业务处理等分成多个部分。每部分多个线程，轮训判断前面的逻辑处理完了该部分的线程去处理
+ AIO：将BIO的轮训判断变成了主动通知

Tomcat 8.0默认为NIO模式

学习自：

+ https://blog.51cto.com/u_9411970/5006824

+ https://blog.csdn.net/xujingyiss/article/details/120317475
+ https://blog.csdn.net/Squid87/article/details/123452472
+ **重点**：https://www.cnblogs.com/zhangxiaoji/p/16152141.html
+ **动图**：https://zhuanlan.zhihu.com/p/470778284