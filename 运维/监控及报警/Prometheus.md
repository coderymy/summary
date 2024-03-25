# 简介

一套开源的**系统监控报警框架**，Pemetheus 可以很方便的与众多开源项目集成，另一方面分析其收集的大数据，可以帮助我们进行系统优化和作出决策。它不仅是可以应用在 IT 领域，对于任何需要收集指标数据的情形下都可以使用。

![](https://img-blog.csdnimg.cn/a3310ee40e90435388fc3f1afa2a1052.jpeg#pic_center)



+ 多维 数据模型（时序由 metric 名字和 k/v 的 labels 构成）。
+ 灵活的查询语句（PromQL）。
+ 无依赖存储，支持 local 和 remote 不同模型。
+ 采用 http 协议，使用 pull 模式，拉取数据，简单易懂。
+ 监控目标，可以采用服务发现或静态配置的方式。
+ 支持多种统计数据模型，图形化友好



# 实现逻辑

数据拉取逻辑

1. server定期从静态配置的target、服务发现的target中拉取数据
2. server获取的数据大于缓存区，即持久化到磁盘（或remote到云端）

报警逻辑

+ 配置规则，定期检查对应的数据，如果出现命中规则则报警



# 概念

## 数据模型（时间序列）

metric+标签来唯一标识一个数据模型。而对应样本+格式，标识一条数据

一个样本包含以下三部分

+ 指标metric：指标名和描述（标签）当前样本特征的标签集合，比如指标名CRM_HTTP_NUM。标签名GET
+ 时间戳timestamp：精确到毫秒的时间戳
+ 样本值value： 一个 float64 的浮点型数据表示当前样本的值

例如：CRM_HTTP_NUM{method="GET",handler:"/getTaskPage"}



## 指标类型

监控的纬度不同，所展现的就不一样。

Prometheus 定义了 4 种不同的指标类型：**Counter（计数器）**、**Gauge（仪表盘）**、**Histogram（直方图）**、**Summary（摘要）**。

+ Counter：标识只增不减，比如Http_num
+ Gauge：可增可减，就想车的仪表盘一样，当前内存使用情况
+ Histogram：对一个时间范围（区间）进行分组。比如一分钟内的访问情况等
+ Summary：摘要，统计，对一段行为进行一个取平均等。汇聚操作。比如95%的请求延迟 < xxx ms ，99%的请求延迟 < xxx ms



## 存储

Prometheus保存的结构是一个TSDB的时序数据库。

```
{__name__="http_requests_total",method="GET	", handler="/api/v1/items"}   @1649483597.197     17
```

## PromQL

 Prometheus 提供了其它大量的内置函数，可以对时序数据进行丰富的处理，基础语法可参考官方文档：



## AlertManager

告警模块。通过配置对应规则，定时检查规则，当数据达到规则的时候，就会触发告警



