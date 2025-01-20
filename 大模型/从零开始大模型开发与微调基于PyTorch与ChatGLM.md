> # 快速体验
>
> ## 安装conda
>
> conda：主要用来管理软件包和虚拟环境。大量应用于python项目
>
> 下载：https://www.anaconda.com/
>
> 安装：一键安装
>
> 检查安装：`conda --version`
>
> 创建虚拟环境：`conda create -n pyt` ，其中`-n`后面跟要创建的名称
>
> 
>
> ## 安装pytorch
>
> > **[PyTorch](https://www.baidu.com/s?wd=PyTorch&usm=2&ie=utf-8&rsv_pq=c2c8236d0024ef71&oq=pytorch是什么&rsv_t=945f2RrAb5TMr%2F1SHbXF3yDC8cA0OrF4E0gt85Qg0heK1%2BL0rz6f51Ufr5o&sa=re_dqa_zy&icon=1)是一个开源的[Python](https://www.baidu.com/s?wd=Python&usm=2&ie=utf-8&rsv_pq=c2c8236d0024ef71&oq=pytorch是什么&rsv_t=43a4d2osl1M09Ug2SqD9BPDkpEgdEjh2Gj6zTFW%2Fm7cszzm333QOhlC7bOk&sa=re_dqa_zy&icon=1)机器学习库，基于[Torch](https://www.baidu.com/s?wd=Torch&usm=2&ie=utf-8&rsv_pq=c2c8236d0024ef71&oq=pytorch是什么&rsv_t=43a4d2osl1M09Ug2SqD9BPDkpEgdEjh2Gj6zTFW%2Fm7cszzm333QOhlC7bOk&sa=re_dqa_zy&icon=1)，用于自然语言处理等应用程序。**它可以看作加入了GPU支持的[numpy](https://www.baidu.com/s?wd=numpy&usm=2&ie=utf-8&rsv_pq=c2c8236d0024ef71&oq=pytorch是什么&rsv_t=43a4d2osl1M09Ug2SqD9BPDkpEgdEjh2Gj6zTFW%2Fm7cszzm333QOhlC7bOk&sa=re_dqa_zy&icon=1)，同时也可以看成一个拥有自动求导功能的强大的[深度神经网络](https://www.baidu.com/s?wd=深度神经网络&usm=2&ie=utf-8&rsv_pq=c2c8236d0024ef71&oq=pytorch是什么&rsv_t=43a4d2osl1M09Ug2SqD9BPDkpEgdEjh2Gj6zTFW%2Fm7cszzm333QOhlC7bOk&sa=re_dqa_zy&icon=1)。PyTorch提供了两个高级功能：1.具有强大的GPU加速的张量计算（如NumPy），2.包含自动求导系统的深度神经网络。
>
> 先使用`conda install python==3.11.7`再conda的环境里安装python
>
> 安装：`conda install pytorch::pytorch torchvision torchaudio -c pytorch`
>
> 测试，进入python环境执行以下代码
>
> ```python
> >>> import torch
> >>> x=torch.rand(2,3)
> >>> x
> ```
>
> ## pycharm中安装pytorch虚拟环境
>
> 1. 创建一个项目，注意使用的python版本
>
> 2. settings->python interpreter ->Add interpreter ->Add local interpreter ->conda Environment ->Use existing environment 
>
> 3. 执行以下代码测试，注意需要魔法上网。调用对应的模型库来完成下面的操作
>
>    ```python
>    from transformers import BertTokenizer, GPT2LMHeadModel,TextGenerationPipeline
>    
>    tokenizer = BertTokenizer.from_pretrained("uer/gpt2-chinese-poem")
>    
>    model = GPT2LMHeadModel.from_pretrained("uer/gpt2-chinese-poem")
>    
>    text_generator = TextGenerationPipeline(model, tokenizer)
>    
>    result=text_generator("[CLS] 万叠春山积雨晴", max_length=50, do_sample=True)
>    
>    print (result)
>    
>    ```
>



# 实现数字体识别

