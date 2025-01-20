# 基于数据集创建微调模型

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20240813205328.png)

学习率：



![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20240813205416.png)



训练次数：![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20240813205428.png)





# 流程

第一步：针对现有的考试题库、考试参考书籍，生成问题和对应的答案的数据集（针对训练集-语文+训练集-英语生成output.jsonl）

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20240813210213.png)

第二步：针对生成的数据集（数据集和json格式的两个key-value数据）训练一个预训练模型



