# 工具&网站

[智谱embedding接口文档](https://open.bigmodel.cn/dev/api#text_embedding)

[redis-search使用方法（类似elasticsearch）](https://zhuanlan.zhihu.com/p/265427217)





# 概述

## LM

Ngram语言模型

> 简单模型就是把一句话切成一个个词，然后统计概率，这类模型叫做Ngram语言模型，是最简单的语言模型，这里的N表示每次用到的上下文长度。还是举个例子，看下面这句话：「我喜欢在深夜的星空下伴随着月亮轻轻地想你」。常用的N=2或3，等于2的叫Bi-Gram，等于3的叫Tri-Gram：
>
> - Bi-Gram：我/喜欢 喜欢/在 在/深夜 深夜/的 的/星空 星空/下……
> - Tri-Gram：我/喜欢/在 喜欢/在/深夜 在/深夜/的 深夜/的/星空 的/星空/下……

Token

> 实际中我们往往不叫一个词为「词」，而是「Token」，你可以将其理解为一小块，可以是一个字，也可以是两个字的词，或三个字的词，取决于你怎么Token化。也就是说，给定一个句子时，我有多种Token化方式，可以分词，也可以分字，英文现在都是分子词。比如单词Elvégezhetitek，Token化后变成了：
>
> ```python
> ['El', '##vé', '##ge', '##zhet', '##ite', '##k']
> ```

卷积神经网络（convolutional neural network，CNN）

RNN模型

> Recurrent Neural Network，中文叫循环神经网络。RNN 模型与其他神经网络不同的地方在于，它的节点之间存在循环连接，这使得它能够记住之前的信息，并将它们应用于当前的输入。
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/202407031154592.png)



## Transformer

基于注意力机制的编码器-解码器（Encoder-Decoder）架构

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/202407031344884.png)



Encoder-Decoder架构

> 简单来说就是先把输入映射到Encoder，这里大家可以把Encoder先想象成上面介绍的RNN，Decoder也可以想象成RNN。这样，左边负责编码，右边则负责解码。**这里面不同的是，左边因为我们是知道数据的，所以建模时可以同时利用当前Token的历史Token和未来（前面的）Token；但解码时，因为是一个Token一个Token输出来的，所以只能根据历史Token以及Encoder的Token表示进行建模，而不能利用未来的Token**。

Self-Attention机制

> Attention机制与Self-Attention机制的区别
>
> 传统的Attention机制发生在Target的元素和Source中的所有元素之间。
>
> 简单讲就是说Attention机制中的权重的计算需要Target来参与。即在Encoder-Decoder 模型中，Attention权值的计算不仅需要Encoder中的隐状态而且还需要Decoder中的隐状态。
>
> **Self-Attention：**
>
> 不是输入语句和输出语句之间的Attention机制，而是输入语句内部元素之间或者输出语句内部元素之间发生的Attention机制。
>
> 例如在Transformer中在计算权重参数时，将文字向量转成对应的KQV，只需要在Source处进行对应的矩阵操作，用不到Target中的信息。

Seq2Seq（sequence to sequence）架构

> 也就是输入是一个文本序列，输出是另一个文本序列。

多头注意力（Multi-Head Attention）

> 简单说，就是一句话的前面的token会有多个头关注后面不同的结果
>
> 它是解码器中的Token和编码器中每一个Token的重要性权重。多头注意力中用到一个东西叫自注意力（Self-Attention），和刚刚说的注意力非常类似，只不过它是自己的每一个Token和自己的每一个Token的重要性权重。简单来说，就是“一句话到底哪里重要”。自注意力机制可以说是非常精髓了，无论是ChatGPT，还是其他非文本的模型，几乎都用到了它，可以说是真正的一统江湖。多头（Multi-Head），简单来说就是把刚刚的这种自己注意自己重复多次（multi个head），每个头注意到的信息不一样，这样就可以捕获到更多信息。比如我们前面提过的这句话：“人工智能让世界变得更美好”，有的头（Head）“人工智能”注意到“世界”，有的头“人工智能”注意到“美好”……这样看起来是不是更加符合直觉。

前馈（Feed Forward）网络

> 可以简单地把它当作“记忆层”，大模型的大部分知识都存在这里面，多头注意力则根据不同权重的注意力提取知识。另外，有个地方也要特别注意下，在解码器的黄色模块力有一个遮盖多头注意力（Masked Multi-Head Attention），它和多头注意力的区别就是遮盖（mask）掉未来的Token。我们在本节内容开始时提到过，再以前面Seq2Seq的翻译为例，给定“Knowledge”生成下一个Token时，模型当然不知道下一个就是“is”。还记得上一节讲的学习（训练）过程吗，下一个Token是“is”是我们训练数据里的，模型输出什么Token要看最大的概率是不是在“is”这个Token上，如果不在，参数就得更新。

自然语言理解（natural language understanding，NLU）

自然语言生成（natural language generation，NLG）

总结：

Transformer这个架构基于Seq2Seq，可以同时处理自然语言理解和生产任务，而且这种自注意力机制的特征提取能力（表示能力）很强大。结果就是自然语言处理取得了阶段性的突破，深度学习开始进入了**微调模型**时代。大概的做法就是**拿着一个开源的预训练模型，然后在自己的数据上微调一下，让它能够完成特定的任务。**这个开源的预训练模型往往就是个语言模型，从大量数据语料上，使用我们前面讲的语言模型的训练方法训练而来。**偏自然语言理解领域的第一个工作是Google的BERT**（bidirectional encoder representations from transformers，BERT），相信不少人即便不是这个行业的也大概听过。BERT就是用了Transformer的编码器（没有用解码器），有12个Block（图1-7左侧的黄色模块，这每一个Block也可以叫一层），1亿多参数，它不预测下一个Token，而是随机把15%的Token盖住（其中80%用`[MASK]`替换，10%保持不变，10%随机替换为其他Token），然后利用其他没盖住的Token来预测盖住位置的Token。其实和根据上文预测下一个Token是类似的，不同的是可以利用下文信息。**偏自然语言生成领域的第一个工作是OpenAI的GPT**（generative pre-trained transformer，GPT），用的是Transformer的解码器（没有用编码器），参数和BERT差不多。它们都发表于2018年，然后分别走上了两条不同的路。



## GPT

​	就是ChatGPT的那个GPT，中文叫“**生成式预训练Transformer**”。生成式的意思就是类似语言模型那样，一个Token接着一个Token生成文本，也就是上面提到的解码器。预训练刚刚也提过了，就是在大量语料上训练的语言模型。GPT模型从1到4，一共经历了5个版本，中间有个ChatGPT是3.5版。

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/202407031429869.png)

温度（temperature）

> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/202407031459865.png)



## RLHF

Reinforcement Learning from Human Feedback，从人类反馈中学习

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/202407031548884.png)



- 步骤一：SFT，Supervised Fine-Tuning，有监督微调。顾名思义，它是在有监督（有标注）数据上微调训练得到的。这里的监督数据其实就是输入提示词，输出相应的回复，只不过这里的回复是人工编写的。这个工作要求比一般标注要高，其实算是一种创作。
- 步骤二：RM，Reward Model，奖励模型。具体来说，一个提示词丢给前一步的SFT，输出若干个（4-9个）回复，由标注人员对这些回复进行排序。然后从4-9个中每次取2个，因为是有序的，就可以用来训练这个奖励模型，让模型学习到这个好坏评价。这一步非常关键，它就是所谓的Human Feedback，引导下一步模型的更新方向。
- 步骤三：RL，Reinforcement Learning，强化学习，使用PPO策略进行训练。PPO，Proximal Policy Optimization，近端策略优化，是一种强化学习优化方法，它背后的主要思想是避免每次太大的更新，提高训练的稳定性。具体过程如下：首先需要初始化一个语言模型，然后丢给它一个提示词，它生成一个回复，上一步的RM给这个回复一个打分，这个打分回传给模型更新参数。这里的语言模型在强化学习视角下就是一个策略。这一步有个很重要的动作，就是更新模型时会考虑模型每一个Token的输出和第一步SFT输出之间的差异性，要让它俩尽量相似。这是为了缓解强化学习可能的过度优化。



# Embedding

embedding的演化

## Embedding表示

第一步：分词/token化

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/202407031602205.png)

第二步：记录

将token转换成词表

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/202407031606580.png)

## 如何表示一句话

当前最好的方式就是：直接对词向量取平均。**无论一句话或一篇文档有多少个词，找到每个词的词向量，平均就好了，得到的向量大小和词向量一样**。事实上，在深度学习NLP刚开始的几年，这种方式一直是主流，也出现了不少关于如何平均的工作，比如使用加权求和，权重可以根据词性、句法结构等设定一个固定值。

## ChatGPT接口使用

### Embedding接口

获取一句话的embedding结果

```python
import os
import openai

if __name__ == '__main__':
    OPENAI_TOKEN = os.environ.get("OPENAI_API_KEY")
    openai.api_key = OPENAI_TOKEN
    str = "我爱蛋炒饭"
    model = "text-embedding-ada-002"
    openai.Model = "text-embedding-ada-002"
    emb_req = openai.embeddings.create(input=[str], model=model)
    print(emb_req)
```

输出的内容是

```python
emb = emb_req.data[0].embedding
len(emb) == 1536
type(emb) == list
```

一个data数组节点下包含1536个浮点数

> 相似度实验
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/202407031632944.png)

```python
import os
from zhipuai import ZhipuAI
import numpy as np


def embedding(str):
    zhipu_client = ZhipuAI(api_key=os.environ.get("ZHIPU_API_KEY"))
    emb_req = zhipu_client.embeddings.create(
        model="embedding-2",  # 填写需要调用的模型名称
        input=str,
    )
    return emb_req.data[0].embedding


def similarity(str):
    zhipu_client = ZhipuAI(api_key=os.environ.get("ZHIPU_API_KEY"))
    emb_req = zhipu_client.embeddings.create(model="embedding-2", input=str)


# 计算两个向量的余弦相似度
def cosine_similarity(vec1, vec2):
    return np.dot(vec1, vec2) / (np.linalg.norm(vec1) * np.linalg.norm(vec2))


def cosine_similarity_text(text1, text2):
    emb1 = embedding(text1)
    emb2 = embedding(text2)
    return cosine_similarity(emb1, emb2)


if __name__ == '__main__':
    # print(embedding("我爱吃蛋炒饭"))
    # similarity_prompt(OPENAI_TOKEN)
    print(f"相似度1:" + str(cosine_similarity_text("我爱吃蛋炒饭", "我不爱吃蛋炒饭")))
    print(f"相似度1:" + str(cosine_similarity_text("我爱吃蛋炒饭", "我爱吃蛋炒饭")))

```



### 增加提示词

```python
def similarity_prompt(openai_api_key):
    content = "请告诉我下面三句话的相似程度：\n1. 我喜欢你。\n2. 我钟意你。\n3.我不喜欢你。\n"
    response = openai.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": content}]
    )
    print(response.choices[0].message.content)
```

输出

> 第一句和第二句表达的感情相似度较高，都是表示喜欢对方；而第三句表达的感情与前两句相比较不同，表示不喜欢对方。因此，第一句和第二句的相似程度较高，第三句与前两句的相似程度较低。



为什么chatgpt已经给处理的这么完善了，我们还要自己关注`Embedding`呢？

1. 有些问题使用Embedding解决（或其他非ChatGPT的方式）会更加合理。通俗来说就是“杀鸡焉用牛刀”。
2. ChatGPT性能方面不是特别高效，毕竟是一个Token一个Token吐出来的。

### 经典任务

以问题找问题



```python
import os
from zhipuai import ZhipuAI
import numpy as np


def embedding(str):
    zhipu_client = ZhipuAI(api_key=os.environ.get("ZHIPU_API_KEY"))
    emb_req = zhipu_client.embeddings.create(
        model="embedding-2",  # 填写需要调用的模型名称
        input=str,
    )
    return emb_req.data[0].embedding


def similarity(str):
    zhipu_client = ZhipuAI(api_key=os.environ.get("ZHIPU_API_KEY"))
    emb_req = zhipu_client.embeddings.create(model="embedding-2", input=str)


# 计算两个向量的余弦相似度
def cosine_similarity(vec1, vec2):
    return np.dot(vec1, vec2) / (np.linalg.norm(vec1) * np.linalg.norm(vec2))


def cosine_similarity_text(text1, text2):
    emb1 = embedding(text1)
    emb2 = embedding(text2)
    return cosine_similarity(emb1, emb2)


def gpt_similarity():
    content = """请告诉我下面三句话的相似程度：
    1. 我喜欢你。
    2. 我钟意你。
    3. 我不喜欢你。
    第一句话用1表示，第二句话用2表示，第三句话用3表示。
    请以json格式输出两两语义相似度。仅输出json，不要输出其他任何内容。
    """
    zhipu_client = ZhipuAI(api_key=os.environ.get("ZHIPU_API_KEY"))
    response = zhipu_client.chat.completions.create(
        model="glm-3-turbo",
        messages=[
            {"role": "user", "content": content},
        ],
    )
    print(response.choices[0].message.content)

if __name__ == '__main__':
    # print(embedding("我爱吃蛋炒饭"))
    # similarity_prompt(OPENAI_TOKEN)
    #print(f"相似度1:" + str(cosine_similarity_text("我爱吃蛋炒饭", "我不爱吃蛋炒饭")))
    #print(f"相似度1:" + str(cosine_similarity_text("我爱吃蛋炒饭", "我爱吃蛋炒饭")))
    gpt_similarity()

```

```python
import numpy as np
import pandas as pd
import redis
from redis.commands.search.query import Query

import embedding.embedding_zhipu_utils

VECTOR_DIM = 1024  # 智谱AI需改为1024，因为智谱AI的Embedding维度是1024
INDEX_NAME = "faq"


def getRedis():
    return redis.Redis(host="localhost", db=0, port=6379)


# 预处理数据
def deal_csv():
    csv_content = pd.read_csv("../dataset/seat_qa.csv")
    # print(f"长度:" + str(len(csv_content)))
    # csv_content.head()默认读取前五行
    vec_base_list = []
    # 对question进行向量化
    for v in csv_content.head().itertuples():
        q = v.Questions
        a = v.Link
        emb = embedding.embedding_zhipu_utils.embedding(q)
        emb = np.array(emb, dtype=np.float32).tobytes()
        item = {
            "question": q,
            "answer": a,
            "embedding": emb
        }
        vec_base_list.append(item)
        # 保存在redis中
        getRedis().hset(name=f"{INDEX_NAME}-{v.Index}", mapping=item)


def deal_question():
    # 构造查询输入
    print("请输入问题")
    query = input()
    # query = "你好，你叫什么名字"
    embed_query = embedding.embedding_zhipu_utils.embedding(query)
    # 构建查询条件
    params_dict = {"query_embedding": np.array(embed_query).astype(dtype=np.float32).tobytes()}
    # 找到最相似的三个回答
    k = 3
    # 使用KNN表达式在已经建立的HNSW（高效的相似搜索算法）索引中，查询条件为$query_embedding，搜索最近的三个结果
    # KNN（K最近邻算法），简单来说就是对未知点，分别和已有的点算距离，挑距离最近的K个点
    # {some filter query}=>[ KNN {num|$num} @vector_field $query_vec]
    base_query = f"* => [KNN {k} @embedding $query_embedding AS score]"
    return_fields = ["question", "answer", "score"]
    # 构建查询语句
    query = (
        Query(base_query)
        .return_fields(*return_fields)
        .sort_by("score")
        .paging(0, k)
        .dialect(2)
    )
    # 使用redis查询
    res = getRedis().ft(INDEX_NAME).search(query, params_dict)
    if (1 - float(res.docs[0].score) < 0.3):
        print("对不起，我的知识库暂时无法解答您的问题")
    else:
        print(res.docs[0].answer)


if __name__ == '__main__':
    # deal_csv()
    deal_question()

```



# 句词分类

## 简述

NLU是Natural Language Understanding的简称，即自然语言理解。

具体点来说，当用户输入一句话时，机器人一般会针对该句话（也可以把历史记录给附加上）进行全方面分析，包括：

+ 情感倾向分析
+ 意图识别
  + 多分类：给定输入文本，输出为一个Label，但Label的总数有多个。比如类型包括询问地址、询问时间、询问价格、闲聊等等。
  + 层次分类：给定输入文本，输出为层次的Label，也就是从根节点到最终细粒度类别的路径。比如询问地址/询问家庭地址、询问地址/询问公司地址等等。
  + 多标签分类：给定输入文本，输出不定数量的Label，也就是说每个文本可能有多个Label，Label之间是平级关系。
+ 实体和关系抽取

## API

利用大模型的**In-Context**能力进行**Zero-Shot**或**Few-Shot**的推理。这里有四个概念需要先稍微解释一下：

- GPT：全称是Generative Pretrained Transformer，生成式预训练Transformer。大家只要知道它是一个大模型的名字即可。
- **In-Context**：简单来说就是一种上下文能力，也就是模型只要根据输入的文本就可以自动给出对应的结果，这种能力是大模型在学习了非常多的文本后获得的。可以看作是一种内在的理解能力。
- **Zero-Shot**：直接给模型文本，让它给出你要的标签或输出。
- **Few-Shot**：给模型一些类似的Case（输入+输出），再拼上一个新的没有输出的输入，让模型给出输出。

openai接口参数：

+ `model`：指定的模型，如`gpt-3.5-turbo`
+ `messages`：会话消息，支持多轮，多轮就是多条。每一条消息为一个字典，包含「role」和「content」两个字段。如：`[{"role": "user", "content": "Hello!"}]`
+ `max_tokens`：生成的最大Token数，默认为16。注意这里的Token数不一定是字数（但对中文来说几乎一致）。Prompt+生成的文本，所有的Token长度不能超过模型的上下文长度（一般是2048，新的是4096，具体可以参考上面的链接）。
+ `temperature`：温度，默认为1。采样温度，介于0和2之间。较高的值（如0.8）将使输出更加随机，而较低的值（如0.2）将使其更加集中和确定。通常建议调整这个参数或下面的top_p，但不能同时更改两者。
+ `top_p`：采样topN分布，默认为1。0.1意味着Next Token只选择前10%概率的。
+ `stop`：停止的Token或序列，默认为null，最多4个，如果遇到该Token或序列就停止继续生成。注意生成的结果中不包含stop。
+ `presence_penalty`：存在惩罚，默认为0，介于-2.0和2.0之间的数字。正值会根据新Token到目前为止是否出现在文本中来惩罚它们，从而增加模型讨论新主题的可能性。
+ `frequency_penalty`：频率惩罚，默认为0，介于-2.0和2.0之间的数字。正值会根据新Token到目前为止在文本中的现有频率来惩罚新Token，降低模型重复生成同一行的可能性。

```python
def zhipu_chat_api(content):
    zhipu_client = ZhipuAI(api_key=os.environ.get("ZHIPU_API_KEY"))

    resp = zhipu_client.chat.completions.create(
        model="glm-4",
        messages=[
            {"role": "user", "content": f"{content}"}
        ]
    )
    return resp.choices[0].message
```

+ 使用`Zero-Shot`

  ```python
  # Zero-Shot
  prompt_zero_shot = """The following is a list of companies and the categories they fall into:
  
  Apple, Facebook, Fedex
  
  Apple
  Category:
  """
  ```

+ 使用`Few-Shot`

  ```python
  # Few-Shot
  prompt_few_shot = """今天真开心。-->正向
  心情不太好。-->负向
  我们是快乐的年轻人。-->
  """
  ```

我们想要更准确的回答，可以使用Few-Shot

## 应用

文档问答

和Q&A不同的是回答的内容是一个文档中的。也就是大模型需要针对这个文档进行解析问题答案

第一步：将文本内容向量化，存储在数据库中

第二步：将问题向量化，并在数据库中获取相似度最大的文本

第三步：将使用向量化获取的文本和问题一起发送给大模型，大模型会针对问题在文本中找对应的答案



# 文本生成

## 文本摘要

### 基于预训练模型

基于mT5模型（T5模型的多语言版）的文本摘要样例

```python
import re
import torch
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
 
# 载入模型 
tokenizer = AutoTokenizer.from_pretrained("csebuetnlp/mT5_multilingual_XLSum")
model = AutoModelForSeq2SeqLM.from_pretrained("csebuetnlp/mT5_multilingual_XLSum")

WHITESPACE_HANDLER = lambda k: re.sub('\s+', ' ', re.sub('\n+', ' ', k.strip()))

text = """自动信任协商主要解决跨安全域的信任建立问题,使陌生实体通过反复的、双向的访问控制策略和数字证书的相互披露而逐步建立信任关系。由于信任建立的方式独特和应用环境复杂,自动信任协商面临多方面的安全威胁,针对协商的攻击大多超出常规防范措施所保护的范围,因此有必要对自动信任协商中的攻击手段进行专门分析。按攻击特点对自动信任协商中存在的各种攻击方式进行分类,并介绍了相应的防御措施,总结了当前研究工作的不足,对未来的研究进行了展望"""
text = WHITESPACE_HANDLER(text)
input_ids = tokenizer([text], return_tensors="pt", padding="max_length", truncation=True, max_length=512)["input_ids"]

# 生成结果文本
output_ids = model.generate(input_ids=input_ids, max_length=84, no_repeat_ngram_size=2, num_beams=4)[0]
output_text = tokenizer.decode(output_ids, skip_special_tokens=True, clean_up_tokenization_spaces=False)

print("原始文本: ", text)
print("摘要文本: ", output_text)
```





### 基于openAI



使用模型：`text-davinci-003` 、`gpt-3.5-turbo`

```python
def summarize_text(text):
    response = openai.Completion.create(
        engine="text-davinci-003",
        prompt=f"请对以下文本进行总结，注意总结的凝炼性，将总结字数控制在20个字以内:\n{text}",
        temperature=0.3,  # 越小，确定性越强，越大，创造性越强
        max_tokens=500,   # 输出多少个token
    )

    summarized_text = response.choices[0].text.strip()
    return summarized_text

text = "自动信任协商主要解决跨安全域的信任建立问题,使陌生实体通过反复的、双向的访问控制策略和数字证书的相互披露而逐步建立信任关系。由于信任建立的方式独特和应用环境复杂,自动信任协商面临多方面的安全威胁,针对协商的攻击大多超出常规防范措施所保护的范围,因此有必要对自动信任协商中的攻击手段进行专门分析。按攻击特点对自动信任协商中存在的各种攻击方式进行分类,并介绍了相应的防御措施,总结了当前研究工作的不足,对未来的研究进行了展望。"""
output_text = summarize_text(text)
print("原始文本: ", text)
print("摘要文本: ", output_text)
print("摘要文本长度: ", len(output_text))
```



### 基于自定义语料fine tune

目前OpenAI仅开放了ada, babbage, curie, davinci四个小模型的fine tune接口，其中最大的davinci模型约175亿参数。

