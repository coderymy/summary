# 问题

1、rocketmq的架构结构

> rocketmq的架构主要突出在broker集群上
>
> broker集群实现方式
>
> 1、单机
>
> 2、多master：同一个topic的queue平均分配在每个master上。如果宕机该master上的消息全部丢失
>
> 3、多master多slave：slave作为master的消息备份和主备切换
>
> 主备数据同步的时候涉及几个概念
>
> **数据复制**
>
> master与slave之间的关系
>
> + 同步复制：master接收到生产者消息，只有通知到slave并返回成功master才返回生产者成功
> + 异步复制：master接收到生产者消息之后直接ACK。之后通过异步的方式通知slave（降低系统写入延迟，效率高，但是出现异常可能会丢失消息）
>
> **刷盘策略**
>
> 主机内部内存与磁盘之间的关系
>
> 消息发送到broker内存后消息持久化到磁盘的方式
>
> - 同步刷盘：当消息持久化到broker的磁盘后才算是消息写入成功。
> - 异步刷盘：当消息写入到broker的内存后即表示消息写入成功，无需等待消息持久化到磁盘。（降低系统写入延迟，效率高，但是出现异常可能会丢失消息）

2、rocketmq的messageQueue

3、broker、namespace、messageQueue、offset等

4、如何保证消息不丢失，发送方、broker、接收方三角度

5、刷盘机制

6、pull和push

7、重复消费问题

8、rocketMQ的分布式事务逻辑

> 1.业务方保存本地事务记录，并初始化状态。
>
> 2.业务方调用sendMessageInTransaction发送半消息到MQ的RMQ_SYS_TRANS_HALF_TOPIC队列。
>
> 3.MQ执行成功，回调业务方executeLocalTransaction方法，也就是业务方的业务逻辑。
>
> 4.业务方返回事务状态给MQ，
>
> 1. commit: 塞一条消息进REAL_TOPIC真实队列，等待消费者消费。
> 2. commit/rollback：添加一条消息进RMQ_SYS_TRANS_OP_HALF_TOPIC队列，代表已处理消息。
> 3. unknow：根据一定的频率回查业务方本地事务状态。
>
> 5.MQ内部有定时任务，轮询比较halfoffset、opset,判定哪些未处理（无结果）消息，并回查业务方本地事务状态。
>
> 6.MQ->业务方, 执行checkLocalTransaction方法，查询本地事务状态。返回事务状态给MQ就是步骤4.

9、rocketMQ延迟消息原理



# 1、broker集群

NameServer每隔10s检测一次Broker的心跳时间，120s没有发送的Broker就认定为宕机；broker每隔30s向NameServer发送一个心跳包并携带时间戳

生产者在发送消息之前先从NameServer获取Broker服务器的地址列表，然后 根据负载算法从列表中选择一台broker发送消息。生产者每**30s**向NameServer更新Topic

### 数据复制与刷盘策略

**数据复制**

master与slave之间的关系

+ 同步复制：master接收到生产者消息，只有通知到slave并返回成功master才返回生产者成功
+ 异步复制：master接收到生产者消息之后直接ACK。之后通过异步的方式通知slave（降低系统写入延迟，效率高，但是出现异常可能会丢失消息）

**刷盘策略**

主机内部内存与磁盘之间的关系

消息发送到broker内存后消息持久化到磁盘的方式

- 同步刷盘：当消息持久化到broker的磁盘后才算是消息写入成功。
- 异步刷盘：当消息写入到broker的内存后即表示消息写入成功，无需等待消息持久化到磁盘。（降低系统写入延迟，效率高，但是出现异常可能会丢失消息）

### 多master

多个master构成，没有slave。**同一个Topic的Queue平均分配在各个master上**

+ 优点：配置简单。磁盘配置为RAID10（保障内存能写入磁盘），同步刷盘（保障消息不会从生产的角度上丢失）消息不会丢失
+ 缺点：宕机期间该server上的消息无法恢复

### 多master多slave

[特点及区别](https://blog.csdn.net/weixin_43882788/article/details/124865506)

**异步复制**

在配置了RAID磁盘阵列的情况下，一个master一般配置一个slave即可。master与slave的关系是主备关系，即master读写请求，而slave消息的备份与master宕机后的角色切换。

异步复制即前面所讲的`复制策略`中的`异步复制策略`

该模式的最大特点之一是，**当master宕机后slave能够`自动切换`为master**。不过当master宕机后，这种异步复制方式可能会存在少量消息的丢失问题。

>  对于Master的RAID磁盘阵列，若使用的也是异步复制策略，同样也存在延迟问题，同样也可能会丢失消息。但RAID阵列的秘诀是微秒级的（因为是由硬盘支持的），所以其丢失的数据量会更少。

**同步复制**

该模式是`多Master多Slave模式`的`同步复制`实现。该模式与`异步复制模式相比`，优点是消息的安全性更高，不存在消息丢失的情况。但性能要略低。

该模式存在一个大的问题：对于目前的版本，Master宕机后，Slave`不会自动切换`到Master。



总结：

多master的目的是：负载broker上topic的请求（单点变多点同时分布式支持高并发）。

带上slave的目的是：防止master怠机导致master上的消息延时，同时保障消息可靠性。还做到了读写分离防止压力太大。

使用RAID10阵列的目的是：降低刷盘效率问题，保障异步刷盘模式下消息丢失的问题

### 最佳实践

一般会为Master配置RAID10磁盘阵列，然后再为其配置一个Slave。即利用了RAID10磁盘阵列的高效、安全性，又解决了可能会影响订阅的问题。

> 1 ）RAID磁盘阵列的效率要高于Master-Slave集群。因为RAID是硬件支持的。也正因为如此，所以RAID阵列的搭建成本较高。
>
> 2 ）多Master+RAID阵列，与多Master多Slave集群的区别是什么？
> 1.多Master+RAID阵列，其仅仅可以保证数据不丢失，即不影响消息写入，但其可能会影响到消息的订阅。但其执行效率要远高于`多Master多Slave集群`
> 2.多Master多Slave集群，其不仅可以保证数据不丢失，也不会影响消息写入。其运行效率要低于`多Master+RAID阵列`



# 2、如何保证全链路数据不丢失

RocketMQ 通过多种机制来保证全链路数据不丢失：

1. **内存映射文件存储** RocketMQ 将消息存储在内存映射文件中，当消息被写入到内存中后，会通过同步刷盘的方式将消息持久化到磁盘。这样即使系统崩溃或重启，也能够保证消息不会丢失。
2. **主从同步复制** RocketMQ 支持主从同步复制模式，将主节点的消息同步到从节点中，从而保证消息的高可用性。在主节点写入消息时，同时将消息同步到从节点中，如果主节点发生故障，从节点可以顶替主节点继续提供服务，确保消息的可靠性。
3. **多副本存储** RocketMQ 通过多副本存储机制，将消息存储在多个节点中，这样即使某个节点发生故障，也可以通过其他节点提供服务，确保消息的可靠性。
4. 顺序写入 RocketMQ 的消息写入是顺序写入的，这样可以保证消息的顺序性。同时，RocketMQ 支持自定义顺序器，可以根据业务逻辑将消息发送到指定的队列中，保证消息的顺序性。
5. **消息确认机制** RocketMQ 提供了消息确认机制，消费者在消费消息后，需要向消息队列发送确认消息，以确保消息已经被成功消费。如果消息没有被确认，RocketMQ 将会重新投递消息，直到消息被成功消费为止。

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/7H24ZO.png)

生产者消息不丢失：发送**事务消息**（消息发送之前，生产者会先发送half进行broker的可用性确认），失败重试机制

写入磁盘：异步写入改成同步写入，生产者发送消息之后只有得到broker的ack，且broker刷盘机制改成同步刷盘，消息复制改成同步复制。保证只有写入磁盘才返回消息发送成功

磁盘消息：使用磁盘RAID阵列保证磁盘信息的多级备份，保证不丢失

消费者消费消息：拉取消息，只有消息处理结束之后才返回成功。

> Producer发送消息阶段
>
> 1通过采用同步发送消息到broker，等待broker接收到消息过后返回的一个确认消息，虽然效率低，但是时丢失几率最小的方式，异步1和单向消息发送丢失的几率比同步消息丢失的几率大。
>
> 2发送消息失败或超时则进行重试。
>
> 3broker提供多master模式【即使某台broker宕机了，换一台broker进行投递，保持高可用】
>
> ===》采用同步消息和失败重试和多master模式
>
> Broker处理消息阶段
>
> 手段四：提供同步刷盘的策略【等待刷盘成功才会返回producer成功】
>
> 当数据写入到内存中之后立刻刷盘(同步的将内存中的数据持久化到磁盘上)，
>
> 手段五：提供主从模式，同时主从支持同步双写
>
> 主从broker都同步刷盘成功，才返回producer一个确认消息。
>
> ===》采用同步刷盘+broker主从模式，支持同步双写
>
> Consumer消费消息阶段
>
> consumer默认提供的是At least Once（**Consumer先pull【主动拉取Broker中的信息】 消息到本地，消费完成后，才向服务器返回ack（消费成功的消息--acknowledge）**）机制
>
> 手段6 broker队列中的消息消费成功，才返回一个确认消息给broker。
>
> 手段7 当消息消费失败了，进行消费消息重试机制（保证幂等就行了。）
>
> ===》采用先消费，在返回一个确认消息+消息重试。

事务消息：

1、生产者发送half消息，当broker返回half消息的响应成功之后，生产者开始执行本地事务的代码

2、当生产者本地代码执行完成之后，发送给broker/broker回查当前事务是否commit。如果broker发现commit了，就将消息释放出去供消费者消费

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/uigeYB.jpg)



# 3、如何保证消息有序

保证发送的消息都进入同一个MessageQueue：可以在发送者发送消息时指定一个MessageSelector对象，让这个对象来决定消息发入哪一个MessageQueue。

实现方式

1、接口上增加注解，选定顺序消费

2、实现**MessageQueueSelector**接口，重写里面的选择算法。保证顺序消费

# 4、如何处理大量积压的消息？

如果Topic下的MessageQueue配置得是足够多的，那每个Consumer实际上会分配多个MessageQueue来进行消费。这个时候，就可以简单的通过增加Consumer的服务节点数量来加快消息的消费，等积压消息消费完了，再恢复成正常情况。

如果messageQueue数量与consumer一致还是积压，可以



# 5、消息的消费模式有哪几种

**集群消费**
一条消息只会被同Group中的一个Consumer消费
多个Group同时消费一个Topic时，每个Group都会有一个Consumer消费到数据

![输入图片说明](https://bright-boy.gitee.io/technical-notes/rocketmq/images/QQ%E6%88%AA%E5%9B%BE20220208141053.png)

**广播消费**

一条消息会被group下所有消费者消费一遍

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/mv3P6V.jpg)

# 6、pull和push

pull就是客户端去broker获取消息。不断的请求，请求不到就结束过一段时间再请求。

**push**就是主动推送给消费者消息，本质是对pull的包装，建立长链接（长轮询），服务端一旦有数据就会将数据发送给客户端。

长轮询的方式：客户端请求broker获取消息，如果broker没有消息就挂起这个链接并不返回，直到客户端超时或者有消息才返回。

优缺点：

> push

最常用的模式

优点在于，数据的同步及时。

缺点在于服务端不知道客户端的承受能力是多少容易出现数据的堆积在客户端

> pull

优点在于对客户端的压力不大，客户端能承受多少就拉取多少

缺点在于无法评估拉取的时间间隔。





# 7、RocketMq的存储机制了解吗？

RocketMq采用文件系统进行消息的存储，相对于ActiveMq采用关系型数据库进行存储的方式就更直接，性能更高了

RocketMq与Kafka在写消息与发送消息上，继续沿用了Kafka的这两个方面：顺序写和零拷贝

1）顺序写
我们知道，操作系统每次从磁盘读写数据的时候，都需要找到数据在磁盘上的地址，再进行读写。而如果是机械硬盘，寻址需要的时间往往会比较长而一般来说，如果把数据存储在内存上面，少了寻址的过程，性能会好很多；
但Kafka 的数据存储在磁盘上面，依然性能很好，这是为什么呢？
这是因为，Kafka采用的是顺序写，直接追加数据到末尾。实际上，磁盘顺序写的性能极高，在磁盘个数一定，转数一定的情况下，基本和内存速度一致
因此，磁盘的顺序写这一机制，极大地保证了Kafka本身的性能
2）零拷贝
比如：读取文件，再用socket发送出去这一过程

buffer = File.read
Socket.send(buffer)

传统方式实现：
先读取、再发送，实际会经过以下四次复制
1、将磁盘文件，读取到操作系统内核缓冲区Read Buffer
2、将内核缓冲区的数据，复制到应用程序缓冲区Application Buffer
3、将应用程序缓冲区Application Buffer中的数据，复制到socket网络发送缓冲区
4、将Socket buffer的数据，复制到网卡，由网卡进行网络传输

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/W0SNOq.jpg)

传统方式，读取磁盘文件并进行网络发送，经过的四次数据copy是非常繁琐的
重新思考传统IO方式，会注意到在读取磁盘文件后，不需要做其他处理，直接用网络发送出去的这种场景下，第二次和第三次数据的复制过程，不仅没有任何帮助，反而带来了巨大的开销。那么这里使用了零拷贝，也就是说，**直接由内核缓冲区Read Buffer将数据复制到网卡**，**省去第二步和第三步的复制**。

那么采用零拷贝的方式发送消息，必定会大大减少读取的开销，使得RocketMq读取消息的性能有一个质的提升

此外，还需要再提一点，零拷贝技术采用了MappedByteBuffer内存映射技术，采用这种技术有一些限制，其中有一条就是传输的文件不能超过2G，这也就是为什么RocketMq的存储消息的文件CommitLog的大小规定为1G的原因

小结：RocketMq采用文件系统存储消息，并采用顺序写写入消息，使用零拷贝发送消息，极大得保证了RocketMq的性能

# 8、RocketMq的存储结构是怎样的？

如图所示，消息生产者发送消息到broker，都是会按照顺序存储在CommitLog文件中，每个commitLog文件的大小为1G

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/B3iJVW.jpg)

CommitLog-存储所有的消息元数据，包括Topic、QueueId以及message

CosumerQueue-消费逻辑队列：存储消息在CommitLog的offset

IndexFile-索引文件：存储消息的key和时间戳等信息，使得RocketMq可以采用key和时间区间来查询消息

也就是说，rocketMq将消息均存储在CommitLog中，并分别提供了CosumerQueue和IndexFile两个索引，来快速检索消息

# 9、RocketMq性能比较高的原因

RocketMq采用文件系统存储消息，采用顺序写的方式写入消息，使用零拷贝发送消息，这三者的结合极大地保证了RocketMq的性能





# 10、业务场景问题



## 重复消费

> 原因

+ 消息重发
+ 分布式消息重复股消费

```sequence
title: kafka消息重复消费
participant 生产者 as producer
participant kafka
participant zookeeper as zk
participant 消费者 as consumer


producer -> kafka: 1. 发送每台消息都会带着一个offset(坐标,顺序)

kafka-> consumer: 2. 消费者消费消息是按照顺序消费
consumer-> zk: 3. 消费者消费了消息之后会返回提交offset
zk-> kafka: 4. 同步

```

消费者并不是消费一条数据就提交offset,而是定时定期去提交

如果在已消费、未提交前出现了问题,就会出现kafka认为这条数据并没有消费的情况,下一次消费的时候kafka会将这个offset对应的消息再发给消费者



> 解决方案

幂等:

业务逻辑进行处理

redis锁进行处理

关键业务数据的mysql写入唯一性约束



## 顺序消费

> 原因

rabbitMQ,一个队列,多个消费者,消费消息可能会因为性能不一致等原因导致顺序与生产顺序不一致

kafka,能内部保障写入一个partition的数据是顺序的(在写入的时候指定一个key,这样可以保障所有同样key的数据被同一个partition消费)。kafka不顺序消费的情况是消费者内部的多线程处理

rocketmq，能保证同一个Queue是顺序消费的。所以实现顺序消费的基础就是将消息都发送到该topic的一个Queue中。

> 解决方案

使用针对订单的订单号hash的方式进行运算,保证同一条订单的信息走到同一个MessageQueue中

kafka

+ 使用相同的key,保证进入同一个partition中
+ 出队之后放入内存队列中,保证写入内存队列顺序写入,这样就会进入同一个线程处理

针对重要的数据,也可以增加redis锁机制来保证一定的消费顺序消费的情况



如果这种顺序消息消费失败了,不能使用`CONSUMER_LATER`来将消费发送会broker进行重试消费,而是将整个queue中的信息都回馈回去进行重试.即**不能针对消息重试,而需要针对queue进行重试**

**终极：针对所有mq都适用的解决方案:针对不同的业务信息,创建多个队列.顺序的队列进行使用消息,也就是一个消费者是另一个数据的生产者**





## 消息丢失

1. 生产者弄丢数据<br>
   ribbitMQ使用transaction和confirm模式来保证生产者不会丢消息<br>

   tacnsaction机制：发送消息前"channel.txSelect()"开启事务。消息发送没出现异常"channel.txCommit()"提交事务。出现任何异常"channel.txRollback()"回滚事务<br>
   缺点：吞吐量下降

   confirm机制：所有被生产者生产的消息都会被**加上唯一ID**，如果消息被正确消费了ribbitMQ就发送一个ACK给生产者。如果消息没有正确消费ribbitMQ就返还一个NACK给生产者

2. 消息队列丢失数据
   使用消息持久化磁盘的方法<br>

   1. 开启持久化磁盘的方法
      1. durable设置成true
      2. 发送消息的时候将deliveryMode=2
   2. 设置之后，和confirm一起使用，会在本地持久化存储生产者生产的消息。并在意外岱机之后重启恢复数据

3. 消费者丢数据
   一般是采用了自动确认消息模式。这种模式下，消费者会自动确认收到的消息。然后ribbitMQ会删除这个消息。如果这个时候消费者出现异常没有完整处理业务逻辑，就会出现数据丢失<br>
   解决方法：手动确认消息即可
   <br>
   关闭rabbitMQ提供的自动ACK消息确认机制，改为消费者处理完消息之后,
    手动ACK(基于tcp的ack事务包)

> ###### rabbitmq消息丢失
>
> 1. 创建queue指定durable,也就是持久化的
> 2. 生产消息的时候也指定持久化
>
> 在还没有将消息送入mq的时候,如果宕机会丢失

## 高可用

架构上broker的多master多slave

## 延时队列

开源版本的RocketMQ仅支持设置的18个等级的时间延时。不支持任意时间

实现原理：

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/IDTNNu.jpg)





在broker启动的时候会启动对应数量（对应延时等级的个数）的定时器TImer。每个定时器绑定一个延迟等级，并按照延迟等级每隔一段时间检测一次消息是否到期。

1. 消息发送到对应Topic的queue中，写入commitlog后会检查是否携带了延时队列的标示。
2. 将对应延时消息发送到该Topic的`SCHEDULE_TOPIC_TOPICNAME`中。
3. 定时器会每次检索该延迟等级的第一个消息是否到期，如果到期就执行该消息将该消息重新分发commitlog的该正常队列中
4. 就可以正常执行该消息的消费。



重点在于：延时是在进行消费分发时候做的

## 消息清理

commitlog默认过期时间为三天，按照文件来清理

## 消息堆积

两种情况：

如果queue本身便比consumer多。那么多上线几个consumer可以缓解消息堆积的问题

如果queue本身不多于consumer，那么上线多个consumer是没有用的。此时应该上线代码将该topic中的数据转移到另一个topic中，然后开多个queue与consumer进行消费处理



## 分布式事务

Rocketmq实现分布式事务。

通过向broker发送half消息。只有在TM获取到所有都准备好的指令之后，才会向broker发送commit/rollback消息，这个时候这个消息才能被消费者看到，才来让其他的所有RM都执行对应的逻辑进行提交

RocketMQ提供了事务消息，可以保证消息发送和消息事务的原子性。在RocketMQ中，事务消息分为三个阶段：发送消息、预提交和提交或回滚。

当生产者发送一个事务消息时，会先发送一个半消息到Broker。半消息只有消息的一部分内容，不可消费，同时Broker会返回一个事务ID。生产者接下来会根据业务逻辑执行本地事务，如果事务成功则调用`commit`方法，此时Broker会将半消息标记为可消费状态。如果事务失败，则调用`rollback`方法，此时Broker会删除半消息。

当半消息被标记为可消费状态后，消费者就可以消费该消息了。如果在预提交阶段后发生了故障，比如生产者宕机或网络故障，Broker会定时检查该消息是否被提交或回滚。如果消息被提交，则Broker会将消息正式标记为已提交，如果消息被回滚，则Broker会删除半消息。

事务消息的使用场景比较广泛，比如订单支付场景，可以将订单状态更新和发送支付成功消息封装在一个事务中。如果订单状态更新失败，则回滚该事务，不会发送支付成功消息，从而保证了数据的一致性。



RocketMQ的事务消息可以通过使用**TransactionListener**接口来实现，该接口包括**执行本地事务、回查事务状态和提交事务**三个方法。当消息发送时，先执行本地事务，如果本地事务执行成功，则将消息发送到消息队列中；如果本地事务执行失败，则回滚消息发送操作。当消息发送成功后，RocketMQ会启动一个定时任务，在一定时间内（默认5分钟）轮询回查事务状态方法，以确保消息被正确处理。如果回查事务状态方法返回失败，则会回滚消息发送操作；如果返回成功，则提交事务，消息正式被消费者消费。



## 批量消息

批量发送的消息不能是延时消息或者事务消息。默认消息体最大上线为4M，可配置（需配置生产者和消费者两端）



# 11、queue的分配策略

+ 平均分配

+ 环型平均分配，这样就可以将queue依次分配，不用计算每个consumer分配几个queue的问题

+ 一致性hash算法：最常见的形式了，将queue进行取模运算。适用于频繁变化consumer数量的情况

+ 同机房策略

  ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/tXm2ul.jpg)







-----



[面试题](https://blog.csdn.net/qq_42877546/article/details/125425061)

# 1. 四大消息队列

| 特性           | activeMQ                                           | rabbitMQ                                                     | rocketMQ                                                     | kafka                                                        |
| -------------- | -------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 单机吞吐量     | 万级-1                                             | 万级别-2                                                     | 10万级-3                                                     | 10万级-4                                                     |
| 消息可靠性     | <font color='red'>有小概率<br/>会丢消息</font>     |                                                              | 通过配置0丢失                                                | 通过配置0丢失                                                |
| 优点           | 很成熟 <br>业内使用很多                            | 性能较高<br>自带管理后台<br>社区活跃                         | 性能高<br>默认支持分布式架构<br>Java开发好维护<br><font color="red">支持复杂业务场景</font> | 性能高<br>                                                   |
| 缺点           | 有小概率会丢失消息<br>社区维护也较少<br>吞吐量较小 | 性能不够高<br>不默认支持一些复杂的业务操作，需要自己实现     |                                                              | 依赖于Zookeeper                                              |
| 特点           |                                                    |                                                              | 顺序消费、pull和push、分布式                                 | 零拷贝。partition                                            |
| 高可用解决方案 | 不支持                                             | 三种模式：<br>单机<br>普通集群：相当于主备机器，但是业务数据不备份。<br>镜像集群：所有MQ上都有全套的业务数据（通信同步压力大） | 基于broker的分布式实现管理。对broker进行多主多从配置         | 与rocketmq类似：通过broker进程进行同步调度,会将消息分摊到不同的partition上 |
|                |                                                    |                                                              |                                                              |                                                              |

业务上推荐使用RocketMq：自身是支持分布式的架构可实现三高。针对各种复杂业务提供了解决方案（延时队列、顺序消费、集合数据等）

中间件上（日志采集，数据分析等）推荐使用kafka：稳定高效以及可靠的持久性特点。



# 2. 工作原理

## 2.1 消息生产过程

1. Producer发送消息之前，去NameServer获取Topic路由信息的请求。返回topic的`路由表`和`broker列表`

   > 路由表：Map<TopicString,List<QueueData>>，其中QueueData是一个Broker中所有该topic的Queue的集合
   >
   > Broker列表：就是所有Broker组实例（一个Master和一个Slave）组成的Map集合

2. 根据Queue的选择算法，选择一个Queue用于后续消息存储

   > 无序消息
   >
   > 轮询算法
   >
   > 最小投递延迟算法（统计每次投递的投递时间，选择延迟最小的那个Queue。）

3. 进行一些消息的基本处理（压缩4M以下，校验等）

4. 向选出的Queue的Broker发送RPC请求发送消息



## 2.2 消息存储

存储在`/store`目录下

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/0uwJK8.jpg)



### commitlog

存放着mappedFile文件。文件名为当前文件第一条的offset。文件大小为1G上限

也就是该文件中存储的就是整个消息的各个信息。所有topic的消息都顺序放在该文件中



### consumequeue

/consumequeue/${topicName}/${queueId}

用来记录每个Queue的消息索引

### index

其中写入了消息中包含`key`的消息。提供给其他操作需要使用key进行查询的时候使用，快速索引查找



### 零拷贝机制

[大佬零拷贝机制](https://www.likecs.com/show-204169190.html)

正常进行文件传输的时候，需要两个步骤

1. 从用户态切换到内核态：去将磁盘的文件拷贝到内核态缓冲区
2. 内核态切换到用户态：将文件从内核态缓冲区拷贝到用户缓冲区
3. 用户态切换到内核态：用户缓冲区拷贝到socket缓冲区
4. 内核态切换到用户态：发送文件

经历了三次拷贝，四次状态切换

操作磁盘文件需要用户态和内核态之间的切换

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/3FnGSF.png)



**零拷贝是指CPU不需要在应用内存和内核内存之间拷贝数据消耗资源。**

#### mmap

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/sPkl34.png)

原理就是映射一块内存分配区域，给用作共享缓冲区。

增加内核态和用户态都能操作的“共享缓冲区”

1. 磁盘到共享缓冲区
2. 共享缓冲区到socket缓冲区

减少了一次拷贝

RocketMq中关于零拷贝的实现就给予mmap。将文件映射一个内存地址以供调用，真实的拷贝发生在共享缓冲区之间传输的操作上

#### sendfile

原理就是不经过用户态直接在内核态上进行数据拷贝。

## 2.5 Rebalance

重新平衡机制：目的就是在于新增消费者之后，将该topic中的所有queue进行平衡分配一下。

问题：在于重新分配的间隙可能会产生**重新消费**、**消费暂停**的问题





# 3. 深入理解rocketmq

## 3.1 Queue（队列）

消息存储的物理结构，也就是**分区**（kafka中的partition）。

存在的目的：就是为了区分出来消费者。一个topic一般有多个queue。一个消费者针对同一个TOPIC只能消费一个Queue。（不考虑消费者组的问题）

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/dAYp23.png)

> ps：如果消息堆积，增加消费者能解决问题吗？
>
> 如果MessageQueue的数量大于消费者的数量，增加消费者肯定是可以解决问题的！

## 3.4 rocketmq特点

NameServer：类似于分布式里面的consul、eureka、zookeeper这种注册中心。

- `生产者`发送消息到`NameServer`
- `NameServer`将该消息持久化存储
- `消费者`订阅需要的主题消息
- `NameServer`将消息推送push到`消费者`（也可以`消费者`主动去`NameServer`pull）

broker与nameserver的心跳机制：

```
在启动broker的时候，向nameserver进行注册。
nameserver与每台broker保持长连接，并间隔30s检测broker是否存活，如果检测不到，即将其在路由注册表中移除。
```

多台NameServer之间

```
为了实现高可用，通常会建立多台NameServer，但是相互之间不进行通信。
```

producer、NameServer、broker的路由机制？？

```
每次生产者生产消息时就去NameServer获取服务器地址列表，再通过负载算法选择一台Broker发送消息。
```











# 4. RocketMQ面对几大问题

## 基于磁盘操作的RocketMq性能问题

**零拷贝机制**

**PageCache机制**：页缓存机制

RocketMQ中，无论是消息本身还是消息索引，都是存储在磁盘上的。其不会影响消息的消费吗？当然不会。其实RocketMQ的性能在目前的MQ产品中性能是非常高的。因为系统通过一系列相关机制大大提升了性能。

首先，RocketMQ对文件的读写操作是通过`mmap零拷贝`进行的，将对文件的操作转化为直接对内存地址进行操作，从而极大地提高了文件的读写效率。

其次，consumequeue中的数据是顺序存放的，还引入了`PageCache的预读取机制`，使得对consumequeue文件的读取几乎接近于内存读取，即使在有消息堆积情况下也不会影响性能。

> PageCache机制，页缓存机制，是OS对文件的缓存机制，用于加速对文件的读写操作。一般来说，程序对文件进行顺序读写的速度几乎接近于内存读写速度，主要原因是由于OS使用PageCache机制对读写访问操作进行性能优化，将一部分的内存用作PageCache。
>
> 1)写操作：OS会先将数据写入到PageCache中，随后会以异步方式由pdæush（page dirty æush)内核线程将Cache中的数据刷盘到物理磁盘
> 2)读操作：若用户要读取数据，其首先会从PageCache中读取，若没有命中，则OS在从物理磁盘上加载该数据到PageCache的同时，也会顺序 对其相邻数据块中的数据进行预读取。

RocketMQ中可能会影响性能的是对commitlog文件的读取。因为对commitlog文件来说，读取消息时会产生大量的随机访问，而随机访问会严重影响性能。不过，如果选择合适的系统IO调度算法，比如设置调度算法为Deadline（采用SSD固态硬盘的话），随机读的性能也会有所提升。





## 与kafka的对比

相同点：

+ 都采用了分区的概念，rocketmq中是queue；kafka中是partition
+ 都采用了offset的概念进行消息顺序操作。

不同点：

+ kafka中没有tag的概念
+ kafka中无索引文件







# 0. 研习《RocketMQ技术内幕》

## 1. rocketMQ的设计目标

+ 架构模式

  发布订阅的模式

+ 顺序消息

  保证发送在同一个TOPIC中的消息在消费的时候是按照发送的顺序进行消费的

  在分布式的情况下如何保证？

+ 消息过滤

  在同一个TOPIC下设置了TAG和`selectorExpression`等元素来帮助消费者进行消息的过滤获取想要的消息

+ 消息存储

  所有TOPIC消息都存储在一个文件中，同时设置过期时间和存储空间报警机制

+ 高可用性

  分布式的架构、消息同步/异步刷盘模式

+ 消费的低延时

  使用长轮询机制（push）

+ 消息回溯

  使用offset的概念帮助进行消息的回溯

+ 消息堆积

  磁盘存储，所以面对消息堆积压力不是很大

+ 定时消息

  为了减少服务端的压力，只允许使用固定模式的时间进行设置定时消息

+ 消息重试

  使用offset

## 2. 路由中心——NameServer

目的：为了保证客户端出现故障能够快速进行切换使用，从而避免服务宕机和消息丢失

，

生产者与broker、NameServer：生产者在发送消息之前先从NameServer获取Broker服务器的地址列表，然后 根据负载算法从列表中选择一台broker发送消息。

NameServer之间：不会相互通信，所以可能会出现短时间的数据不一致性

broker与NameServer：Broker在启动时向所有NameServer注册。	Broker 启动之后会向所有 NameServer 定期（每 **30s**）发送心跳包，包括：IP、Port、TopicInfo，NameServer 会定期扫描 Broker 存活列表，每**10s**检测一次心跳包如果超过 **120s** 没有心跳则移除此 Broker 相关信息，代表下线。

生产者与NameServer：每**30s**向NameServer更新Topic





## 3. 集群、主从

brokerId=0表示主节点

brokerId>0表示从节点

## 4. 消息发送

+ 同步
+ 异步
+ 单向

消息发送者首次向topic发送消息会去nameServer验证是否有这个topic。有就将这个topic缓存到本地缓存中。然后每隔30s去nameServer验证下本地缓存的topic状态





​	





























