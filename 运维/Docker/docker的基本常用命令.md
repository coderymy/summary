# 镜像

**获取镜像**

`docker pull [选项] [Docker Registry 地址[:端口号]/]仓库名[:标签]`

例如：`docker pull ubuntu:18.04`

**查看所有镜像**
`docker image ls`


**删除镜像**
`docker image rm +镜像名称`



# 容器
**启动容器**
`docker run IMAGE [COMMAND] [ARG]`

例：`docker run ubuntu echo 'hello world'`

**启动交互式容器**
`docker run -i -t IMAGE /bin/bash`

-i，表示告诉守护进程，为容器始终打开标准输入

-t，为创建的容器分配一个--tty终端，这样新创建的容器才能提供一个交互的shell

--name，给启动的容器命名

使用`Ctrl+P/Q`来退出`bash`

使用`exit`退出交互式容器，会直接关闭容器

**进入容器**
`docker attach +id/name`

退出守护式容器的bash之后，可以使用attach重新进入

**查看容器列表**
`docker ps [-a] [-l]`
-a 表示列出所有的容器

-l 表示列出刚刚创建的容器

查看刚刚建立的容器

**查看容器详情**
`docker inspect + 容器的id/name`

**重新启动已关闭的容器**
`docker start [-i] 容器名`

**在容器中创建新的进程**
`docker exec [-d] [-i] [-t] 容器名`
例如开启bash交互命令

**关闭容器**
`docker stop + 容器的id/name`

**强制关闭容器**
`docker kill 容器名`

**删除容器**
`docker rm id/name`


# 管理

**查看容器日志**
`docker logs [-f] [-t] [-tail] 容器名`

**构建容器**
`docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]`

| 参数 | 全称         | 简介                                  |
| :--- | :----------- | :------------------------------------ |
| -a   | --author     | 也就是给出镜像的作者                  |
| -m   | --message    | 备注信息                              |
| -p   | --pause=true | 指示不暂停正在执行的容器<br/>进行创建 |

```
docker commit -a "作者信息" -m "镜像的描述" 容器名字 想要创建镜像的名字
如：
docker commit -a "coderymy" -m "empty" commit_test coderymy/commit_test1
```

然后就可以使用这个镜像来创建容器

```
docker run -d --name empty_ubuntu coderymy/commit_test1 
```

**运行dockerFile文件**

`docker build -t="xxx/xxxxDockerfile .`

**使用docker-compose**

下载并加入可执行文件中`sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose`

赋权`sudo chmod +x /usr/local/bin/docker-compose`

在目录中运行：
`docker-compose up`以来启动程序。后台运行：`docker-compose up -d`

`docker-compose down`停止启动的服务

`docker compose ps`列出文件夹中会启动的容器




