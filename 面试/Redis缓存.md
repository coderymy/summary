# 1. 问题

1、redis如何实现分布式锁

> 1、setnx保证key存在就获取不到锁，key不存在就获取得到锁
>
> 2、使用lua脚本保证多个rediskey操作的原子性。（上锁setnx返回1成功，0失败。不具备设置过期时间的参数需要再用pexpire设置过期时间，释放锁需要先判断是否能get到，然后再delete）
>
> 3、使用watchdog保证锁过期的时候监听锁是否需要**续约**（watchdog其实是一段程序，因为如果不设置过期时间（在redis服务端宕机的情况下，可能导致死锁）；如果设置过期时间（又会出现过期时间已经过了但是业务代码还没处理完成的情况）。所以需要watchdog来每隔十秒判断上锁（其实就是调用java的方法判断上锁的那个线程是否存活，如果存活就将锁的过期时间重置））
>
> lua脚本：
>
> > 上锁
> >
> > ```lua
> > 	if redis.call('setnx', KEYS[1], ARGV[1]) == 1 then redis.call('pexpire', KEYS[1], ARGV[2]) return 1 else return 0 end
> > ```
> >
> > 释放锁
> >
> > ```lua
> > if redis.call('get', KEYS[1]) ~= nil then return redis.call('del', KEYS[1]) else return 0 end
> > ```
>
> watchdog代码，使用redission工具。
>
> 还有一种使用方式
>
> `set key value ex|px expireTime nx`，其中ex|px（ex表示秒、px表示毫秒）表示设置过期时间，nx表示只有不存在的时候才能设置成功（存在则失败）。返回的ok则表示成功，nil则表示失败`set order12138 1 ex 100 nx`

2、redis线程模型，单线程为什么还这么快「内单多高」

> 1、纯内存操作
>
> 2、没有线程切换的开销
>
> 3、IO多路复用机制提升IO效率
>
> 4、高效的数据结构，全局hash表（结构和hashMap基本一致，只是在链表过高的时候进行rehash）及各种高效数据结构，跳表、压缩列表、链表等

3、redis集群如何保证单线程运行

主从模式下，只有一个master供请求，所以还是单机的单线程运行。cluster模式下，每个master上保存的数据都不一致，所以查找还是到具体的master上找，所以还是单机的单线程运行

4、redis淘汰策略

> 1、全局LRU，最近最少使用
>
> 2、有过期时间的LRU
>
> 3、全局随机
>
> 4、有过期时间的随机
>
> 5、过期时间最短的
>
> 6、全局使用次数最少
>
> 7、有过期时间使用次数最少
>
> 8、不淘汰

5、redis过期策略

> 1、定期删除
>
> 2、惰性删除
>
> 一般合起来使用

6、如何保证缓存和持久化的一致性

> 1、先写缓存，更新mysql，成功/失败都再重新获取mysql数据去更新缓存。
>
> 2、先写mysql，成功之后再更新缓存。
>
> 3、监听mysql的binlog的变化，发现数据变化就更新缓存。

7、存储结构-跳表

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/5NdFBp.png)

相当于进行二分查找，数据使用双向链表链接，然后上层使用索引进行分配（空间换时间）

8、持久化技术

AOF和RDB

9、缓存雪崩和击穿

> 雪崩：短时间内大量key都失效导致大量数据打到了mysql
>
> 解决方案：
>
> 1、动态分配key的过期时间
>
> 2、过期时间加随机值
>
> 击穿：大量的mysql不存在的key访问，导致查询不到没法存缓存，下回进来还是直接访问mysql
>
> 解决方案：
>
> 1、布隆过滤器，使用guava中的布隆过滤器，将获取到的数据存储再一个列表中，这个列表只能告诉你这个数据存不存在。（难以落地）
>
> 2、null值存储的办法，使用spring-cache，开启null依然缓存。对于方法返回null存储15秒缓存即可解决。
>
> [缓存击穿雪崩落地实现方案](https://www.cnblogs.com/rjzheng/p/16165822.html)

10、redis6.0之后的多线程，网络请求和数据操作是单线程的，其余的集群数据同步、持久化等都是另外的线程去处理的

11、redis的数据类型，以及每种数据类型的使用场景

>**分析**：是不是觉得这个问题很基础，其实我也这么觉得。然而根据面试经验发现，至少百分八十的人答不上这个问题。建议，在项目中用到后，再类比记忆，体会更深，不要硬记。基本上，一个合格的程序员，五种类型都会用到。
>**回答**：一共五种
>(一)String
>这个其实没啥好说的，最常规的set/get操作，value可以是String也可以是数字。一般做**一些复杂的计数功能的缓存。**
>(二)hash
>这里value存放的是结构化的对象，比较方便的就是操作其中的某个字段。博主在做**单点登录**的时候，就是用这种数据结构存储用户信息，以cookieId作为key，设置30分钟为缓存过期时间，能很好的模拟出类似session的效果。
>(三)list
>使用List的数据结构，可以**做简单的消息队列的功能**。另外还有一个就是，可以利用lrange命令，**做基于redis的分页功能**，性能极佳，用户体验好。
>(四)set
>因为set堆放的是一堆不重复值的集合。所以可以做**全局去重的功能**。为什么不用JVM自带的Set进行去重？因为我们的系统一般都是集群部署，使用JVM自带的Set，比较麻烦，难道为了一个做一个全局去重，再起一个公共服务，太麻烦了。
>另外，就是利用交集、并集、差集等操作，可以**计算共同喜好，全部的喜好，自己独有的喜好等功能**。
>(五)sorted set
>sorted set多了一个权重参数score,集合中的元素能够按score进行排列。可以做**排行榜应用，取TOP N操作**。另外，参照另一篇[《分布式之延时任务方案解析》](https://www.cnblogs.com/rjzheng/p/8972725.html)，该文指出了sorted set可以用来做**延时任务**。最后一个应用就是可以做**范围查找**。



# 2. 底层存储结构

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/2nWrry.png)

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/MyKFQC.png)

String：简单字符串

List：双向链表、压缩列表

Hash：哈希表、压缩列表

ZSet：跳表、压缩列表

Set：数组、哈希表

其实对应关系很简单呢，list、hash、zset在数据量小的时候都使用压缩列表。数据量大的时候才使用自己的结构（使用object encoding key查看key的具体底层实现类型）

+ 简单动态字符串
+ 双向链表，双向指针的链表结构
+ 压缩列表：基于数组的基础上，增加一些附加信息（热点元素的偏移量），快速查找到第一个元素和最后一个元素
+ 哈希表：hash表加链表的结构
+ 跳表：基于二分查找的思想，实现的一种类似树的结构。查询的时候每次都可以排除掉一半的不匹配信息
+ 整数数组：数组形式

## 压缩列表

列表的基础上进行压缩。然后增加一些偏移量的字段。适合存储数据量小的数据（hash、list、zset在数据量小的时候都是用这个结构）

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/pyJupm.png)

zltail：记录最后一个元素的偏移量。所以可以很快的找到第一个元素和最后一个元素。

## 跳表

Zset 对象能支持范围查询（如 ZRANGEBYSCORE 操作），这是因为它的数据结构设计采用了跳表，而又能以常数复杂度获取元素权重（如 ZSCORE 操作），这是因为它同时采用了哈希表进行索引。

哈希表和跳表是顺序插入的，保证两边的数据是一致的

zset结构使用的底层数据结构，双向链表的基础上加上了多层索引

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/5NdFBp.png)

看起来原理和B+树类似



# 3. redis集群

[实战博文](https://www.cnblogs.com/rjzheng/p/10360619.html)

三种模式

## 主从复制模式

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/UgQ6N8.jpg)

主进行读写，复制给从服务器，从服务器只读。

> 产生的原因

```
1. 容错性(只有一台的情况,一旦挂掉就会影像业务逻辑)
2. 并发性(一台的并发能力必然很低,读的能力会很差)
```

> 使用主从的结果

```
1. 数据冗余
2. 读写分离
```

> 原理

```
1. 主节点负责读/写,从节点只能进行读操作
2. 可以一主多从
3. 数据同步:一般初次会讲所有主节点数据同步到从节点,后续都是补发更新的数据,并且主从节点有长链接的心跳机制
```

## 哨兵模式

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/vaN493.jpg)



增加哨兵保证系统的可用性，在master宕机的时候，哨兵自动选举来将一个slave提升到master的节点以供使用

> 产生的原因

```
在搭建主从之后,主节点只有一个,一旦发生错误之后就没有主节点信息了
```

> 存在的作用

1. 监控：检查主从服务器的正常运行，出现问题会通过API来向管理员发送监控结果
2. 故障转移：出现问题时，哨兵机制会使用流言协议获取下线状态，并在剩下的从节点中通过<font color='red'>选举算法</font>选出一个节点充当主节点
3. IP统一：不用再直接访问master节点而是访问哨兵的IP地址

> 哨兵原理

1. 每个`sentinel`会以心跳机制请求master、slave进行PING命令,如果一个实例响应超过设置的时间.
2. 当有足够数量的额sentinel确定master下线,就会认定下线,就会进行选举算法选举出新节点作为主节点

当使用哨兵模式之后,就不要再直接连redis的ip和端口了,而是访问哨兵的信息,由哨兵进行<font color='red'>转发</font>

## **Cluster**集群模式

为了防止主从复制模式数据的冗余问题。集群中一共有16384个hash槽，所有节点平分这些哈希槽。每个 key 通过 CRC16 校验后对 16384 取模来决定放置哪个槽。

Redis 客户端可以在任意一个 Redis 实例发出请求，如果所需数据不在该实例中，通过重定向命令引导客户端访问所需的实例。

特点：

1、互为主从，备份复制数据A作为D从，B作为A的从，C作为B的从等。同时master节点还可以单独形成集群模式，外挂多个slave服务器以备故障

2、开启6379和16379两个端口，16379作为节点之间的信息通信

3、无中心化结构。

缺点：

1、扩容需要手动导入槽

2、只能使用0数据库



+ 自动将数据进行分片,每个master上放一部分数据

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230221142252.png)

创建每个redis的服务端进行cluster的时候,需要给每个服务端分配hash槽

![](https://img-blog.csdnimg.cn/20181128141957764.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1MTUyMDM3,size_16,color_FFFFFF,t_70)

每个redis的key经过一系列算法获取到对应需要访问的hash槽在哪个redis服务端上

### 分布式寻址算法

针对cluster集群模式..每个请求进来的时候都需要按照一定的算法来判断是去哪个节点获取数据

这个算法有以下三种

**hash算法**(按照key的hash值/节点数来判断去哪个取,但是如果一旦一个节点挂了,那么算法就废了)

**一致性hash算法**

![](https://gitee.com/shishan100/Java-Interview-Advanced/raw/master/images/consistent-hashing-algorithm.png)

**hash槽算法**

cluster默认拥有16384个hash槽,在注册每个节点的时候,指定这个节点管理的hash槽是哪个范围.即可后续寻址

## redis sharding

客户端分片，也就是在客户端访问服务端的时候（jedis）进行hash算法去判断访问哪个节点

# 4. redis带来的业务问题

## redis的击穿(穿透)

> 出现原因

```
出现大量redis中的key不存在的请求,导致创建了太多的jdbc链接从而跳过了redis的缓存机制,给数据库带来太大的压力
```

> 解决办法

```
1. 增加数据规则的验证,只有符合规则的key才进行查询,防止人为恶意的进行请求
2. 数据库中查询为null的对应key值信息也进行缓存
```

## redis的缓存雪崩

> 出现原因

```
同一时间点大量的缓存数据失效,导致透过redis直接请求数据库出现问题
```

> 解决办法

```
1. 均匀分配缓存的过期时间(业务逻辑角度)
2. 创建多级缓存来辅助修改(springBoot+redis+Ecache)
3. 使用分布式锁的逻辑,保证获取数据库资源有一个一定的上限,超过上限就进行等待知道锁释放
4. redis的高可用性
```

# 5. redis线程模型

从前往后

1、多个socket链接通过IO多路复用程序压入工作队列

2、工作队列依次出队，通过文件事件分配器分配处理客户端的请求



包括五个基本组成部分

+ 多个socket的链接
+ IO多路复用程序
+ 执行队列
+ 文件事件分派器
+ 文件事件处理器
  + 连接应答处理器
  + 命令请求处理器
  + 命令回复处理器

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/RGMCw5.jpg)



![](https://gitee.com/shishan100/Java-Interview-Advanced/raw/master/images/redis-single-thread-model.png)

1. Server socket 监听到客户端发的请求,会产生一个AE_REABLE的事件
2. IO多路复用程序将AE_REABLE事件压入队列中,依次执行
3. <font color='red'>文件事件分派器</font>从队列中取数据交给<font color='red'>链接应答处理器</font>
4. 链接应答处理器创建与客户端的长链接socket,并将这个长链接和需要执行的命令给到<font color='red'>命令请求处理器</font>
5. 命令请求处理器进行命令执行,执行完成之后将socket的长链接与<font color='red'>命令回复处理器</font>关联
6. 文件事件分派器使用对应的socket关联与命令回复处理器的执行断开socket请求

线程模型的意义

1. 使用非阻塞IO多路复用程序,所以支持高并发
2. 使用的文件事件分派器是单线程的,所以redis是单线程的

# 6. redis淘汰策略

1、有过期时间最近最少使用

2、全体数据最近最少使用

3、有过期时间随机淘汰

4、全体数据随机淘汰

5、有过期时间，距离最短淘汰

6、不淘汰

7、有过期时间使用次数最少淘汰

8、全体数据使用次数最少淘汰



|            | 全体数据                                                     | 有设置过期时间的数据                                         |
| ---------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| LRU        | allkeys-lru：全体数据中找**最近**使用最少的数据进行淘汰（时间） | volatile-lru：有设置过期时间的数据中找使用最少的数据进行淘汰（最近的时间使用） |
| random     | allkeys-random：全体数据中进行淘汰                           | volatile-random：设置了过期时间的数据中随机淘汰              |
| TTL        | ——                                                           | volatile-ttl：设置了过期时间，且距离过期越近淘汰率越高       |
| noeviction | 禁止所有数据淘汰（默认）                                     |                                                              |
| LFU        | allkeys-lfu：全体数据使用最不频繁淘汰（次数）                | volatile-lfu：设置了使用时间的数据中最不频繁使用的淘汰（次数） |



1. noeviction:**禁止驱逐数据**，当内存上限的时候，再添加数据会产生异常。从而保证数据不会丢失（默认）

2. **allkeys-lru: 全体数据中找最近使用最少的数据进行淘汰**

3. volatile-lru: 从**有设置过期时间的数据**中找最近**使用最少**的数据进行淘汰

4. allkeys-random: **全体数据**，**随机淘汰**

5. volatile-random: **设置过期时间的数据**，**随机淘汰**

6. volatile-ttl: 从**设置过期时间**的数据中，**随机**找一些数据淘汰。**距离过期时间越短，淘汰优先级越高**

4.0版本后增加以下两种：

7. volatile-lfu：从已设置过期时间的数据集(server.db[i].expires)中挑选最不经常使用的数据淘汰

8. allkeys-lfu：当内存不足以容纳新写入数据时，在键空间中，移除最不经常使用的key

Redis淘汰策略主要分为LRU淘汰、TTL淘汰、随机淘汰三种机制。

**LRU淘汰**

LRU(Least recently used，<font color="red">最近最少使用</font>)算法根据数据的历史访问记录来进行淘汰数据，其核心思想是“如果数据最近被访问过，那么将来被访问的几率也更高”。

在服务器配置中保存了 lru 计数器 server.lrulock，会定时(redis 定时程序 serverCorn())更新，server.lrulock 的值是根据 server.unixtime 计算出来进行排序的，然后选择最近使用时间最久的数据进行删除。另外，从 struct redisObject 中可以发现，每一个 redis 对象都会设置相应的 lru。每一次访问数据，会更新对应redisObject.lru。

在Redis中，LRU算法是一个近似算法，默认情况下，Redis会随机挑选5个键，并从中选择一个最久未使用的key进行淘汰。在配置文件中，按maxmemory-samples选项进行配置，选项配置越大，消耗时间就越长，但结构也就越精准。

> 手写LRU代码

```
//使用LinkedHashMap<K,V>
//Math.cell((cacheSize/0.75)+1,0.75f,true),最后一个true表示进行顺序的排序,最近访问的放在头部,最老访问的放在最后
//removeEldestEntry
//return size()>CACHE_SIZE表示大于制定的缓存时,就调用删除最老的数据
public class LruCache<K,V> extends LinkedHashMap<K,V> {

    private int size;

    public LruCache(int size){
        super(size,0.75f,false);
        this.size = size;
    }

    @Override
    protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
        return super.size() > size;
    }

    public static void main(String[] args) {
        LruCache<Object, Object> LruCache = new LruCache<>(3);
        LruCache.put(1,1);
        LruCache.put(2,2);
        LruCache.put(3,3);
        System.out.println(LruCache.keySet());

        LruCache.put(4,4);
        System.out.println(LruCache.keySet());
        LruCache.put(3,3);
        System.out.println(LruCache.keySet());
        LruCache.put(3,3)
        System.out.println(LruCache.keySet());
        LruCache.put(5,5);
        System.out.println(LruCache.keySet());
    }
}
```

**LRU和LFU的区别**：LRU侧重点在于这个Key距离当前时间多久没使用；LFU侧重点在于一段时间内使用了多少次这个Key

[大佬：Redis优化--LRU和LFU区别](https://blog.csdn.net/eafun_888/article/details/104714530)

**TTL淘汰**

也就是按照过期时间进行淘汰。距离过期时间越短，淘汰的优先级越高。

**随机淘汰**

在随机淘汰的场景下获取待删除的键值对，随机找hash桶再次hash指定位置的dictEntry即可。

Redis中的淘汰机制都是几近于算法实现的，主要从性能和可靠性上做平衡，所以并不是完全可靠，所以开发者们在充分了解Redis淘汰策略之后还应在平时多主动设置或更新key的expire时间，主动删除没有价值的数据，提升Redis整体性能和空间。

总结六种:

1. 不淘汰
2. 随机淘汰
3. 有过期时间的随机淘汰
4. 使用最少
5. 有过期时间的使用最少
6. 过期时间越短淘汰率越高

Redis实现LRU算法

随机取若干个key，然后按照访问时间排序，淘汰掉最不经常使用的数据。

为此，Redis给每个key额外增加了一个24bit长度的字段，用于保存最后一次被访问的时钟（Redis维护了一个全局LRU时钟lruclock:REDIS_LUR_BITS，时钟分辨率默认1秒）。

# 7. redis的过期策略问题

两者一起使用

+ 定期删除(定时器定时监视所有key，如果过期就删除)
+ 惰性删除(调用的时候检查到该key已过期,过期则删除（弥补上面定期删除可能会出现删除不及时的问题）)

定期删除+惰性删除：

**为什么数据过期之后,并不会直接将redis的内存删除掉(一个小时过期了百分之五十,但是内存还是那样)?**

```
两者一起使用的真实情况是：

redis默认每隔一段时间就随机抽取一些设置了过期时间的key检查是否过期,如果过期了就会删除.
注意这个地方是随机操作的

并不是key到时间就被删除掉,而是查询这个key的时候,redis在懒惰的检查一下.所以查的时候并查不到这百分之五十的key值信息,但是内存还是占用着
```

# 8. redis持久化

## RDB

在一段时间内有设置的数量的key更新就是横城一个快照

> 原理

快照的方式保存数据,每隔一段时间有固定多少key值发生变更,将数据进行快照备份一次

由父进程fork开启一个子进程，使用子进程进行I/O操作将内存中的快照保存在硬盘上

> 缺点

耗时,耗性能

> 实现

在 *`redis.windows.conf`* 配置文件中默认有此下配置：

```
save 900 1
save 300 10
save 60 10000
```

save 开头的一行就是持久化配置，可以配置多个条件（每行配置一个条件），每个条件之间是『或』的关系，*`save 900 1`* 表示 900 秒钟（15 分钟）内至少 1 个键被更改则进行快照，*`save 300 10`* 表示 300 秒（5 分钟）内至少 10 个键被更改则进行快照。

Redis 启动后会读取 RDB 快照文件，将数据从硬盘载入到内存。根据数据量大小与结构和服务器性能不同，这个时间也不同。通常将记录一千万个字符串类型键、大小为 1GB 的快照文件载入到内存中需要花费 20～30 秒钟。

但是 RDB 方式实现持久化有个问题啊：一旦 Redis 异常（突然）退出，就会丢失最后一次快照以后更改的所有数据。因此在使用 RDB 方式时，需要根据实际情况，调整配置中的参数，以便将数据的遗失控制在可接受范围内。

## AOF

每次支持数据的修改的时候，都将修改日志保存下来

> 原理

将操作日志保存下来,做的是增量保存.在重启的时候执行所有操作一遍

> 缺点

文件体积大,恢复速度慢

现在一般采用两者集合的方式来进行持久化。底层对这两种方案做了融合处理

> 实现

默认情况下 Redis 没有开启 AOF（append only file）方式的持久化，可以通过配置文件中的 *`appendonly`* 参数开启：

```
appendonly yes
```

开启 AOF 持久化后每执行一条会更改 Redis 中的数据的命令，Redis 就会将该命令写入硬盘中的 AOF 文件。AOF 文件的保存位置和 RDB 文件的位置相同，都是通过 *`dir`* 参数设置的，默认的文件名是 *`appendonly.aof`*，可以通过 *`appendfilename`* 参数修改：*`appendfilename appendonly.aof`*









# 9. 主从复制的原理

数据同步问题

#### 全量复制

1、主节点使用bgsave命令在子进程（fork）上生成RDB持久化的文件（dump.rdb）

2、通过网络master将文件发送到slave上，期间网络会受到影响

3、从节点删除所有数据，然后根据持久化文件重新生成从节点的数据。期间不可使用

#### 部分复制

1、主节点发起slaveof建立主从关系

2、从节点想master节点发送paync+上一次复制主节点ID+offset

​	上一次复制主节点ID保证增量的来源是一致的。offset保证增量是从哪增的

3、master返回之后，就可以从master的复制缓冲区（队列）依次执行命令进行复制

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/9xA7fu.png)







# 10. mysql与redis数据一致性解决方案

先操作缓存再操作数据库：

方案一（保证数据完全一致）：**缓存修改成一个特定值禁止访问**

先修改缓存（修改成一个设定值-999），然后修改数据库，然后再将缓存修改成正确的数据。

客户端发现缓存的数据是-999的时候，就休眠一会再重新访问。

方案二：**延时双删**。

先删除缓存，写入数据库，再休眠一段时间，再删除缓存。



先操作数据库再操作缓存：（缓存写失败的情况）

方案一：给缓存设置过期时间

方案二：引入MQ保证原子操作（mq**重试机制**）

方案三：**版本号**。数据库和redis中都存一个版本号。后台有一个程序不断的扫描这些关键数据的key，判断版本号是否一致，不一致就替换成版本最高的那个

---



# 11. redis的八种数据结构及使用场景

#### 1.String

> **常用命令:**  set,get,decr,incr,mget 等。

String数据结构是简单的key-value类型，value其实不仅可以是String，也可以是数字。 
常规key-value缓存应用； 

#### 2.Hash

> **常用命令：** hget,hset,hgetall 等。

hash 是一个 string 类型的 field 和 value 的映射表，hash 特别适合用于存储对象，后续操作的时候，你可以直接仅仅修改这个对象中的某个字段的值。 比如我们可以 hash 数据结构来存储用户信息，商品信息等等。比如下面我就用 hash 类型：

```
key=JavaUser293847
value={
  “id”: 1,
  “name”: “SnailClimb”,
  “age”: 22,
  “location”: “Wuhan, Hubei”
}

```


#### 3.List

> **常用命令:** lpush,rpush,lpop,rpop,lrange等

list 就是链表，Redis list 的应用场景非常多，也是Redis最重要的数据结构之一，比如微博的关注列表，粉丝列表，消息列表等功能都可以用Redis的 list 结构来实现。

Redis list 的实现为一个双向链表，即可以支持反向查找和遍历，更方便操作，不过带来了部分额外的内存开销。

另外可以通过 lrange 命令，就是从某个元素开始读取多少个元素，可以基于 list 实现分页查询，这个很棒的一个功能，基于 redis 实现简单的高性能分页，可以做类似微博那种下拉不断分页的东西（一页一页的往下走），性能高。

#### 4.Set

> **常用命令：**
> sadd,spop,smembers,sunion 等

set 对外提供的功能与list类似是一个列表的功能，特殊之处在于 set 是可以自动排重的（**不能重复**）。

当你需要存储一个列表数据，又不希望出现重复数据时，set是一个很好的选择，并且set提供了判断某个成员是否在一个set集合内的重要接口，这个也是list所不能提供的。可以基于 set 轻易实现交集、并集、差集的操作。

比如：在微博应用中，可以将一个用户所有的关注人存在一个集合中，将其所有粉丝存在一个集合。Redis可以非常方便的实现如共同关注、共同粉丝、共同喜好等功能。这个过程也就是求交集的过程，具体命令如下：

```
sinterstore key1 key2 key3     将交集存在key1内
```

#### 5.Sorted Set

> **常用命令：** zadd,zrange,zrem,zcard等


和set相比，sorted set增加了一个权重参数score，使得集合中的元素能够按score进行有序排列。

**举例：** 在直播系统中，实时排行信息包含直播间在线用户列表，各种礼物排行榜，弹幕消息（可以理解为按消息维度的消息排行榜）等信息，适合使用 Redis 中的 Sorted Set 结构进行存储。

队列模式:

list作为队列,rpush生产消息,lpop消费消息

#### 6. Geospatial,地理位置类型

#### 7. bitmap,位图类型(key:value(1,2))

#### 8. Hyperloglog,数学上的集合类型

# redis的事务

通过`MULTI`、`EXEC`、`WATCH`等命令实现事务。redis提供一种将请求打包执行，期间不会切换到别的client去执行命令。也就相当于事务开启期间就不会出现其他的读写操作。（mysql的串行化事务隔离级别）

redis支持事务，但是整体redis集群不支持事务

在 Redis 中，事务总是具有原子性（Atomicity）、一致性（Consistency）和隔离性（Isolation），并且当 Redis 运行在某种特定的持久化模式下时，事务也具有持久性（Durability）。

## 1. 事务的一般执行流程

```
1. 开启事务`MULTI`
2. 执行操作，也就是执行你需要进行的操作set等
3. 提交事务`EXEC`，会执行一并所有的操作一起提交
```

##  2. 使用SpringBoot+redis执行事务

```java
//1. 创建对应执行的RedisTemplate对象
@Autowired
StringRedisTemplate stringRedisTemplate
//2. 开启事务权限
stringRedisTemplate.setEnableTransationSupport(true);
//3. 开启事务
stringRedisTemplate.multi();
//4. 回滚
stringRedisTemplate.discard();
//5. 提交
stringRedisTemplate.exec();
```

如果开启事务，所有的命令只有在执行了exec。才会往redis中插入





# redis实现分布式锁

> 原理

1. redis是单线程的

> 如何实现

```
1.线程 A setnx(上锁的对象,超时时的时间戳 t1)，如果返回 true，获得锁。

2.线程 B 用 get 获取 t1,与当前时间戳比较,判断是是否超时,没超时 false,若超时执行第 3 步;

3.计算新的超时时间 t2,使用 getset 命令返回 t3(该值可能其他线程已经修改过),如果

t1==t3，获得锁，如果 t1!=t3 说明锁被其他线程获取了。

4.获取锁后，处理完业务逻辑，再去判断锁是否超时，如果没超时删除锁，如果已超时，不用处理（防止删除其他线程的锁）。

```

> 核心

<font color='red'>**`setnx`**</font>关键字,将key对应的资源锁定,set成功返回1,失败返回0

Java操作

使用Lua脚本实现

```java
@Component
public class RedisDistributedLock {

    private static final Logger LOGGER = LoggerFactory.getLogger(RedisDistributedLock.class);
    /**
     * 成功标识
     */
    private static final Long SUCCESS = 1L;
    /**
     * 订单锁前缀
     */
    private static final String LOCK_PREFIX = "xk:kc_order:lock:";
    /**
     * 锁过期时间
     */
    private static final int LOCK_EXPIRE = 200;
    /**
     * 加锁lua脚本
     */
    private static final String LOCK_SCRIPT = "if redis.call('setnx', KEYS[1], ARGV[1]) == 1 then redis.call('pexpire', KEYS[1], ARGV[2]) return 1 else return 0 end";
    /**
     * 释放锁lua脚本
     */
    private static final String RELEASE_LOCK_SCRIPT = "if redis.call('get', KEYS[1]) ~= nil then return redis.call('del', KEYS[1]) else return 0 end";
  
      @Resource
    RedisTemplate<String, Object> redisTemplate;
    /**
     * 服务器IP
     */
    String clientIP = "";
  
      /**
     * 启动初始化，获取服务器IP
     */
    @PostConstruct
    public void init() {
        InetAddress address = null;
        try {
            address = InetAddress.getLocalHost();
        } catch (UnknownHostException e) {
            LOGGER.error("地址获取错误", e);
        }
        if (null == address) {
            clientIP = "127.0.0.1";
        } else {
            clientIP = address.getHostAddress();
        }
        LOGGER.info("redis lock init...success,clientIP is {}", clientIP);
    }
  
  
      /**
     * 尝试获取锁
     *
     * @param lockName 业务名称:key(order_create:orderId)
     * @return true 成功获取锁，false 获取锁失败
     */
    public boolean tryLock(String lockName) {
        return tryLock(lockName, clientIP);
    }
  
  
      /**
     * 加锁
     *
     * @param lockName 业务名称:key(order_create:orderId)
     * @param value    值
     * @return boolean是否上锁
     */
    public boolean tryLock(String lockName, Object value) {
        return tryLock(lockName, value, LOCK_EXPIRE);
    }
  
  
      /**
     * 释放锁
     *
     * @param lockName 业务名称:key(order_create:orderId)
     * @return boolean是否上锁
     */
    public boolean releaseLock(String lockName) {
        String key = LOCK_PREFIX + lockName;
        RedisScript<Long> lockRedisScript = new DefaultRedisScript<>(RELEASE_LOCK_SCRIPT, Long.class);
        Long result = redisTemplate.execute(lockRedisScript, Collections.singletonList(key), clientIP);
        if (SUCCESS.equals(result)) {
            return Boolean.TRUE;
        }
        return Boolean.FALSE;
    }
  
  
    /**
     * 是否上锁
     *
     * @param lockName 业务名称:key(order_create:orderId)
     * @return boolean是否上锁
     */
    public boolean isLocked(String lockName) {
        String key = LOCK_PREFIX + lockName;
        Boolean ret = redisTemplate.hasKey(key);
        if (null == ret) {
            return false;
        }
        return ret;
    }

  
  
  
    /**
     * 获取锁的
     * @param lockName
     * @return
     */
    public Object getLockContent(String lockName) {
        String key = LOCK_PREFIX + lockName;
        return redisTemplate.opsForValue().get(key);
    }
  
}
```







## 对比redis与zookeeper实现分布式锁

edis实现分布式锁与Zookeeper实现分布式锁的区别

相同点

>  在集群的环境下，保证只允许有一个jvm进行执行

从技术上分析

Redis是nosql数据库，主要特点是缓存

Zookeeper是分布式协调工具，主要用户分布式解决方案

实现思路分析

获取锁

> Zookeeper，多个客户端（jvm）会在Zookeeper上创建同一个临时节点，因为Zookeeper节点命名路径保证唯一，不允许出现重复，只要谁能创建成功就能获取这个锁

> redis，多个jvm会在redis中使用setnx命令创建相同的一个key，因为redis的key保证唯一，不允许重复。只要谁先创建成功，谁就能获取锁

释放锁

> Zookeeper直接关闭 临时节点session会话连接，因为临时节点生命周期session会话绑定在一起，如果session会话连接关闭的话，就会使这个临时节点被删除

> 然后客户端使用事件监听，监听到临时节点被删除，就释放锁

> redis释放锁的时候，为了保证是锁的一致性问题，在删除锁的时候需要判断对应的value是否是对应创建的那个业务的id

死锁解决

Zookeeper使用会话有效方式解决死锁的现象

redis是对key设置有效期来解决死锁现象

性能上：

因为redis是nosql，所以redis比Zookeeper性能好 

可靠性

 Zookeeper更加可靠。因为redis有效求不是很好控制，可能会产生延迟

# 其余面试问题

## **一个字符串类型的值能存储最大容量是多少？**

512M

## **为什么 Redis 需要把所有数据放到内存中？**

Redis 为了达到最快的读写速度将数据都读到内存中，并通过异步的方式将数据写入磁盘。

所以 redis 具有快速和数据持久化的特征，如果不将数据放在内存中，磁盘 I/O 速度为严重影响 redis 的性能。

在内存越来越便宜的今天，redis 将会越来越受欢迎， 如果设置了最大使用的内存，则数据已有记录数达到内存限值后不能继续插入新值。

## **数据量大的时候,如何保证redis中缓存的都是热点数据**

使用的淘汰策略可以是LRU策略，可以实现淘汰最近最少使用的数据淘汰掉

## **Redis key 的过期时间和永久有效分别怎么设置？**

EXPIRE 和 PERSIST 命令

## **Redis 如何做内存优化？**

尽可能使用散列表（hashes），散列表（是说散列表里面存储的数少）使用的内存非常小，所以你应该尽可能的将你的数据模型抽象到一个散列表里面。

比如你的 web 系统中有一个用户对象，不要为这个用户的名称，姓氏，邮箱，密码设置单独的 key,而是应该把这个用户的所有信息存储到一张散列表里面。

## **Redis 回收进程如何工作的？**

一个客户端运行了新的命令，添加了新的数据。Redi 检查内存使用情况，如果大于 maxmemory 的限制, 则根据设定好的策略进行回收。一个新的命令被执行，等等。

所以我们不断地穿越内存限制的边界，通过不断达到边界然后不断地回收回到边界以下。

如果一个命令的结果导致大量内存被使用（例如很大的集合的交集保存到一个新的键），不用多久内存限制就会被这个内存使用量超越。

## **锁互斥机制**

那么在这个时候，如果客户端 2 来尝试加锁，执行了同样的一段 lua 脚本，会咋样呢？很简单，第一个 if 判断会执行“exists myLock”，发现 myLock 这个锁 key 已经存在了。接着第二个 if 判断，判断一下，myLock 锁 key 的 hash 数据结构中，是否包含客户端 2 的 ID，但是明显不是的，因为那里包含的是客户端 1 的 ID。

所以，客户端 2 会获取到 pttl myLock 返回的一个数字，这个数字代表了 myLock 这个锁 key的剩余生存时间。比如还剩 15000 毫秒的生存时间。此时客户端 2 会进入一个 while 循环，不停的尝试加锁。

## **watch dog 自动延期机制**

客户端 1 加锁的锁 key 默认生存时间才 30 秒，如果超过了 30 秒，客户端 1 还想一直持有这把锁，怎么办呢？

**简单！**只要客户端 1 一旦加锁成功，就会启动一个 watch dog 看门狗，他是一个后台线程，会每隔 10 秒检查一下，如果客户端 1 还持有锁 key，那么就会不断的延长锁 key 的生存时间。

# 问题

1. 为什么使用redis

2. redis的使用场景

3. redis的集群

4. redis的雪崩效应，穿透效应

5. redis实现分布式锁，与zk的区别

6. 一个字符串类型的值能存储最大容量是多少

   512M

7. 为什么 Redis 需要把所有数据放到内存中？

   Redis 为了达到最快的读写速度将数据都读到内存中，并通过异步的方式将数据写入磁盘。

   所以 redis 具有快速和数据持久化的特征，如果不将数据放在内存中，磁盘 I/O 速度为严重影响 redis 的性能。

   在内存越来越便宜的今天，redis 将会越来越受欢迎， 如果设置了最大使用的内存，则数据已有记录数达到内存限值后不能继续插入新值。

8. MySQL 里有 2000w 数据，redis 中只存 20w 的数据，如何保证 redis 中的数据都是热点数据？

   使用的淘汰策略可以是LRU策略，可以实现淘汰最近最少使用的数据淘汰掉

9. Redis 中的管道有什么用？

   一次请求/响应服务器能实现处理新的请求即使旧的请求还未被响应，这样就可以将多个命令发送到服务器，而不用等待回复，最后在一个步骤中读取该答复。

   这就是管道（pipelining），是一种几十年来广泛使用的技术。例如许多 POP3 协议已经实现支持这个功能，大大加快了从服务器下载新邮件的过程。

10. Redis key 的过期时间和永久有效分别怎么设置

    EXPIRE 和 PERSIST 命令

11. Redis 如何做内存优化？

    尽可能使用散列表（hashes），散列表（是说散列表里面存储的数少）使用的内存非常小，所以你应该尽可能的将你的数据模型抽象到一个散列表里面。

    比如你的 web 系统中有一个用户对象，不要为这个用户的名称，姓氏，邮箱，密码设置单独的 key,而是应该把这个用户的所有信息存储到一张散列表里面。

12. Redis 回收进程如何工作的？

    一个客户端运行了新的命令，添加了新的数据。Redi 检查内存使用情况，如果大于 maxmemory 的限制, 则根据设定好的策略进行回收。一个新的命令被执行，等等。

    所以我们不断地穿越内存限制的边界，通过不断达到边界然后不断地回收回到边界以下。

    如果一个命令的结果导致大量内存被使用（例如很大的集合的交集保存到一个新的键），不用多久内存限制就会被这个内存使用量超越。

13. 锁互斥机制

    那么在这个时候，如果客户端 2 来尝试加锁，执行了同样的一段 lua 脚本，会咋样呢？很简单，第一个 if 判断会执行“exists myLock”，发现 myLock 这个锁 key 已经存在了。接着第二个 if 判断，判断一下，myLock 锁 key 的 hash 数据结构中，是否包含客户端 2 的 ID，但是明显不是的，因为那里包含的是客户端 1 的 ID。

    所以，客户端 2 会获取到 pttl myLock 返回的一个数字，这个数字代表了 myLock 这个锁 key的剩余生存时间。比如还剩 15000 毫秒的生存时间。此时客户端 2 会进入一个 while 循环，不停的尝试加锁。

14. watch dog 自动延期机制

    客户端 1 加锁的锁 key 默认生存时间才 30 秒，如果超过了 30 秒，客户端 1 还想一直持有这把锁，怎么办呢？

    **简单！**只要客户端 1 一旦加锁成功，就会启动一个 watch dog 看门狗，他是一个后台线程，会每隔 10 秒检查一下，如果客户端 1 还持有锁 key，那么就会不断的延长锁 key 的生存时间。

15. **缓存与数据库不一致怎么办**

    假设采用的主存分离，读写分离的数据库，

    如果一个线程 A 先删除缓存数据，然后将数据写入到主库当中，这个时候，主库和从库同步没有完成，线程 B 从缓存当中读取数据失败，从从库当中读取到旧数据，然后更新至缓存，这个时候，缓存当中的就是旧的数据。

    发生上述不一致的原因在于，主从库数据不一致问题，加入了缓存之后，主从不一致的时间被拉长了

    处理思路：在从库有数据更新之后，将缓存当中的数据也同时进行更新，即当从库发生了数据更新之后，向缓存发出删除，淘汰这段时间写入的旧数据。

    主从数据库不一致如何解决场景描述，对于主从库，读写分离，如果主从库更新同步有时差，就会导致主从库数据的不一致

    1、忽略这个数据不一致，在数据一致性要求不高的业务下，未必需要时时一致性

    2、强制读主库，使用一个高可用的主库，数据库读写都在主库，添加一个缓存，提升数据读取的性能。

    3、选择性读主库，添加一个缓存，用来记录必须读主库的数据，将哪个库，哪个表，哪个主键，作为缓存的 key,设置缓存失效的时间为主从库同步的时间，如果缓存当中有这个数据，直接读取主库，如果缓存当中没有这个主键，就到对应的从库中读取。

16. redis 和 memcached 的区别

    1. **redis支持更丰富的数据类型（支持更复杂的应用场景）**：Redis不仅仅支持简单的k/v类型的数据，同时还提供list，set，zset，hash等数据结构的存储。memcache支持简单的数据类型，String。
    2. **Redis支持数据的持久化**，可以将内存中的数据保持在磁盘中，重启的时候可以再次加载进行使用,而Memecache把数据全部存在内存之中。
    3. **集群模式**：memcached没有原生的集群模式，需要依靠客户端来实现往集群中分片写入数据；但是 redis 目前是原生支持 cluster 模式的.
    4. **Memcached是多线程**，非阻塞IO复用的网络模型；Redis使用单线程的多路 IO 复用模型。**

    当然入股是存储大量的数据，相对于redis而言，memcached回会更好一点

17. 常见的redis应用场景

    【1】缓存，也就是在查询数据库之前可以先查询一下redis。如果redis中有这个数据，将直接从redis中取出来，如果没有，就进入数据库中查询，查询出来之后，再将数据添加到redis中

    【2】sessionId，也就是在分布式项目中，使用nginx进行负载均衡之后，一个客户端的两次请求你可能不在同一个tomcat服务器上，这样就造成了session丢失。所以可以使用redis将sessionId存储起来（但是这个方案有缺陷就是在高并发的项目中会造成大量的数据冗余）

    【3】聊天室的好友在线列表，

    【4】任务队列，比如秒杀，抢购，12306等。比如说秒杀，在redis中存放一个数据（商品量），每秒杀一个就减去一个，当数量为0的时候就禁止秒杀。同时在秒杀之后，设置过期时间，也就是秒杀没有下单，就算是过期。这样就给数据重新加入到秒杀量中

    因为redis是单线程，且内存数据库。所以使用redis进行秒杀

    【5】应用排行榜

    【6】网站访问量

    【6】数据过期处理（验证码等）



# 命令

redis-cli，使用客户端链接server

```
-a 后面接密码
-h 后面接主机ip
-p 后面接端口

redis-cli shutdown 关闭服务端
```

redis-server，server端的操作

```
redis-server redis.conf使用配置文件启动
```



## Key

1、删除key

> del [key]

2、设置key的有效时间s

> expire [key] [seconds]

3、设置key的有效时间ms

> pexpire [key] [ms]

4、使用字符串匹配查找key

> keys [pattern]
>
> `keys *`查找所有的key

5、查看key的有效时间s

> ttl [key]

## 字符串

1、设置字符串

> set [key] [val]

2、获取字符串

> get [key]

3、重设key的值，并返回久值

> getset key val

4、一次获取多个

> mget key1 key2 ...

5、不存在则创建

> setnx key val
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203135722.png)

6、自增1

> incr key

7、自减1

> decr key

## hash

1、设置key field

> hmset key field1 val1 field2 val2
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203140308.png)

2、获取key对应field

> hmget key field1 [field2...]

3、获取key中所有字段

> hgetall key
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203140530.png)

4、删除key中的某一字段

> hdel key field1 [field2...]

5、field不存在则创建对应field

> hsetnx key field1 val
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203140723.png)

## 列表

1、将一个或多个值插入到尾部

> lpush key val1 [val2...]
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203142217.png)

2、将一个值插入已存在的列表头部

> lpushx key val
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203142300.png)

3、使用范围查看元素

> lrange key start end

4、移除并获取第一个元素

> lpop key

5、移除获取列表第一个元素，如果没有则超时等待

> blpop key1 [key2] timeout
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203142810.png)

6、移除获取列表最后一个元素，如果没有就超时等待

> brpop key1 [key2...] timeout
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203142851.png)

7、通过索引获取元素

> lindex key index
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203143001.png)

## 集合

无序集合

1、向集合中添加元素

> sadd key member1 [member2...]

2、获取集合中元素数量

> scard key

3、判断元素是否在集合中

> sismember key member
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203145700.png)

4、获取集合中所有成员

> smembers key

5、随机移除并返回一个成员

> spop key
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203145846.png)

6、随机返回一个或多个成员

> srandmember key [count]
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203150022.png)

## 有序集合

1、添加成员及分数

> zadd key score1 member1 [score2 member2...]

2、通过索引区间，返回指定区间的成员

> zrange key start end
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203152203.png)

3、通过成员，返回分值

> zrank key member
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203152327.png)

4、移除成员

> zrem key member1 [member2...]

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230203153230.png)



