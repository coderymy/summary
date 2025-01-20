# OLTP和OLAP

概念

+ **OLAP**全称为**OnlineAnalyticalProcessing**，**它强调对大量历史数据的分析与处理**。OLAP系统通常用来查询多维数据库，以便观察数据的多个维度之间的关系，并进行复杂的计算和汇总。它的主要功能包括**查询、分析、预测、数据挖掘**等，为用户提供灵活的数据分析和快速决策支持。
+ **OLTP**全称为**OnlineTransactionProcessing**，**它强调对数据的实时处理**。OLTP系统通常用于处理企业的日常交易数据，例如订单处理、库存管理、银行交易等。它的主要功能是**支持事务和实时数据处理**，为用户提供高效的交易处理服务。

区别：

+ 使用场景不同：
  + OLTP：交易数据实时处理
  + OLAP：数据分析、数据挖掘
+ 规模不一样
  + OLTP：处理实时的数据
  + OLAP：大规模历史数据处理
+ 数据结构不一样
  + OLTP：关系型数据库
  + OLAP：多维数据结构。通过维度、度量、层次等数据元素来组织和管理数据，以便进行复杂的查询和分析。



# 列存储和行存储

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/202407191434137.png)

对于行存的一条数据，在列存中会保存多条。



区别：

+ 数据写入
  + 行存一条数据的写入是一次动作，磁头写入会是一次
  + 列存一条数据的写入是多次，磁头移动多次，所以写入速率会较低
+ 数据读取
  + 行存储是将一列读出之后再去除冗余列
  + 列存储取出的是集合中的一批数据
+ 数据分布
  + 行存储单条数据所在的一块区域的数据格式和所占大小不一样
  + 列存储单条数据所在区块的每一个item是一样的大小。所以数据解析效率要高于行存



结论

+ 行存储，保存数据具有完整性、保存效率更高。查询会产生冗余数据
+ 列存储，保存数据不完全保证整条数据的完整性。查询不产生冗余数据，适合数据量较大但是对完整性要求不那么严格的业务场景，如数据统计、大数据计算等

使用场景

+ 行存储：每次查询都关注整行数据
+ 列存储：每次查询只是关注几列而不是全表、有频繁聚集需要（对列的某个字段进行聚集）

# IMCI

原因：

1. 存储节点和计算节点分离开
2. 列存较为适合聚合查询

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/202407191522296.png)



## OLTP与OLAP业务场景下行存和列存自动分流

> ps：我们不需要依赖阿里云的自动分流，使用手动指定的方式

条件：

集群地址的读写模式设置为**可读可写（自动读写分离）**。或集群地址的读写模式设置为**只读**，并且集群地址的负载均衡策略设置为**基于活跃请求数负载均衡**。



自动分流判断标准：

- 低于SQL语句的预估执行代价阈值的请求将被引流至行存节点上（或者主节点）执行。多个行存节点的情况下，具体引流至哪个行存节点，根据负载均衡自动判定。
- 高于SQL语句的预估执行代价阈值的请求将被引流至列存节点上执行。多个列存节点的情况下，具体引流至哪个列存节点，根据负载均衡自动判定。



## IMCI列存特点

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/202407191525875.png)

PolarDB MySQL版的列存索引特性提供了一站式HTAP产品体验，可以应用于多种业务场景：

- 对在线数据有实时数据分析需求的场景，如实时报表；
- 专用数据仓库场景：依托PolarDB提供的海量数据存储能力，汇聚多个上游数据源，将其作为专用数据仓库使用；
- ETL数据加速计算场景：依托PolarDB基于列存索引提供的强大而灵活的计算能力，在PolarDB中使用SQL来实现ETL功能。



## 列存索引

### 索引限制

#### 以下SQL不支持列存索引

[列存限制条件](https://help.aliyun.com/zh/polardb/polardb-for-mysql/user-guide/limits-3?spm=a2c4g.11186623.0.0.7e401f42tCHNDt)

- 含锁操作的**SELECT**语句。如：`SELECT ... FOR [UPDATE | SHARE] ... `。

- 含frame聚合函数的**SELECT**语句。如：

  ```sql
  SELECT
      time,
      subject,
      val,
      SUM(val) OVER (
          PARTITION BY subject
          ORDER BY time
          ROWS UNBOUNDED PRECEDING  --- window function 中的 frame 定义，IMCI 不支持
      ) AS running_total
  FROM
      observations;
  ```

- 子查询出现在GROUP BY clause 中的**SELECT**语句。如：`SELECT SUM(a) FROM t1 GROUP BY (SELECT ... FROM ...) as some_subquery;`

- 子查询出现在ORDER BY表达式中的**SELECT**语句。如：`SELECT a FROM t1 ORDER BY (SELECT ... FROM ...) as some_subquery;`

- 子查询中的关联项出现在join condition中的**SELECT**语句。如：`WHERE t1.a in (SELECT t2.a FROM t2 INNER JOIN t3 on t2.a = t3.a AND t2.b > t1.b)；`

- 子查询中含有window function，且关联项在HAVING条件中的**SELECT**语句。

- 子查询中含有UNION，且关联项出现在UNION的子查询中的**SELECT**语句。

#### 以下函数不支持

| **表达式**       | **是否支持使用列存索引功能** |
| ---------------- | ---------------------------- |
| JSON_ARRAYAGG()  | 不支持                       |
| JSON_OBJECTAGG() | 不支持                       |
| JSON函数         | 不支持                       |



### 创建列存索引

> 列存索引暂不支持SET数据类型。

如果表/字段新建

- 在建表时，您只需要在**CREATE TABLE**语句的**COMMENT**字段里增加**COLUMNAR=1**字符串，即可创建列存索引。其余语法均不变，且不受影响。
- **COLUMNAR=1**可以单独加在列的**COMMENT**字段中，单独对该列生效；也可以加在**CREATE TABLE**语句末尾的**COMMENT**字段中，对表中所有支持的数据类型的列生效。

如果表/字段已存在

- 可在**ALTER TABLE**语句后增加**COMMENT 'COLUMNAR=1'**字段，为表创建对全表生效的列存索引。
- 可在**ALTER TABLE ... MODIFY COLUMN ...**语句后增加**COMMENT 'COLUMNAR=1'**字段，为指定列创建列存索引。

[查看创建情况](https://help.aliyun.com/zh/polardb/polardb-for-mysql/user-guide/view-ddl-execution-speed-and-build-progress-for-imcis?spm=a2c4g.11186623.0.0.7efb1527wph4Ld)

当某条SQL语句的执行计划不是列存执行计划时，可能的原因有哪些？

- SQL语句查询的数据列是否被列存索引覆盖，若数据列没有被列存索引覆盖，请为需要使用列存执行计划的数据列创建列存索引，创建列存索引请参见[建表时创建列存索引的DDL语法](https://help.aliyun.com/zh/polardb/polardb-for-mysql/user-guide/execute-the-create-table-statement-to-create-an-imci#concept-2176899)或[使用DDL语句动态增删列存索引](https://help.aliyun.com/zh/polardb/polardb-for-mysql/user-guide/use-ddl-statements-to-dynamically-add-and-delete-an-imci#concept-2176902)。
- 对于已开启行存/列存自动引流的集群地址，请确认**参数设置**中的`loose_imci_ap_threshold`参数值是否满足条件，即检查`SHOW STATUS LIKE 'Last_query_cost'`的值是否大于`SHOW VARIABLES LIKE 'imci_ap_threshold'`的值。若不满足，请参考[配置自动引流阈值](https://help.aliyun.com/zh/polardb/polardb-for-mysql/user-guide/automatic-request-distribution-among-row-store-and-column-store-nodes#section-es1-vty-y0e)中的内容适当修改`loose_imci_ap_threshold`参数值。
- 对于只读列存节点， 请确认**参数设置**中的`loose_cost_threshold_for_imci`参数值是否满足条件，即检查`SHOW STATUS LIKE 'Last_query_cost'`的值是否大于`SHOW VARIABLES LIKE 'cost_threshold_for_imci'`的值。若不满足，请参考[配置自动引流阈值](https://help.aliyun.com/zh/polardb/polardb-for-mysql/user-guide/automatic-request-distribution-among-row-store-and-column-store-nodes#section-es1-vty-y0e)中的内容适当修改`loose_cost_threshold_for_imci`参数值。
- 对于主节点、普通列存节点或未开启行存/列存自动引流的集群地址，请切换至开启行存/列存自动引流的集群地址或者直接连接只读列存节点。



查看列存储索引



[行存和列存](https://www.cnblogs.com/liujichang/p/17384083.html)

[IMCI阿里云介绍](https://help.aliyun.com/zh/polardb/polardb-for-mysql/user-guide/overview-29?spm=a2c4g.11186623.0.0.40304e03UVqEEG)