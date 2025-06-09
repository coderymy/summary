> 可用开源商用预训练大模型
>
> + Gpt
> + Llama2
> + ChatGLM2

参数量=大模型的生成能力、推理能力，参数越多学习能力使用能力越强

# Propt提示词工程

> 如何让大模型更贴近需求，让大模型的回答和自己的需要更一致，就需要讲提示词提前的给到大模型。
>
> 需要在使用之前将提示词工程切入到大模型。众多的专业的大模型都是提前讲这个应用的提示词赋予给大模型得到的结果
>
> 提示词的核心技术：
> 
> + N-gram（2-gram就是由前一个词预测后一个词，3-gram就是由前两个词预测后面一个词）
> + 深度学习：从数据中学习数据的特征，让模型一直学习，使返回的结果更符合预期
>
> 





# Transformers

embedding：向量化，将人类的语言通过12000个维度解释成矩阵来方便计算机理解

encoder，编码器，尝试理解输入的内容。理解语义

deocoder，解码器，通过前面的理解进行推理和运算









# 多模态

可以处理多种数据类型的，可以处理，语音、文本、图片。可以说，听，看





# 名词解释

## 知识库

存储知识和信息的数据库

+ 传统数据库
+ AI数据库：与LLM的结合。结构更切合AI的需要。**同时可以做到AI对话的方式获取其中存储的信息**



## embedding

嵌入，向量化。讲文本转换成模型可以读懂的内容

## prompt engineer

提示词工程

## RAG

检索增强生成

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240518194707.png)

整个流程就叫做RAG，检索增强生成



## 微调

优化已有的人工智能模型来适应特定任务/数据集



## AI agent

+ 信息检索和做决策
+ 以目标为导向
+ 可以适应和学习的

可以理解成**互联网上的一个人**，可以执行很多复杂的操作，进行一个目标所需要的工作的聚合

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240519200249.png)





# Langchain

一个工程架构，（AI agent背后的架构就是Langchain）

诞生来自于：大数据+人工智能

为用户提供友好的可视化的编辑工具



## 基本原理

### 数据输入

将文本数据输入langchain之后，会进行数据清洗，检查哪些有效哪些是无用的（标点等）

+ 手动输入
+ 文件上传
+ 数据库连接

### 数据分析

分析引擎：将杂乱的数据分析出有用的东西

使用了很多算法

+ 文本分类模型
+ 情感分析模型（正面/负面/中性）
+ 主题建模

合并很多小模型来做到分析

### 输出

分析结果以各种形式展示给用户

+ 图表类
+ 文本报告
+ 互动界面



# ChatGLM2+Langchain

ChatGLM2是清华开源的大预言模型，对中文最友好，可商用



Langchain，非常占显存，消费级显卡无法使用

## 部署





![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240519203145.png)

其中Temperature：大模型温度，小则大模型内容死板严谨，大则大模型内容灵活充满想象力（缺失专业性）

历史对话轮数：使大模型具有记忆力，可以联系上下文进行回答







## 配置



mse-base：模型的位置，本地部署，需要修改



+ 提示词配置：Lang-chain-Chatchat/configs/prompt_config.py
+ 搜索引擎配置：Lang-chain-Chatchat/configs/kb_config.py

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240519204916.png)



## 构建知识库

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240519204938.png)



![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240519205126.png)	

embedding模型：将上传的知识库转换成机器可以识别的语言（数字，数字，数字）

> 智谱AI
>
> 也是国内的清华开源的大模型底座





# 微调

## 部署

> 阿里云**机器学习PAI**试用

DAW建模->

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240519213107.png)

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240519213240.png)



## 一键微调

直接修改数据集，将自己需要的数据集导入进去使用





# 私有化大模型

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240519220326.png)


![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240519220349.png)




![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240519220405.png)



![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo20240519220416.png)



按量付费

计算型c7

ubuntu22.04

5M

