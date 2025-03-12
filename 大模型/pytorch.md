[官网](https://pytorch.org/)

[datawhale](https://datawhalechina.github.io/thorough-pytorch/%E7%AC%AC%E4%B8%80%E7%AB%A0/1.2%20PyTorch%E7%9A%84%E5%AE%89%E8%A3%85.html)



# 基础概念

## 张量

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20250311144036.png)

| 张量维度 | 代表含义                                         |
| -------- | ------------------------------------------------ |
| 0维张量  | 代表的是标量（数字）                             |
| 1维张量  | 代表的是向量                                     |
| 2维张量  | 代表的是矩阵                                     |
| 3维张量  | 时间序列数据 股价 文本数据 单张彩色图片(**RGB**) |

### 创建张量

- 创建tensor

  ```python
  import torch
  x = torch.rand(4, 3) 
  print(x)
  
  
  ---
  tensor([[0.7569, 0.4281, 0.4722],
          [0.9513, 0.5168, 0.1659],
          [0.4493, 0.2846, 0.4363],
          [0.5043, 0.9637, 0.1469]])
  ```

- 全0矩阵的构建

  ```python
  import torch
  x = torch.zeros(4, 3, dtype=torch.long)
  print(x)
  
  ---
  tensor([[0, 0, 0],
          [0, 0, 0],
          [0, 0, 0],
          [0, 0, 0]])
  ```

- `torch.tensor()`直接使用数据

  ```python
  import torch
  x = torch.tensor([5.5, 3]) 
  print(x)
  
  ---
  tensor([5.5000, 3.0000])
  ```

- 基于已经存在的 tensor，创建一个 tensor 

  ```python
  x = x.new_ones(4, 3, dtype=torch.double) 
  # 创建一个新的全1矩阵tensor，返回的tensor默认具有相同的torch.dtype和torch.device
  # 也可以像之前的写法 x = torch.ones(4, 3, dtype=torch.double)
  print(x)
  x = torch.randn_like(x, dtype=torch.float)
  # 重置数据类型
  print(x)
  # 结果会有一样的size
  # 获取它的维度信息
  print(x.size())
  print(x.shape)
  
  ---
  tensor([[1., 1., 1.],
          [1., 1., 1.],
          [1., 1., 1.],
          [1., 1., 1.]], dtype=torch.float64)
  tensor([[ 2.7311, -0.0720,  0.2497],
          [-2.3141,  0.0666, -0.5934],
          [ 1.5253,  1.0336,  1.3859],
          [ 1.3806, -0.6965, -1.2255]])
  torch.Size([4, 3])
  torch.Size([4, 3])
  ```

- 

  |                函数 | 功能                                              |
  | ------------------: | ------------------------------------------------- |
  |       Tensor(sizes) | 基础构造函数                                      |
  |        tensor(data) | 类似于np.array                                    |
  |         ones(sizes) | 全1                                               |
  |        zeros(sizes) | 全0                                               |
  |          eye(sizes) | 对角为1，其余为0                                  |
  |    arange(s,e,step) | 从s到e，步长为step                                |
  | linspace(s,e,steps) | 从s到e，均匀分成step份                            |
  |   rand/randn(sizes) | rand是[0,1)均匀分布；randn是服从N(0，1)的正态分布 |
  |    normal(mean,std) | 正态分布(均值为mean，标准差是std)                 |
  |         randperm(m) | 随机排列                                          |



### 操作张量



- 加法

  ```python
  import torch
  # 方式1
  y = torch.rand(4, 3) 
  print(x + y)
  
  # 方式2
  print(torch.add(x, y))
  
  # 方式3 in-place，原值修改
  y.add_(x) 
  print(y)
  
  
  ---
  tensor([[ 2.8977,  0.6581,  0.5856],
          [-1.3604,  0.1656, -0.0823],
          [ 2.1387,  1.7959,  1.5275],
          [ 2.2427, -0.3100, -0.4826]])
  tensor([[ 2.8977,  0.6581,  0.5856],
          [-1.3604,  0.1656, -0.0823],
          [ 2.1387,  1.7959,  1.5275],
          [ 2.2427, -0.3100, -0.4826]])
  tensor([[ 2.8977,  0.6581,  0.5856],
          [-1.3604,  0.1656, -0.0823],
          [ 2.1387,  1.7959,  1.5275],
          [ 2.2427, -0.3100, -0.4826]])
  ```

- 索引操作

  ```python
  import torch
  x = torch.rand(4,3)
  # 取第二列
  print(x[:, 1]) 
  
  ---
  tensor([-0.0720,  0.0666,  1.0336, -0.6965])
  
  
  
  y = x[0,:]
  y += 1
  print(y)
  print(x[0, :]) # 源tensor也被改了了
  
  ---
  tensor([3.7311, 0.9280, 1.2497])
  tensor([3.7311, 0.9280, 1.2497])
  ```

- 维度变换

  ```python
  torch.view()和torch.reshape()
  
  
  x = torch.randn(4, 4)
  y = x.view(16)
  z = x.view(-1, 8) # -1是指这一维的维数由其他维度决定
  print(x.size(), y.size(), z.size())
  
  ---
  torch.Size([4, 4]) torch.Size([16]) torch.Size([2, 8])
  
  注: torch.view() 返回的新tensor与源tensor共享内存(其实是同一个tensor)，更改其中的一个，另外一个也会跟着改变。(顾名思义，view()仅仅是改变了对这个张量的观察角度)
  ```

PyTorch中的 Tensor 支持超过一百种操作，包括转置、索引、切片、数学运算、线性代数、随机数等等，具体使用方法可参考[官方文档](https://pytorch.org/docs/stable/tensors.html)。



### 广播机制



```python
x = torch.arange(1, 3).view(1, 2)
print(x)
y = torch.arange(1, 4).view(3, 1)
print(y)
print(x + y)

---
tensor([[1, 2]])
tensor([[1],
        [2],
        [3]])
tensor([[2, 3],
        [3, 4],
        [4, 5]])
```

由于x和y分别是1行2列和3行1列的矩阵，如果要计算x+y，那么x中第一行的2个元素被广播 (复制)到了第二行和第三行，⽽y中第⼀列的3个元素被广播(复制)到了第二列。如此，就可以对2个3行2列的矩阵按元素相加。





## 自动求导



## 并行计算

原因：

- 分摊内存
- 计算更快



# pyTorch主要模块

1. 基础配置（没批大小，读取线程数量，更新步长，训练轮次），配置硬件参数（GPU 使用情况）
2. 数据读入：编写数据转换方法，加载数据到 dataset，加载数据到 dataloader。输出查看样式

## 基本配置

> 导入基本的 packages

```python
import os 
import numpy as np 
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader
import torch.optim as optimizer
```



> 配置训练过程的超参数

```python
# 2. 配置每次支持的批大小（读入训练的数据的量）
batch_size=256
# 3. 多少个线程进行数据读入
num_workers=4
# 4. 参数更新的步长
lr = 1e-4
# 5. 训练轮次
epochs=20
```

> 配置的硬件参数（GPU 设置）

```python
# 检查是否有 GPU，如果有返回 True，否则返回 False
print(torch.cuda.is_available())
# 配置 GPU，两个方式，
# 方案一：使用os.environ
os.environ['CUDA_VISIBLE_DEVICES'] = '0,1' # 指明调用的GPU为0,1号 物理上就是第一块和第二块
# 方案二：使用 device 后续对要使用 GPU 的变量用.to(device)即可
device = torch.device("cuda:1" if torch.cuda.is_available() else "cpu") # 指明调用的GPU为1号
```

## 数据读入

PyTorch 数据读入是通过`Dataset + DataLoader`的方式完成的，Dataset 定义好数据的格式和数据变换形式，DataLoader 用 iterative 的方式不断读入批次数据。

```
插件包：torchvision
官方 pyTorch 的生态包
```

- 如何读取格式不定的本地数据：DataSet

- 如何将数据加载以供模型输入：DataLoader

```python
# 首先设置数据变换
image_size = 28
data_transform = transforms.Compose([
    # 这一步取决于后续的数据读取方式，如果使用内置数据集则不需要
    # transforms.ToPILImage(),
    transforms.Resize(image_size),
    transforms.ToTensor()
])


```

```python
   train_loader = torch.utils.data.DataLoader(train_data, batch_size=batch_size, num_workers=num_workers, shuffle=True, drop_last=True)
    val_loader = torch.utils.data.DataLoader(test_data, batch_size=batch_size, num_workers=num_workers, shuffle=False)

    images, labels = next(iter(train_loader))
    print(images.shape)
    plt.imshow(images[0].permute(1, 2, 0).cpu().numpy())
    plt.show()
```

## 模型构建

### 构建模型

卷积层（图像特征提取）：把一张图片变成01 的数据矩阵。需要设置通道数、卷积核数目、卷积核大小

池化层：将很大的图像矩阵压缩变成可以计算的图像矩阵，便于计算。需要设置池化方法、池化核大小、步长

全连接层：将图像矩阵展开层一段数据

这一段数据就是这个图片的唯一标识了，计算机就认识了这张图片

### 训练模型

实际上：将训练数据输入模型，计算损伤，调整参数。这样重复进行多个周期，让模型很好的学到数据特征

训练模型就是将大量已经手动标记的数据告诉计算机，让计算机不断的学习/复习，最终让考试成绩越来越好的过程

## 激活函数

神经网络中决定是否将信息传递给其他部分

打开/关闭

ReLU，如果输入的信息是正的就打开开关，传递原始信息。如果输入的信息是负的就关闭开关

## 损失函数

用于衡量模型预测的准确性

例：交叉熵损失

## 优化器

调整模型的参数

例：随机梯度下降

## 训练与评估

找测试数据进行测试，判断准确率的高低
