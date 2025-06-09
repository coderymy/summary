# 命令

- `conda env list`

  查看环境列表

- `conda create -n ENV_NAME python==PYTTHON_VERSION`

  创建环境并指定 python 版本

- `conda install PACKAGE_NAME`

  安装包

- `conda remove PACKAGE_NAME`

  删除包

- `conda remove -n ENV_NAME --all`

  移除某个环境

- `conda activate ENV_NAME`

  激活某个环境

- `conda deactivate`

  退出当前环境





# 换源

永久换源

```bash
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge
conda config --set show_channel_urls yes
```

单次换源下载

```bash
conda install -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main numpy
```

恢复默认源

```bash
conda config --remove-key channels
```





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
