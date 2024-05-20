命令

> **显示当前系统上存在的所有 Conda 环境的信息**。当你运行这个命令时，**Conda 会列出所有已创建的 Conda 环境，并显示它们的名称及对应的路径**
>
> conda info --envs



> 用于创建一个名为 “pyt” 的新 Conda 环境
>
> conda create -n pyt



> 进入刚刚创建的虚拟环境
>
> conda activate pyt



> 退出一个激活的虚拟环境，就输入
>
> conda deactivate。



> 安装python
>
> conda install python==3.11.7



> 安装pytorch
>
> conda install pytorch::pytorch torchvision torchaudio -c pytorch