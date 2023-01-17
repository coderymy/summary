# 1. ansbile概念

是什么？
<br>
ansible自我理解就是一种可以远程操作大量主机、服务器的一个工具，是一种自动化运维工具
<br>
基于python开发，所以部署非常简单，只要求有python环境即可
<br>

特点：
1. 部署简单，主控端只需要python环境，被控端只需要一个权限足够大的用户即可
2. 可以批量控制服务器
3. 支持API及自定义模块，可以通过python进行扩展开发
4. 拥有自己的后台管理工具---AWX平台

ansible整体执行流程：
```
1. 加载自己的配置文件`/etc/ansible.ansible.cfg`
2. 加载模块信息，如默认模块command
3. 按照输入的模块操作及参数设置，生成对应需要执行的.py文件，并将该文件传输至需要远程批量操作的主机的`$HOME/.ansible/tmp/ansible-tmp-xxx/xxx.py`文件中
4. 执行.py文件
5. 执行结果返回
6. 删除主控端和被控端的临时.py文件
```

# 2. ansible部署及配置

## 2.1 安装
### 2.1.1 git安装
```bash
# 安装git
yum -y install git
git clone git://github.com/ansible/ansible.git --recursive
cd ./ansible
source ./hacking/env-setup
```
### 2.1.2 pip安装

```bash
yum install python-pip python-devel
yum install gcc glibc-devel zibl-devel  rpm-bulid openssl-devel
pip install  --upgrade pip
pip install ansible --upgrade
```
### 2.1.3 EPEL源的rpm包安装===推荐
```bash
# 安装EPEL源
yum -y install epel-release
# 查看是否安装成功
cd /etc/yum.repos.d/
# 重新创建 本地仓库缓存
yum clean all && yum makecache
```

```bash
# 安装
yum install ansible
# 编译
yum -y install python-jinja2 PyYAML python-paramiko python-babel python-crypto
tar xf ansible-1.5.4.tar.gz
cd ansible-1.5.4
python setup.py build
python setup.py install
mkdir /etc/ansible
cp -r examples/* /etc/ansible

```

确认安装成功
```bash
ansible --version
# 返回ansible版本号
```

## 2.2 主机配置
最简单的配置，直接vi操作，在上面新增如下方式
```bash
[webser]
192.168.56.102
192.168.56.103
```

## 2.3 配置文件详解



## 2.4 JK认证

```bash
# 生成秘钥对
ssh-keygen

# copy公钥到被管理的主机上
ssh-copy-id -i .ssh/id_rsa.pub root@192.168.56.102
# 接着yes并输入密码即可
# 如果以后的管理中需要使用sudo权限，远程服务器的用户rick需要配置visudo为NOPASSWD
# root执行sudo时不需要输入密码(eudoers文件中有配置root ALL=(ALL) ALL这样一条规则)
# 如果需要修改，则在远程服务器上使用visudo命令，在其中增加如下rick ALL=(ALL) NOPASSWD: ALL，需要注意大小写
# 不知道为什么，这个地方忽然会话连接切换成对应的被管理主机上了
```

测试是否成功`ansible all -m ping`
<br>
返回pong即表示成功


# 3. ansible的临时命令及常用模块分析
执行ansible命令之后，返回的颜色代表的含义<br>
绿色：执行成功并且不需要做改变的操作<br>
黄色：执行成功并且对目标主机做变更<br>
红色：执行失败

## 3.1 command 模块
ansiblede 默认模块
`ansible webserve -m command -a 'xxxxx'`

-a后面跟对应的linux命令，虽然很强大，但是对于一些复杂的linux命令不支持，如管道符、导出符等

## 3.2 shell模块

类似command模块，都是操作Linux命令的模块，比command模块强大，支持很多linux命令

`ansible webserve -m shell -a 'echo HOSTNAME'`

## 3.3 script模块

可以用来执行远程主机上的bash脚本，注意是<font color='red'>远程主机</font>

`ansible webserve -m script -a /data/xxx.sh`

## 3.4 copy模块

从主控端复制文件到被控端

`ansible webserve -m copy -a "src=源路径 dest=目标路径 "`

目标路径后面还可以跟一些参数，比如允许访问的权限，管理的用户组等

## 3.5 fetch模块

从远程主机拉取文件到ansible端

`ansible webserve -m fetch -a 'src=远程主机路径 dest=ansible路径'`

## 3.6 file模块

对文件属性进行设置

`ansible webserve -m file -a 'path=路径/文件名 设置参数'`

后面可以跟一些设置的参数信息

## 3.7 unarchive模块

解包解压缩

+ 将ansible主机上的压缩包传到远程主机之后解压缩到特定目录，设置copy=yes
+ 将远程主机某个压缩文件解压缩到指定路径，设置copy=no

常见参数
+ copy：默认为yes，当copy=yes，拷贝的文件是从ansible主机复制到远程主机上，如果设置为copy=no，会在远程主机上寻找src源文件
+ remote_src：和copy功能一样且互斥，yes表示在远程主机，不在ansible主机，no表示文件在ansible主机上
+ src：源路径，可以是ansible主机上的路径，也可以是远程主机上的路径，如果是远程主机上的路径，则需要设置copy=no
+ dest：远程主机上的目标路径
+ mode：设置解压缩后的文件权限

`ansible webserve -m unarchive -a 'src=文件路径 dest=解压缩路径' `



## 3.8 archive模块

打包压缩

`ansible webserve -m archive -a 'path=需要打包的文件夹 dest=指定压缩文件存放路径及压缩文件名 '`

后面可以跟其他参数

## 3.9 hostname模块

管理主机名

`ansible webserve -m hostname -a "name=主机名"`

## 3.10 cron模块

设置定时执行的任务

支持时间：minute，hour，day，month，weekday

`ansible websrvs   -m cron -a "minute=*/5 job='/usr/sbin/ntpdate 172.20.0.1 &>/dev/null' name=Synctime"`

## 3.11 yum模块

管理软件包，如下载等，注意：只支持RHEL，CentOs，fedora，不支持ubuntu等其他版本（使用的其他下载源）

`ansible webserve -m yum -a 'name=httpd state=present'`

state参数，present表示安装，absent表示删除

## 3.12 service模块

管理服务，比如重启，关闭，启动等

`ansible webserve -m service -a 'name=httpd state=started enabled=yes'`

注意后面的参数信息，name表示服务名，state表示操作的状态

## 3.13 user模块

管理用户信息

`ansible webserve -m user -a 'name=user1 comment="first user" uid=2048 home=/app/user1 group=root`

注意后面的参数信息name表示管理的用户名，comment表示描述，uid表示用户的唯一标识信息，home标识用户的根目录信息，group标识用户归属于哪个组

## 3.14 group模块

管理组信息

`ansible webserve -m group -a 'name=nginx gid=88 system=yes'`

name表示组名，git标识组，system

## 3.15 lineinfile模块

这个，，，，看不懂啊

## 3.16 replace模块

这个，也看不懂啊

## 3.17 setup模块
获取主机信息，如获取某某软件的版本信息等

`ansible webserve -m setup -a "filter=ansible_hostname"`


# 4. ansible操作playBook

Hosts：运行执行任务（task）的目标主机
remote_user：在远程主机上执行任务的用户
tasks：任务列表
handlers：任务，与tasks不同的是只有在接受到通知时才会被触发
templates：使用模板语言的文本文件，使用jinja2语法。
variables：变量，变量替换{{ variable_name }}

模板
```yml
---
- hosts: webserve
  remote_user: root
  
  tashs:
   - name: 该任务的名字
     ping: 这个ping可以是任意下面执行的模块名
     remote_user: 其中操作的用户信息
     sudo: 是否切换用户
     xxxxxxxxx
```

案例
```yml
---
- hosts: websrvs
  remote_user: root
  tasks:
    - name: "安装Apache"
      yum: name=httpd
    - name: "复制配置文件"
      copy: src=/tmp/httpd.conf dest=/etc/httpd/conf/
    - name: "复制配置文件"
      copy: src=/tmp/vhosts.conf dest=/etc/httpd/conf.d/
    - name: "启动Apache，并设置开机启动"
      service: name=httpd state=started enabled=yes
```

[运维派企业案例信息](http://www.yunweipai.com/34658.html)


# 5. ansible的roles（批量playBook的集合）




# 附录
## 1. 命令
```bash
# 显示模块的帮助信息
ansible-doc [option] [module...]
ansible-doc ping

-s 可以显示简洁信息
ansible-doc -s ping
```



## 2. linux命令

```bash
# 生成秘钥对
ssh-keygen
# 然后一直回车

# 复制文件到另一个主机上
#在本机135主机向137传输：
scp 本机文件路径 另一台账号@192.168.60.137:另一台储存路径
 
#在137主机，从135拉取：
scp 远程用户名@192.168.60.153:文件的绝对路径 本地Linux系统路径
```