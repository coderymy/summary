# 问题

## 用过SpringCloud的哪些组件

1、ribbon，进行负载，当访问微服务中的其他服务进行消息通信的时候，先在注册中心上获取对应服务的路由表，然后本地client的ribbon程序会按照既定的方式进行路由选择，选择具体的服务进行访问

> 轮询策略，用的最多
>
> 权重策略，根据对应服务的响应时间分配一个权重，响应时间越高权重越小
>
> 随机策略
>
> 最小链接策略
>
> 重试策略

2、Nacos做配置中心，也可以作为注册中心

3、consul做注册中心

4、feign的运行原理

> 1. 开始调用方法。
> 2. 由动态代理Target接管方法运行。
> 3. Contract根据注解，取得MethodHandler列表。
> 4. 执行Request相关的MethodHandler。
> 5. 由Encoder包装Request，执行相应的装饰器，记录日志。
> 6. 基于Client发起请求。
> 7. 取得请求Response，由Decoder解码。
> 8. 执行Response相关的MethodHandler。
> 9. 经由代理类返回最终结果。

5、简述服务雪崩

> 原因：一个服务的异常，导致调用他的服务请求出现阻塞。时间长了调用方的线程阻塞过多，导致调用方也出现异常。
>
> 解决方案：熔断异常服务的接口，接口超时请求丢弃，根据业务调整服务副本数量防止流量过大导致错误。





# 简介dubbo和SpringCloud

## dubbo

+ 阿里开源被apache收购.
+ 可使用的注册中心为zookeeper、redis、memcached
+ 可使用的rpc协议为dubbo、hession、thrift
+ dubbo协议是基于netty的nio的http长连接
+ dubbo自带admin(后台管理页面)和monitor(服务监控和预警)



# SpringCloud了解各个组件

## 1. Eureka

注册中心

eureka包括eureka-server、eureka-client两个

client将本地服务的ip及监听的端口注册到server中

server有一个注册表,其中记录着所有的client的信息

client每隔一段时间会获取server的注册表信息将其缓存在本地

![图片](https://mmbiz.qpic.cn/mmbiz_png/1J6IbIcPCLZMkG4ELsMmbSHDHwfFGic4CvHjEPqBW2iclGBwTzB4sD6VR2NU0xmMsoYicmWCXfPCQTn1LticB61OWA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)



## 2. feign

远程服务调用

动态代理的方式

![图片](https://mmbiz.qpic.cn/mmbiz_png/1J6IbIcPCLZMkG4ELsMmbSHDHwfFGic4CT5y3EDh8DaEmDM4ibRNW0aTiaD8opMUFUCKX5yYxnGaqc7Kz7dicWm2kw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

## 3. ribbon

负载均衡

默认使用轮询的策略进行负载均衡

![图片](https://mmbiz.qpic.cn/mmbiz_png/1J6IbIcPCLZMkG4ELsMmbSHDHwfFGic4CtD7kdmviciaXUubWd69erjZn8Hgw5ZZrDWYDBYCAiaBchGDxxwQj7Lic0w/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

## 4. hystrix

隔离、熔断和降级

![图片](https://mmbiz.qpic.cn/mmbiz_png/1J6IbIcPCLZMkG4ELsMmbSHDHwfFGic4CZsj0neCTAwgfBVClSwTarrZ7gMRKAQlNviabrsOJ0DA9GcSmuZ2BTcQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

逻辑中订单服务需要调用库存服务、仓储服务和积分服务.如果其中积分服务挂掉了.会导致订单服务中的线程阻塞,时间长了会影响订单服务访问其他服务.从而导致整体服务的宕机.所以这个时候就需要熔断机制.



## 5. zuul

网关

将所有的服务全部集合起来.由网关统一进行分发请求.

![图片](https://mmbiz.qpic.cn/mmbiz_png/1J6IbIcPCLZMkG4ELsMmbSHDHwfFGic4CA7GmsCW8v9loCtGyHjPUa142lvp8aV4ViaFAsXDp6nGC9Z3ZryRKniaA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

# 面试问题---eureka

1. **Eureka Server是如何保证轻松抗住这每秒数百次请求，每天千万级请求的呢？**
2. Eureka注册中心使用什么样的方式来储存各个服务注册时发送过来的机器地址和端口号？
3. 

## 1. eureka缓存与心跳机制

+ 缓存:eureka-client,每隔30s就会请求一次eureka-server拉去最近有变化的服务信息.
+ 心跳机制:eureka-client每隔30s请求一次eureka-server告诉server我还活着

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/1J6IbIcPCLbvlTGfketBG4ENjvReM6RGImhGtXgshicOL2QX1FafH9hTCDdmXc51CUbj6ftiaibLjDST0RtvOibkoA/640?tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

## 2. eureka注册表结构

基于纯内存维护的一个**registry**的**CocurrentHashMap**数据结构.

- 首先，这个ConcurrentHashMap的key就是服务名称，比如“inventory-service”，就是一个服务名称。

- value则代表了一个服务的多个服务实例。**Map<String, Lease<InstanceInfo**>>
  - key为服务的实例id
  - value是一个叫做**Lease**的类
  - 这个InstanceInfo就代表了**服务实例的具体信息**，比如机器的ip地址、hostname以及端口号。
  - 而这个Lease，里面则会维护每个服务**最近一次发送心跳的时间**

- 举例：比如“inventory-service”是可以有3个服务实例的，每个服务实例部署在一台机器上。



## 3. eureka-server的多级缓存机制

1. **ReadOnlyCacheMap**
2. **ReadWriteCacheMap**
3. **内存**

三十秒重置一次所有缓存数据,从内存中获取进行重新更新

- 在拉取注册表的时候：

- - 首先从**ReadOnlyCacheMap**里查缓存的注册表。

- - 若没有，就找**ReadWriteCacheMap**里缓存的注册表。

- - 如果还没有，就从**内存中获取实际的注册表数据。**

- 在注册表发生变更的时候：

- - 会在内存中更新变更的注册表数据，同时**过期掉ReadWriteCacheMap**。

- - 此过程不会影响ReadOnlyCacheMap提供人家查询注册表。

- - 一段时间内（默认30秒），各服务拉取注册表会直接读ReadOnlyCacheMap

- - 30秒过后，Eureka Server的后台线程发现ReadWriteCacheMap已经清空了，也会清空ReadOnlyCacheMap中的缓存

- - 下次有服务拉取注册表，又会从内存中获取最新的数据了，同时填充各个缓存。

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/1J6IbIcPCLbvlTGfketBG4ENjvReM6RGZUKhPzd0ZNk4uiaZtZekErqU8yvo3qwHCzVeqjqpI5ZC6VvfO1balQg/640?tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

# 面试问题---SpringCloud与dubbo之间的区别

​	



# 面试问题---开发和测试在同一个注册中心,如何做到隔离

在发布和订阅服务的时候指定group或version



# RPC

RPC有三要素 socket 动态代理 序列化



# Dubbo

## dubbo的工作原理

1. service:业务层,提供provider和consumer
2. config
3. proxy层,生成代理,代理之间进行网路通信
4. registry层,将所有的provider都注册,方便进行调用
5. cluster层,集群,将多个同类型服务集群成一个服务
6. monitor,监控监控rpc接口的调用情况
7. protocol,远程调用,封装rpc调用
8. exchange,信息交换
9. transport,网络传输层
10. serialize,数据序列化层

## dubbo的通信协议,序列化协议

dubbo协议是基于NIO的长链接协议.使用hession进行序列化



## dubbo负载均衡策略

+ 随机
+ 轮询
+ 自动感知
+ 一致hash算法

## dubbo集群容错策略

+ 失败自动切换
+ 一次调用失败就立即失败
+ 出现异常时忽略掉
+ 失败了后台自动记录请求

## dubbo的spi思想

插件扩展场景.也就是dubbo定义了接口,可以自己按照接口进行自定义自己的实现类



