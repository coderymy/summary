Apache Hadoop 包含以下模块：

+ Hadoop Common：常见实用工具，用来支持其他 Hadoop 模块。
+ Hadoop Distributed File System（HDFS）：分布式文件系统，它提供对应用程序数据的高吞吐量访问。
+ Hadoop YARN：一个作业调度和集群资源管理框架。
+ Hadoop MapReduce：基于 YARN 的大型数据集的并行处理系统。

其他与 Apache Hadoop 的相关项目包括：

+ Ambari：一个基于Web 的工具，用于配置、管理和监控的 Apache Hadoop 集群，其中包括支持 Hadoop HDFS、Hadoop MapReduce、Hive、HCatalog、HBase、ZooKeeper、Oozie、Pig 和 Sqoop。Ambari 还提供了仪表盘查看集群的健康，如热图，并能够以用户友好的方式来查看的 MapReduce、Pig 和 Hive 应用，方便诊断其性能。

+ Avro：数据序列化系统。
+ Cassandra：可扩展的、无单点故障的多主数据库。
+ Chukwa：数据采集系统，用于管理大型分布式系统。
+ **HBase**：分布式数据库管理系统，进行数据管理的。
+ **Hive**：一个数据查询的方式，优化了使用MapReduce脚本进行数据统计的痛点
+ Mahout：一种可扩展的机器学习和数据挖掘库。
+ Pig：一个高层次的数据流并行计算语言和执行框架。
+ **Spark**：Hadoop 数据的快速和通用计算引擎。Spark 提供了简单和强大的编程模型用以支持广泛的应用，其中包括 ETL、机器学习、流处理和图形计算。(有关 Spark 的内容，会在后面章节讲述)
+ TEZ：通用的数据流编程框架，建立在 Hadoop YARN 之上。它提供了一个强大而灵活的引擎来执行任意 DAG 任务，以实现批量和交互式数据的处理。TEZ 正在被 Hive、Pig 和 Hadoop 生态系统中其他框架所采用，也可以通过其他商业软件（例如 ETL 工具），以取代的 Hadoop MapReduce 作为底层执行引擎。
+ ZooKeeper：分布式系统协调工具



# 为什么要使用hadoop

超大数据量无法存储在单个硬盘中（存储和读取速率都是问题）。所以需要将大量的数据进行拆分放到很多个硬盘中。

但是存储在多个硬盘中又会带来更多的问题
+ 读取方式（分布式处理）
+ 备份压力（分布式存储）
+ 数据的正确组合（分布式分析）（一个人的数据在多个硬盘上）

所以hadoop就是为了解决以上问题而存在的

![](https://raw.githubusercontent.com/coderymy/oss/main/uPic/I9smmu.png)

# hadoop的角色
**HDFS**
## 主节点 NameNode
所有的交互都会首先和主节点进行交互，所以主节点具有管理所有其他节点的目录树结构

对外提供服务
## 数据存储DataNode

进行数据存储



