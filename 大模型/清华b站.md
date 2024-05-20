# NLP

自然语言处理，让机器读懂人说的语言，并且可以和人对话



自然语言最主要的是对于自然语言的理解



实现上一共分为几个步骤



![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240510210030.png)

+ Part of speech：理解词性，名词/动词/形容词
+ Named entity recognition：命名实体的识别，名词中的实体，人名、地名、机构、地区、日期等
+ Co-reference：共指消解 ，将这句话中的一些指示性的词进行理解，比如她可能就是指上文中的一个名字
+ Basic dependencies：基础的依赖关系，基础的语法关系，比如谁是谁的主语，谁是谁的修饰
+ 其他：语言之间的关系，比如中文和英文的不同逻辑，没有空格，如何分词



## 自然语言处理的应用

+ 人机对话
+ 智能家居需要识别人说的是什么
+ 搜索引擎
+ 数据分析和挖掘，识别非常多的文章的内容





## 词的表示

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240510211656.png)

+ 词与词之间的相似度
+ 词与词之间的关系



早期通过对一个词人为的将其语义相近的词放在一起来表示一个词的语义。但是这样如果一个词发生了语义上的变化（apple）就需要再维护

后来通过两个方式

+ 将这个词放在一个维度足够大的维表中，每一个维度都代表了一个词性，当这个词满足这个词性，这个维度就是1，其他的就是0。

  ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240510212425.png)

+ 再通知这个词在自然语言中出现的上下文的词性来定义这个词

  ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240510212504.png)

## 语言模型

Language model 通过词的前文预测下一个词是什么（自然语言中的抢话）

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240510213207.png)

通过检索无数的文本，来计算too late to 后面出现wj的概率在所有too late to的概率，来算出我下面一个词应该是什么的概率最高



# 大模型

由于上述所说的对自然语言的处理，所需对于深度学习的依赖。所以真实的大模型是随着深度学习的发展而发展的

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240510213651.png)



## 预训练语言模型

针对上述的语言进行建模后生成的一个基本的语言模型我们就叫做预训练语言模型

在逐步的训练这个语言模型之后，会发现，当参数越来越多，数据越来越多。这个语言模型会变得更加的有效

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240510214020.png)



**通过预训练之后的模型（通用知识，比如理解某个人是谁，china是一个国家等），再导入大量的与特定任务相关的数据（中国法律相关】，中国保险相关），来生成一个解决具体任务的模型**



![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240510214422.png)





# 神经网络

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240510220623.png)









> 大模型
>
> 1、自然语言处理
>
> - 计算机读懂人的文字，可以交互
> - imitation game
> - 图灵测试：人机对话，验证机器是否具备人类智能
>
> 2、基本任务和应用
>
> - 词性标注
> - 识别命名实体
> - 省略：用代词替代实体，共指消解
> - 语法句法：互相依存关系
> - 语言区别：比如中文空格
>
> 3、从文本中提取知识：Google知识图谱
>
> 知识图谱：实体结构化信息匹配
>
> 构建machine reading自动阅读挖掘知识
>
> 搜索引擎
>
> 4、文本匹配、数据挖掘、信息检索等