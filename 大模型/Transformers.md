# 快速体验

## 安装conda

conda：主要用来管理软件包和虚拟环境。大量应用于python项目

下载：https://www.anaconda.com/

安装：一键安装

检查安装：`conda --version`

创建虚拟环境：`conda create -n pyt` ，其中`-n`后面跟要创建的名称



## 安装pytorch

> **[PyTorch](https://www.baidu.com/s?wd=PyTorch&usm=2&ie=utf-8&rsv_pq=c2c8236d0024ef71&oq=pytorch是什么&rsv_t=945f2RrAb5TMr%2F1SHbXF3yDC8cA0OrF4E0gt85Qg0heK1%2BL0rz6f51Ufr5o&sa=re_dqa_zy&icon=1)是一个开源的[Python](https://www.baidu.com/s?wd=Python&usm=2&ie=utf-8&rsv_pq=c2c8236d0024ef71&oq=pytorch是什么&rsv_t=43a4d2osl1M09Ug2SqD9BPDkpEgdEjh2Gj6zTFW%2Fm7cszzm333QOhlC7bOk&sa=re_dqa_zy&icon=1)机器学习库，基于[Torch](https://www.baidu.com/s?wd=Torch&usm=2&ie=utf-8&rsv_pq=c2c8236d0024ef71&oq=pytorch是什么&rsv_t=43a4d2osl1M09Ug2SqD9BPDkpEgdEjh2Gj6zTFW%2Fm7cszzm333QOhlC7bOk&sa=re_dqa_zy&icon=1)，用于自然语言处理等应用程序。**它可以看作加入了GPU支持的[numpy](https://www.baidu.com/s?wd=numpy&usm=2&ie=utf-8&rsv_pq=c2c8236d0024ef71&oq=pytorch是什么&rsv_t=43a4d2osl1M09Ug2SqD9BPDkpEgdEjh2Gj6zTFW%2Fm7cszzm333QOhlC7bOk&sa=re_dqa_zy&icon=1)，同时也可以看成一个拥有自动求导功能的强大的[深度神经网络](https://www.baidu.com/s?wd=深度神经网络&usm=2&ie=utf-8&rsv_pq=c2c8236d0024ef71&oq=pytorch是什么&rsv_t=43a4d2osl1M09Ug2SqD9BPDkpEgdEjh2Gj6zTFW%2Fm7cszzm333QOhlC7bOk&sa=re_dqa_zy&icon=1)。PyTorch提供了两个高级功能：1.具有强大的GPU加速的张量计算（如NumPy），2.包含自动求导系统的深度神经网络。

先使用`conda install python==3.11.7`再conda的环境里安装python

安装：`conda install pytorch::pytorch torchvision torchaudio -c pytorch`

测试，进入python环境执行以下代码

```python
>>> import torch
>>> x=torch.rand(2,3)
>>> x
```

## pycharm中安装pytorch虚拟环境

1. 创建一个项目，注意使用的python版本

2. settings->python interpreter ->Add interpreter ->Add local interpreter ->conda Environment ->Use existing environment 

3. 执行以下代码测试，注意需要魔法上网。调用对应的模型库来完成下面的操作

   ```python
   from transformers import BertTokenizer, GPT2LMHeadModel,TextGenerationPipeline
   
   tokenizer = BertTokenizer.from_pretrained("uer/gpt2-chinese-poem")
   
   model = GPT2LMHeadModel.from_pretrained("uer/gpt2-chinese-poem")
   
   text_generator = TextGenerationPipeline(model, tokenizer)
   
   result=text_generator("[CLS] 万叠春山积雨晴", max_length=50, do_sample=True)
   
   print (result)
   
   ```



# 开箱即用的pipelines

> ransformers 库将目前的 NLP 任务归纳为几下几类：
>
> - **文本分类：**例如情感分析、句子对关系判断等；
> - **对文本中的词语进行分类：**例如词性标注 (POS)、命名实体识别 (NER) 等；
> - **文本生成：**例如填充预设的模板 (prompt)、预测文本中被遮掩掉 (masked) 的词语；
> - **从文本中抽取答案：**例如根据给定的问题从一段文本中抽取出对应的答案；
> - **根据输入文本生成新的句子：**例如文本翻译、自动摘要等。
>
> Transformers 库最基础的对象就是 `pipeline()` 函数，它封装了预训练模型和对应的前处理和后处理环节。我们只需输入文本，就能得到预期的答案。目前常用的 [pipelines](https://huggingface.co/docs/transformers/main_classes/pipelines) 有：
>
> - `feature-extraction` （获得文本的向量化表示）
> - `fill-mask` （填充被遮盖的词、片段）
> - `ner`（命名实体识别）
> - `question-answering` （自动问答）
> - `sentiment-analysis` （情感分析）
> - `summarization` （自动摘要）
> - `text-generation` （文本生成）
> - `translation` （机器翻译）
> - `zero-shot-classification` （零训练样本分类）

pipeline 模型会自动完成以下三个步骤：

1. 将文本预处理为模型可以理解的格式；
2. 将预处理好的文本送入模型；
3. 对模型的预测值进行后处理，输出人类可以理解的格式。

部分pipeline需要魔法上网

## 情感分析

```
def emotion_pipeline():
    classifier = pipeline("sentiment-analysis")
    result = classifier("I've been waiting for a HuggingFace course my whole life.")
    print(result)
    results = classifier(
        ["I've been waiting for a HuggingFace course my whole life.", "I hate this so much!"]
    )
    print(results)
```

```
[{'label': 'POSITIVE', 'score': 0.9598051905632019}]
[{'label': 'POSITIVE', 'score': 0.9598051905632019}, {'label': 'NEGATIVE', 'score': 0.9994558691978455}]
```

![full_nlp_pipeline](https://transformers.run/assets/img/transformers-note-1/full_nlp_pipeline.png)

1. 预处理 (preprocessing)，将原始文本转换为模型可以接受的输入格式；
2. 将处理好的输入送入模型；
3. 对模型的输出进行后处理 (postprocessing)，将其转换为人类方便阅读的格式。



### 使用分词器进行预处理

将文本转换成模型可以理解的数字

1. 将输入切分为词语、子词或者符号（例如标点符号），统称为 **tokens**；
2. 根据模型的词表将每个 token 映射到对应的 token 编号（就是一个数字）；
3. 根据模型的需要，添加一些额外的输入。

```python
def pre_deal_content():
    checkpoint = "distilbert-base-uncased-finetuned-sst-2-english"
    tokenizer = AutoTokenizer.from_pretrained(checkpoint)

    raw_inputs = [
        "I've been waiting for a HuggingFace course my whole life.",
        "I hate this so much!",
    ]
    inputs = tokenizer(raw_inputs, padding=True, truncation=True, return_tensors="pt")
    print(inputs)
```

```
{'input_ids': tensor([[  101,  1045,  1005,  2310,  2042,  3403,  2005,  1037, 17662, 12172,
          2607,  2026,  2878,  2166,  1012,   102],
        [  101,  1045,  5223,  2023,  2061,  2172,   999,   102,     0,     0,
             0,     0,     0,     0,     0,     0]]), 'attention_mask': tensor([[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0]])}
```

输出包含`input_ids` 和 `attention_mask`

+ `input_ids`：对应分词之后的 tokens 映射到的数字编号列表
+ `attention_mask`：是否是填充数据，1表示原文 0表示填充数



### 输入模型

Transformer 模块的输出是一个维度为 (Batch size, Sequence length, Hidden size) 的三维张量，其中 Batch size 表示每次输入的样本（文本序列）数量，即每次输入多少个句子，上例中为 2；Sequence length 表示文本序列的长度，即每个句子被分为多少个 token，上例中为 16；Hidden size 表示每一个 token 经过模型编码后的输出向量（语义表示）的维度。

输出transformer模块的输出

```python
checkpoint = "distilbert-base-uncased-finetuned-sst-2-english"
tokenizer = AutoTokenizer.from_pretrained(checkpoint)
model = AutoModel.from_pretrained(checkpoint)

raw_inputs = [
    "I've been waiting for a HuggingFace course my whole life.",
    "I hate this so much!",
]
inputs = tokenizer(raw_inputs, padding=True, truncation=True, return_tensors="pt")
outputs = model(**inputs)
print(outputs.last_hidden_state.shape)
```

```
torch.Size([2, 16, 768])
```



预训练模型的本体只包含基础的 Transformer 模块，对于给定的输入，它会输出一些神经元的值，称为 hidden states 或者特征 (features)。对于 NLP 模型来说，可以理解为是文本的高维语义表示。这些 hidden states 通常会被输入到其他的模型部分（称为 head），以完成特定的任务，例如送入到分类头中完成文本分类任务。

> 其实前面我们举例的所有 pipelines 都具有类似的模型结构，只是模型的最后一部分会使用不同的 head 以完成对应的任务。
>
> ![transformer_and_head](https://transformers.run/assets/img/transformers-note-1/transformer_and_head.png)
>
> Transformers 库封装了很多不同的结构，常见的有：
>
> - `*Model` （返回 hidden states）
> - `*ForCausalLM` （用于条件语言模型）
> - `*ForMaskedLM` （用于遮盖语言模型）
> - `*ForMultipleChoice` （用于多选任务）
> - `*ForQuestionAnswering` （用于自动问答任务）
> - `*ForSequenceClassification` （用于文本分类任务）
> - `*ForTokenClassification` （用于 token 分类任务，例如 NER）

对于情感分析任务，很明显我们最后需要使用的是一个文本分类 head。因此，实际上我们不会使用 `AutoModel` 类，而是使用 `AutoModelForSequenceClassification`：

```python
def content_input_model():
    checkpoint = "distilbert-base-uncased-finetuned-sst-2-english"
    tokenizer = AutoTokenizer.from_pretrained(checkpoint)
    model = AutoModelForSequenceClassification.from_pretrained(checkpoint)

    raw_inputs = [
        "I've been waiting for a HuggingFace course my whole life.",
        "I hate this so much!",
    ]
    inputs = tokenizer(raw_inputs, padding=True, truncation=True, return_tensors="pt")
    outputs = model(**inputs)
    print(outputs.logits.shape)
```

对于 batch 中的每一个样本，模型都会输出一个两维的向量（每一维对应一个标签，positive 或 negative）。

```
torch.Size([2, 2])
```





### 对模型输出进行后处理

对模型输出的不适合人阅读的，进行处理

对于上面模型的输出outputs.logits。

```
tensor([[-1.5607,  1.6123],
        [ 4.1692, -3.3464]], grad_fn=<AddmmBackward0>)
```

模型对第一个句子输出 [−1.5607,1.6123]，对第二个句子输出 [4.1692,−3.3464]，它们并不是概率值，而是模型最后一层输出的 logits 值。要将他们转换为概率值，还需要让它们经过一个 [SoftMax](https://zh.wikipedia.org/wiki/Softmax函数) 层，例如：

```
predictions = torch.nn.functional.softmax(outputs.logits, dim=-1)
print(predictions)
```

> 所有 Transformers 模型都会输出 logits 值，因为训练时的损失函数通常会自动结合激活函数（例如 SoftMax）与实际的损失函数（例如交叉熵 cross entropy）。

再对具体的模型进行映射关系

就得出结果：

- 第一个句子: NEGATIVE: 0.0402, POSITIVE: 0.9598
- 第二个句子: NEGATIVE: 0.9995, POSITIVE: 0.0005









## 零训练样本分类

无训练样本，即可针对一段话，对其进行打标签

```
def zero_shot_classification_pipeline():
    classifier = pipeline("zero-shot-classification")
    result = classifier(
        "This is a course about the Transformers library",
        candidate_labels=["education", "politics", "business"],
    )
    print(result)

```

```
{'sequence': 'This is a course about the Transformers library', 'labels': ['education', 'business', 'politics'], 'scores': [0.8445977568626404, 0.1119752749800682, 0.0434269905090332]}
```

## 文本生成

```
def text_generation_pipeline():
    generator = pipeline("text-generation")
    results = generator("In this course, we will teach you how to")
    print(results)

    results = generator(
        "In this course, we will teach you how to",
        num_return_sequences=2,
        max_length=50
    )
    print(results)
```

```
[{'generated_text': "In this course, we will teach you how to implement multiple Java methods in memory. As each method is implemented with different implementation values, it's important to know about the different types of java.io.String, which can lead to unexpected results."}]
[{'generated_text': 'In this course, we will teach you how to work on one of your most popular projects. We hope to provide you with a comprehensive and helpful knowledge of how to make sure your project looks good on Mac and iOS.\n\n\nThis course will help'}, {'generated_text': 'In this course, we will teach you how to write a class for making your own, customizable and interactive software project. We will begin with a basic basic program, which can be compiled with C++, which is not very advanced. In this class'}]
```



## 遮盖词填充

```
from transformers import pipeline

unmasker = pipeline("fill-mask")
results = unmasker("This course will teach you all about <mask> models.", top_k=2)
print(results)
```

```

[{'sequence': 'This course will teach you all about mathematical models.', 
  'score': 0.19619858264923096, 
  'token': 30412, 
  'token_str': ' mathematical'}, 
 {'sequence': 'This course will teach you all about computational models.', 
  'score': 0.04052719101309776, 
  'token': 38163, 
  'token_str': ' computational'}]
```



## 命名实体识别

```
from transformers import pipeline

ner = pipeline("ner", grouped_entities=True)
results = ner("My name is Sylvain and I work at Hugging Face in Brooklyn.")
print(results)
```

```
[{'entity_group': 'PER', 'score': 0.9981694, 'word': 'Sylvain', 'start': 11, 'end': 18}, 
 {'entity_group': 'ORG', 'score': 0.97960186, 'word': 'Hugging Face', 'start': 33, 'end': 45}, 
 {'entity_group': 'LOC', 'score': 0.99321055, 'word': 'Brooklyn', 'start': 49, 'end': 57}]
```



## 自动问答

```
question_answerer = pipeline("question-answering")
answer = question_answerer(
    question="Where do I work?",
    context="My name is Sylvain and I work at Hugging Face in Brooklyn",
)
print(answer)
```

```
{'score': 0.6949771046638489, 'start': 33, 'end': 45, 'answer': 'Hugging Face'}
```

## 自动摘要

```
from transformers import pipeline

summarizer = pipeline("summarization")
results = summarizer(
    """
    America has changed dramatically during recent years. Not only has the number of 
    graduates in traditional engineering disciplines such as mechanical, civil, 
    electrical, chemical, and aeronautical engineering declined, but in most of 
    the premier American universities engineering curricula now concentrate on 
    and encourage largely the study of engineering science. As a result, there 
    are declining offerings in engineering subjects dealing with infrastructure, 
    the environment, and related issues, and greater concentration on high 
    technology subjects, largely supporting increasingly complex scientific 
    developments. While the latter is important, it should not be at the expense 
    of more traditional engineering.

    Rapidly developing economies such as China and India, as well as other 
    industrial countries in Europe and Asia, continue to encourage and advance 
    the teaching of engineering. Both China and India, respectively, graduate 
    six and eight times as many traditional engineers as does the United States. 
    Other industrial countries at minimum maintain their output, while America 
    suffers an increasingly serious decline in the number of engineering graduates 
    and a lack of well-educated engineers.
    """
)
print(results)
```

```
[{'summary_text': ' America has changed dramatically during recent years . The number of engineering graduates in the U.S. has declined in traditional engineering disciplines such as mechanical, civil, electrical, chemical, and aeronautical engineering . Rapidly developing economies such as China and India, as well as other industrial countries in Europe and Asia, continue to encourage and advance engineering .'}]

```









