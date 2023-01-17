# rocketMq如何保证数据的顺序执行

**原理**:同一个Queue是典型的FIFO模式,所以可以保证顺序性

**解决方案**:使用针对订单的订单号hash的方式进行运算,保证同一条订单的信息走到同一个MessageQueue中

**附加**针对重要的数据,也可以增加redis锁机制来保证一定的消费顺序消费的情况

如果这种顺序消息消费失败了,不能使用`CONSUMER_LATER`来将消费发送会broker进行重试消费,而是将整个queue中的信息都回馈回去进行重试.即**不能针对消息重试,而需要针对queue进行重试**

针对所有mq都适用的解决方案:针对不同的业务信息,创建多个队列.顺序的队列进行使用消息,也就是一个消费者是另一个数据的生产者

# 技术选型

| 技术     | 描述                                                | 缺点                                                         | 优点                                                      |
| -------- | --------------------------------------------------- | ------------------------------------------------------------ | --------------------------------------------------------- |
| rabbitMq | erlang开发,万级数据处理量                           | 消息大量堆积的情况下会影响整体性能<br>采用主从架构实现高可用 |                                                           |
| rocketMq | java开发,百万数据处理量,稳定,且有完整的集群搭建模式 | 采用分布式架构实现高可用broker管理                           | 1. 完整的集群搭建模式<br/>2. 在线业务的响应上做了优化处理 |
| kafka    | Scala开发                                           | 每秒钟消息数量没有那么多的时候，Kafka 的时延反而会比较高。所以，Kafka 不太适合在线业务场景。 | 日志丰富,性能最高                                         |
| activeMq | java开发,性能不如前三个                             | 社区不再维护                                                 | 稳定                                                      |

1. rocketMq 针对业务性逻辑处理效率要比kafka要好.kafka针对数据逻辑处理效率要更好
2. 对数据可靠性以及稳定性要求高的情况下使用rocketmq更好.





# rocketMq 消息被消费之后会立即删除吗

不会

消息会持久化到commitLog中,只是在消息消费完成之后会将状态进行变更

默认48小时后会删除不再使用的commitLog文件



# rocketMq 的消费模式

**集群消费**

> 一条消息会被同Group下的一个Consumer消费
>
> 多个Group消费同一个Topic,每个Group中都会有一个Consumer进行消费

**广播消费**

> 针对Group下的每个Consumer都会消费一遍

# rocketMq的push和pull

所有都是pull模式.虽然名义上有push模式,但是底层还是一种`长轮询机制`即拉取机制

# 为什么都是pull模式而没有push模式

consumer按照自己的需求以及自己的处理速度进行消费消息.

push的模式会忽略掉该消费者的本身消费压力的问题

# broker如何处理拉取请求的？

Consumer首次请求Broker

- Broker中是否有符合条件的消息

- 有 ->

- - 响应Consumer
  - 等待下次Consumer的请求

- 没有

- - DefaultMessageStore#ReputMessageService#run方法
  - PullRequestHoldService 来Hold连接，每个5s执行一次检查pullRequestTable有没有消息，有的话立即推送
  - 每隔1ms检查commitLog中是否有新消息，有的话写入到pullRequestTable
  - 当有新消息的时候返回请求
  - 挂起consumer的请求，即不断开连接，也不返回数据
  - 使用consumer的offset，



# 消息重复消费的问题

**原因**:

+ ACK

  消费者处理完成一个消息的消费之后.会返回一个offset给MQ,证明这个消息已经消费过了

  即consumer发送到broker的消息ACK请求并未成功(网络问题等)

+ 消费模式

  集群模式下,消息在broker中会保证相同group的consumer消费一次，但是针对不同group的consumer会推送多次

+ 生产者发送消息发送重复

  即生产者发送消息之后,没有接收到MQ返回的接受成功的标识,从而出现重试的情况

**解决方案**(幂等验证机制)

+ 数据持久化,进行幂等验证消费
+ redis的锁机制



# MQ延迟队列的原理

**RocketMq**

创建每个topic时,会生成 一个不可见的SCHEDULE_TOPIC_XXX的topic

1. 生产者在生产消息时指定延时消费
2. 消费者消费消息消费失败时返回`RECONSUMER_LATER`

消息延时消费上限之后,会放入`死信队列`中



**RabbitMq**

使用**死信队列**和**消息的TTL**

1. 消息设置过期时间(延时时间),放入queue1中.queue1不设置消费端
2. queue1中的消息,到了过期时间还没有消费,则会将其放入死信队列中
3. 针对这个死信息队列设置交换机,将信息倒入queue2中进行消费



# RocketMq的消息堆积怎么处理

1. 找到消息堆积的原因
2. 临时创建一个Topic,上线一个Consumer将消息从原有的Topic中倒入到另一个Topic中.保证线上业务的正常运作
3. 上线N台Consumer进行新的Topic的消息消费
4. 针对消息重试失败或者消息丢失了的情况.针对死信队列和commitLog进行处理



# rocketMq与分布式事务



# MQ写入磁盘数据(rocketMq、kafka)

1. 磁盘顺序写入

   顺序写入磁盘,即写在文件末尾

2. 零拷贝机制

   ![图片](img/640.webp)

kafka的数据写入磁盘操作是先写入os cache.(与写入内存相似.且是采用顺序磁盘写入)之后有操作系统自己决定什么时候写入磁盘.

# 如何保证MQ数据不丢失

1. producer的发送机制

   用阻塞式发送,只有发生成功获取的ok的返回标识才结束发送mq操作

2. broker的持久化机制

   采用1主多从的策略,同步复制和异步复制的方式，同步复制可以保证即使Master 磁盘崩溃，消息仍然不会丢失

3. consumer的offset机制

   Consumer自身维护一个持久化的offset（对应MessageQueue里面的min offset），标记已经成功消费或者已经成功发回到broker的消息下标

   如果Consumer消费失败，那么它会把这个消息发回给Broker，发回成功后，再更新自己的offset

   如果Consumer消费失败，发回给broker时，broker挂掉了，那么Consumer会定时重试这个操作



# rabbitmq消息丢失

1. 创建queue指定durable,也就是持久化的
2. 生产消息的时候也指定持久化

在还没有将消息送入mq的时候,如果宕机会丢失



# MQ高可用性

## rabbitmq高可用性

三种模式

1. 单机模式,一台mq在生产活动
2. 普通集群模式,即多台mq,但是每个queue只在一台mq上进行生产消费.但是其他mq上会有这个queue的元信息(配置信息)
3. 镜像集群模式,queue的元数据和业务数据都会在多台mq中进行同步



## kafka的高可用性

kafka和rocketMq都是使用broker进行管理的.所以本身就具有高可用