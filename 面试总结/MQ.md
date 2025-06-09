# 概念

## 延时队列

实现方式：

1、代码层面实现：当判断是个延时消息的时候，发送到的MQ是对应的代理MQ。代理MQ消费端消费消息之后，将其放入定时任务中，由定时任务触发执行

2、时间轮和deley-file：将消息写入delayfile中或者直接写入时间轮（按照到期时间区分）。最终都是在时间轮中通过每秒进行判断消息是否到期从而写到commitlog中。只要写入到commitlog就会被消费

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230221094046.png)

3、延时队列：将消息发送到对应时间阶段的延时队列中。这个时候有一个**Timer定时器**回去使用对应频次轮训延时队列，到期了就将消息发送到指定的队列中（写入commitlog），即可完成消费



## RocketMQ的存储结构

[推荐看该文：存储结构](https://mp.weixin.qq.com/s?__biz=MzU0OTE4MzYzMw==&mid=2247508558&idx=5&sn=f798822d3b03d74f670e505e9b699df2&chksm=fbb12bb0ccc6a2a6a613f0f0169f3bb9b8e884758ddbc4d0fad2a15731c97d4bbca58ece5f01&scene=27)

文件存储，主要包括三方面

1、commitLog：存储消息主题和消息的元数据（topic等）。在commitlog文件夹中，使用20位来表示文件，每个文件1G，第一个文件是`00000000000000000000`每条消息的偏移量是对应消息的大小。

2、`consumerQueue`：每个`topic`对应的`Queue`，存储的是`commitlog`中的`offset`。在`consumerQueue`的文件夹中，有对应所有的Topic名称的文件夹，每个文件夹下是对应Queue（默认四个）的文件夹。`consumerQueue`相当于`commitLog`的一个索引文件

3、Index文件：除了使用consumerQueue快速查询文件（基于offset），还可以基于Message Key、Unique Key、Message Id。所以对应的查询条件都有对应的index索引文件来帮助快速查询到消息。



## broker集群

三种模式，两个保障：单机模式、master集群模式、master-slave集群模式；同步刷盘，同步复制

针对broker的开源版本

多master-slave集群：多master是为了分摊每个topic的Queue，从而做到负载均衡。slave用作备份master的数据，保障消息不丢失，但是不能防止单点故障（master挂掉之后，该master-slave只支持从slave中取数据，消息发送不到该组合中。slave不会晋升master去处理消息）。

**在5.0的版本之后，新增了主从切换的机制。基于Dleger Controller监听心跳机制来进行主从的选举。**



## 顺序消费

发送端：实现SelectorQueue接口，返回一个QueueMq。发送的时候带上即可指定发送到一个

消费端：分布式锁保证该消费是一次一次消费。



## 消息不丢失

1、发送端：使用half消息，只有确保broker有效才发送。当一个broker失败了，下一次发送到另一个broker中

2、同步刷盘同步复制

3、消费端，代码处理重试以及只有处理完成才主动ACK

