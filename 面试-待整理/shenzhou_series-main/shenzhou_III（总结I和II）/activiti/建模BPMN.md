# BPMN介绍

+ StartEvent：任务的开始
+ EndEvent：任务的结束
+ intermediateEvent：中间事件



+ UserTask：整个流程中需要处理的业务

  请假申请，需要上级领导进行审批。这个`上级领导审批`就是一个用户任务

+ ServiceTask：服务任务

+ SubProcess：子流程

网关：

+ 排他网关：只有一条路径被选择。按照条件计算结果，多个true的时候也只有一个才能被执行
+ 并行网关：
  + 拆分：只要满足条件的所有道路都并行执行
  + 合并：合并所有网关的线路，只有所有线路都满足条件才向下执行（例如财务审批需要等待三个董事长都审批成功才执行采购计划）
+ 包容网关：
+ 事件网关：



## 绘制流程图

1. 一个`startEvent`并配置其id
2. 



# activiti6和activiti7的区别

删除了user表

删除了IdentityService和FormService





# Activiti使用步骤

1. 定义流程，绘制bpmn
2. 部署流程，
3. 启动流程

# 表结构

`act_ge`表示通用

`act_hi`表示数据

`act_re`流程定义的内容和静态资源

`act_ru`运行时的一些数据，执行过程中才会用到

表结构具体字段[参考](https://www.devdoc.cn/activiti-table-summary.html)

| 分类         | 表                    | 表描述                                               | 备注                                                         |
| ------------ | --------------------- | ---------------------------------------------------- | ------------------------------------------------------------ |
| 通用数据     | ACT_GE_BYTEARRAY      | 通用的流程定义和流程资源                             | 流程定义图片和xml、Serializable（序列化）的变量，<br>即保存所有二进制数据。主要注意的有两个点。<br>`锁`和`流程定义文件(bpmn)`。[参考](https://blog.csdn.net/weixin_41039677/article/details/119864308) |
|              | ACT_GE_PROPERTY       | 系统默认属性                                         | 包括使用的`系统定义的信息`和`框架版本等信息`                 |
| 流程历史记录 | ACT_HI_ACTINST        | 历史的流程实例                                       | 记录流程流转过的所有节点，只记录userTask实例[参考](https://blog.csdn.net/weixin_41039677/article/details/119907914?spm=1001.2014.3001.5501) |
|              | ACT_HI_ATTACHMENT     | 历史的流程附件                                       | 存储在流转过程中使用的附件信息                               |
|              | ACT_HI_COMMENT        | 历史的说明性信息                                     | 比如说审批意见等                                             |
|              | ACT_HI_DETAIL         | 历史的流程运行中的细节信息                           | 流程流转的相关变量信息。<br>比如流程判断时可能会使用变量来区分流程的走向 |
|              | ACT_HI_IDENTITYLINK   | 历史的流程运行过程中用户关系                         | 该流程中参与者的一些信息                                     |
|              | **ACT_HI_PROCINST**   | 历史的流程实例                                       | 实例的核心信息，一个流程只会有一条                           |
|              | **ACT_HI_TASKINST**   | 历史的任务实例                                       | 每个人工任务都会产生一条数据                                 |
|              | ACT_HI_VARINST        | 历史的流程运行中的变量信息                           | 会记录详细记录流程中的每个变量，<br>包括他的名字、类型，值是多少、什么时候创建的，什么时候更新的；<br>不管是流程启动的时候传入的变量，还是表单中的字段等。 |
|              | ACT_PROCDEF_INFO      | 流程定义的动态变更信息                               |                                                              |
| 流程定义表   | ACT_RE_DEPLOYMENT     | 部署单元信息                                         |                                                              |
|              | ACT_RE_MODEL          | 模型信息                                             |                                                              |
|              | ACT_RE_PROCDEF        | 已部署的流程定义                                     |                                                              |
| 运行实例表   | ACT_RU_DEADLETTER_JOB | 作业死亡信息表，作业失败超过重试次数                 |                                                              |
|              | ACT_RU_EVENT_SUBSCR   | 运行时事件 throwEvent、catchEvent 时间监听信息表     |                                                              |
|              | ACT_RU_EXECUTION      | 运行时流程执行实例                                   |                                                              |
|              | ACT_RU_IDENTITYLINK   | 运行时流程人员表，主要存储任务节点与参与者的相关信息 |                                                              |
|              | ACT_RU_INTEGRATION    | 运行时积分表                                         |                                                              |
|              | ACT_RU_JOB            | 运行时作业信息表                                     |                                                              |
|              | ACT_RU_SUSPENDED_JOB  | 运行时作业暂停表                                     |                                                              |
|              | ACT_RU_TASK           | 运行时任务节点表                                     |                                                              |
|              | ACT_RU_TIMER_JOB      | 运行时定时器作业表                                   |                                                              |
|              | ACT_RU_VARIABLE       | 运行时流程变量数据表                                 |                                                              |

配置数据库的连接信息生成processEngineConfiguration。

通过下·processEngineConfiguration创建流程引擎processEngine



# Service

+ RepositoryService，部署相关的操作，也就是操作`act_re*`相关的表
+ RuntimeService，操作运行时候的，
+ HistoryService，操作历史的



# 概念

流程定义

流程实例