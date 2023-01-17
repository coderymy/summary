compose是一个工具，定义或者运行多容器的docker引用程序

使用Compose，可以依赖于Yaml来配置应用服务。这样就可以使用一个命令来直接启动你的服务（应用）

# 安装

可以查看官网

[docker-compose的安装](docs.docker.com/compose/install)

# 基本步骤

1. 定义你的Dockerfile
2. 创建`docker-compose.yml`将你的文件放在这里进行启动
3. 运行`docker-compose.yml`

```yaml
version: '3'
services:
	服务名:
		xxx
		xxx
		xxx
	redis: 
		container_name: 容器名称
		image: 使用的镜像
		restart: 出现异常是否重启（always）
		ports: 端口映射
			- '6379:6379'
		command: 运行的语句（redis-server --appendonly yes --requirepase "123456" --protected-mode no），表示追加备份保存，
	webapp: 
		container_name: 
		restart: 
		build: ./（表示使用当前目录下找到Dockerfile，然后执行docker build）
		ports: 
		depends_on:
			- redis（这里表示依赖什么容器，这样好方便创建容器优先级）	
		links: 
			- redis:redisdb（容器名称：项目中的配制）
		
			
			
			
```



```
docker-compose up
即可启动compose中的定义
```

停止docker-compose创建的所有服务`docker-compose down`

`docker compose ps`列出这个文件夹创建的compose生成的容器