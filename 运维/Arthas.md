# 一，概述

Alibaba开源的Java诊断工具



# 二，使用场景



1. 线上总是会需要有一些手动触发的逻辑，需要写各种Controller。CRM早期一些没有使用xxlJob的定时任务
2. 线上偶尔需要进行临时的变量替换。触达项目访问限制次数，偶尔需要根据业务的需要调整
3. 线上无法debug，一些没有日志的代码不好定位问题。
4. 上线的代码没有生效。
5. 一些需要动态替换的参数、变量。





# 三，使用方法

> 安装，启动
>
> ```shell
> curl -0  https://arthas.aliyun.com/arthas-boot.jar;
> java -jar arthas-boot.jar
> ```
>
> 如果本地没有安装，会自动安装并启动

>生产环境上
>
>arms上配置开启Arthas
>
>![image-20240318204452005](C:\Users\星火保\AppData\Roaming\Typora\typora-user-images\image-20240318204452005.png)
>
>![image-20240318204518418](C:\Users\星火保\AppData\Roaming\Typora\typora-user-images\image-20240318204518418.png)



## 基础命令

### 启动

```
java -jar arthas-boot.jar
```

### 退出

```
exit/quit
```

### 停止

```
stop
```

### 清屏

```
cls
```



## 监视功能

### dashboard

看板，可以直接看到这个Java进程的线程使用情况、JVM的内存使用情况、os的基本信息

### monitor

观察指定类中方法的执行情况
用来监视一个时间段中指定方法的执行次数，成功次数，失败次数，耗时等这些信息

```shell
monitor classPath.ClassName methodName 条件表达式

例：
monitor com.bxlsj.crm.service.kaisen.KaiSenServiceImpl transcodingPhone -c 5
五秒刷新一次
```

| 参数           | 解释                   |
| -------------- | ---------------------- |
| -c 3           | 指定刷新间隔           |
| -b             | 在方法执行之前观察返回 |
| "params[0]<=2" | 指定参数的表达式过滤   |

### watch

观察函数的返回值

```shell
watch classPath.ClassName methodName 观察表达式 条件表达式

例：watch com.bxlsj.crm.service.kaisen.KaiSenServiceImpl transcodingPhone '{params,returnObj}' -x 2
```

参数

| [b]  | 在**方法调用之前**观察`before`                      |
| ---- | --------------------------------------------------- |
| [e]  | 在**方法异常之后**观察 `exception`                  |
| [s]  | 在**方法返回之后**观察 `success`                    |
| [f]  | 在**方法结束之后**(正常返回和异常返回)观察 `finish` |
| [x]  | 指定遍历深度                                        |

观察表达式，见下面的OGNL表达式

![image-20240319191925952](C:\Users\星火保\AppData\Roaming\Typora\typora-user-images\image-20240319191925952.png)

### trace

路径追踪，输出方法开销

```shell
trace classPath.ClassName methodName 条件表达式 #cost>?

例：
trace com.bxlsj.crm.service.kaisen.KaiSenServiceImpl transcodingPhone #cost>100
输出大于100毫秒的方法开销信息
```

参数：

| `[n:]`                       | 设置命令执行次数         |
| ---------------------------- | ------------------------ |
| `#cost`                      | 方法执行耗时，单位是毫秒 |
| [--skipJDKMethod true/false] | 跳过jdk默认的一些方法    |

### reset

重置任何增强过的类

### stack

查看指定方法的调用情况、调用路径，帮助排查一个方法被多个地方调用的时候，执行的地方是哪

```shell
trace classPath.ClassName methodName 条件表达式 -n num 
```

| 参数 | 含义         |
| ---- | ------------ |
| [n]  | 执行次数限制 |

### tt

时间隧道。观察方法的入参和返回结果。

```shell
trace classPath.ClassName methodName
```

| tt的参数  | 说明                             |
| --------- | -------------------------------- |
| -t        | 记录某个方法在一个时间段中的调用 |
| -l        | 显示所有已经记录的列表           |
| -n 次数   | 只记录多少次                     |
| -s 表达式 | 搜索表达式                       |
| -i 索引号 | 查看指定索引号的详细调用信息     |
| -p        | 重新调用：指定的索引号时间碎片   |

tt和其他的最大区别在于，可以记录下来当前查看的idx。后面再指定这个idx`tt -i xxx`就可以再次看到这个访问

![](https://img-blog.csdnimg.cn/93e068a0cad54ab3afc2ac04a59dae85.png)

| 表格字段  | 字段解释                                                     |
| --------- | ------------------------------------------------------------ |
| INDEX     | 时间片段记录编号，每一个编号代表着一次调用，<br>后续tt还有很多命令都是基于此编号指定记录操作，非常重要。 |
| TIMESTAMP | 方法执行的本机时间，记录了这个时间片段所发生的本机时间       |
| COST(ms)  | 方法执行的耗时                                               |
| IS-RET    | 方法是否以正常返回的形式结束                                 |
| IS-EXP    | 方法是否以抛异常的形式结束                                   |
| OBJECT    | 执行对象的`hashCode()`，注意，曾经有人误认为是对象在JVM中的内存地址，<br>但很遗憾他不是。但他能帮助你简单的标记当前执行方法的类实体 |
| CLASS     | 执行的类名                                                   |
| METHOD    | 执行的方法名                                                 |

> 使用tt重新发起请求
>
> 由于tt保存了这个方法的调用参数和返回参数，所以可以模拟重新请求
>
> ```shell
> tt -i 1002 -p
> #	再重新调用3次
> tt -i 1002 -p --replay-interval 3
> #	再重新调用3次,并且间隔2S
> tt -i 1008 -p --replay-times 3 --replay-interval 2000
> ```



### jad

反编译代码

```
jad com.bxlsj.crm.service.kaisen.KaiSenServiceImpl > KaiSenServiceImpl.java
```

可以将代码反编译成.java文件



### OGNL表达式



| 字段      | 含义                               |
| --------- | ---------------------------------- |
| params    | 请求参数                           |
| returnObj | 返回参数                           |
| target    | 目标方法中的变量。可以指定属性查看 |
| throwExp  | 查看异常                           |





## 业务操作

### mc和sc

sc可以查看类的加载情况

mc可以指定类来加载



### vmtool

作用：执行方法

- 无请求参数、请求参数为基础数据类型

  ```shell
  vmtool -x 3 --action getInstances --className com.bxlsj.crm.service.kaisen.KaiSenServiceImpl  --express 'instances[0].transcodingPhone("T372855509598081024")' 
  ```

- 请求参数为对象

  先获取到需要操作的类的classLoaderHash

  ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/image-20240318161447961.png)

  ```shell
  sc -d 类的全路径名
  ```

  指定类及类中的属性

  ```shell
  vmtool -x 3 -c 76707e36 --action getInstances --className com.xxx.impl.IbCcContactConfigServiceImpl --express 'instances[0].queryIbCcContactConfig((#demo=new com.xxx.param.IbCcContactConfigParam(), #demo.setContactBizCode('12345L'),#demo)*)'
  ```

| 参数   | 解释                                                         |
| ------ | ------------------------------------------------------------ |
| -x 3   | 返回参数展开形式的，默认1，如果返回体是对象，建议设置3，方便观察返回结果 |
| -c xxx | 指定classLoaderHash，如果不指定，new 方法报错                |



### getstatic

查看静态变量的值

```shell
getstatic 类名 变量名
```







[Arthas 来辅助我的日常工作](https://juejin.cn/post/7291931708920512527)

