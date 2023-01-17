# 基础服务安装

+ 安装jdk，并配置环境变量
+ 安装maven，并配置环境变量
+ 安装git


# 下载nacos-server

注意理解nacos-server和nacos-client并不是一个东西哦

## 使用源码安装

+ 使用git下载源码信息
```bash
git clone https://github.com/alibaba/nacos.git
cd nacos/
mvn -Prelease-nacos -Dmaven.test.skip=true clean install -U  
ls -al distribution/target/

// change the $version to your actual path
cd distribution/target/nacos-server-$version/nacos/bin
```

+ 自己去github下载或者使用链接直接下载

![源码下载](https://raw.githubusercontent.com/coderymy/oss/main/uPic/MNO7ok.png)

然后进行编译`mvn -Prelease-nacos -Dmaven.test.skip=true clean install -U  
ls -al distribution/target/`

其实是推荐这种方式的，因为为后期对整个项目的理解上会有帮助，可以随时查看源码。但是源码的这个编译过程需要下载很多的jar文件，还有一些基于本机的配置信息，所以其实并不能每次都达到自己想要的效果。所以如果搞不定就进行下面的使用已经生成好的server压缩包进行安装


## 使用压缩包安装

![压缩包下载](https://raw.githubusercontent.com/coderymy/oss/main/uPic/svXLUh.png)

下载之后直接解压即可使用

# 使用及有效性测试

**启动**

> Linux/Unix/Mac
启动命令(standalone代表着单机模式运行，非集群模式):
> sh startup.sh -m standalone
>
> 如果您使用的是ubuntu系统，或者运行脚本报错提示[[符号找不到，可尝试如下运行：
> bash startup.sh -m standalone
>
> Windows
> 启动命令(standalone代表着单机模式运行，非集群模式):
>
> startup.cmd -m standalone
> ——来自官网
> 查看启动日志tail ../logs/start.out

**测试验证**

依次执行官网提供的测试例子

如果出现`curl: (7) Failed to connect to 127.0.0.1 port 8848: Connection refused`可以试试将`http://127.0.0.1`换成`localhost`

> **服务注册**:
> curl -X POST 'http://127.0.0.1:8848/nacos/v1/ns/instance?serviceName=nacos.naming.serviceName&ip=20.18.7.10&port=8080'<br/>
> —— ok

> **服务发现**:
> curl -X GET 'http://127.0.0.1:8848/nacos/v1/ns/instance/list?serviceName=nacos.naming.serviceName'<br/>
> —— {"name":"DEFAULT_GROUP@@nacos.naming.serviceName","groupName":"DEFAULT_GROUP","clusters":"","cacheMillis":10000,"hosts":[{"instanceId":"20.18.7.10#8080#DEFAULT#DEFAULT_GROUP@@nacos.naming.serviceName","ip":"20.18.7.10","port":8080,"weight":1.0,"healthy":true,"enabled":true,"ephemeral":true,"clusterName":"DEFAULT","serviceName":"DEFAULT_GROUP@@nacos.naming.serviceName","metadata":{},"instanceHeartBeatInterval":5000,"instanceIdGenerator":"simple","instanceHeartBeatTimeOut":15000,"ipDeleteTimeout":30000}],"lastRefTime":1635738389314,"checksum":"","allIPs":false,"reachProtectionThreshold":false,"valid":true}

> **发布配置**:
> curl -X POST "http://127.0.0.1:8848/nacos/v1/cs/configs?dataId=nacos.cfg.dataId&group=test&content=HelloWorld"<br/>
> —— true

> **获取配置**:
> curl -X GET "http://127.0.0.1:8848/nacos/v1/cs/configs?dataId=nacos.cfg.dataId&group=test"<br/>
> —— HelloWorld

**关闭：**
> Linux/Unix/Mac
> sh shutdown.sh
>
> Windows
> shutdown.cmd
>
> 或者双击shutdown.cmd运行文件。


开启防火墙端口

```bash
firewall-cmd --zone=public --add-port=8848/tcp --permanent

firewall-cmd --reload
```
外部访问，浏览器中输入：`http://yourIp:8848/nacos/v1/ns/instance/list?serviceName=nacos.naming.serviceName`


访问`yourIp:8848/nacos`即可看到控制台信息。账号和密码都是`nacos`
![nacos控制台](https://raw.githubusercontent.com/coderymy/oss/main/uPic/jfxwun.png)

可以切换中文阅览

