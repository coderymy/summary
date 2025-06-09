mysql整体分为server层和存储引擎层
![](https://raw.githubusercontent.com/coderymy/oss/main/uPic/GQO0E4.jpg)

# mysql的redolog、undolog、binlog
## redolog(保证事物提交的持久性)

![](https://raw.githubusercontent.com/coderymy/oss/main/uPic/N8wj7n.jpg)
默认有四个文件进行循环存储.

也就是在进行数据库操作的时候,并不是实时就将数据更新到磁盘中,而是一个异步的流程.如果进行update操作,分为以下几个步骤

WAL机制(write ahead logging)
1. 数据库进行sql校验是否能够执行
2. 进行资源锁定(事务不一定存在)
3. write pos写入redolog并于client交互返回成功
4. checkpoint顺序执行执行到这条语句进行磁盘的数据update操作
5. 并擦除这条redolog操作行为




## undolog(保证事物的回滚和MVCC中的版本概念)


记录了一条增删改操作的相反数据变更,也就是变更前的数据记录信息.方便在回滚时候进行数据变更回去

也记录MVCC中的一个版本号.当用户读取一行记录时,若该记录已经被其他事务占用,当前事务可以通过undo读取之前的行版本信息,以此实现非锁定读取。


## binlog

记录实际最终对数据的操作的语句,记录的是二进制信息


## redolog和binlog

1. redo log是InnoDB引擎特有的；binlog是MySQL的Server层实现的，所有引擎都可以使用。
2. binlog是追加写,redolog是循环写

## 整体执行流程如下
![](https://raw.githubusercontent.com/coderymy/oss/main/uPic/m17UMw.jpg)

`
