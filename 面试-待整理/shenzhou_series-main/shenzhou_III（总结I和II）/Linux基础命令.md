# 防火墙

+ 查看防火墙状态 systemctl status firewalld.service
+ 查看防火墙打开的端口 firewall-cmd --zone=public --list-ports
+ 开启一个端口 firewall-cmd --zone=public --add-port=80/tcp --permanent
+ 重新载入 firewall-cmd --reload
+ 删除一个端口 firewall-cmd --zone= public --remove-port=80/tcp --permanent

# scp命令

```bash
scp 本地文件全路径 远程用户名@远程主机ip:远程文件保存路径

case:
scp docsify root@10.0.10.11:/root
将当前路径下的docsify文件复制到ip为10.0.10.11的用户为root的root目录下

```
scp后跟的参数

|参数|解释|
|--|--|
|`-r`|表示递归复制整个目录文件<br/>通常用于复制文件夹|
|`-P`|表示使用固定端口复制文件|




# 巴拉巴拉

git统计每个人的代码行数
```bash
git log --format='%aN' | sort -u | while read name; do echo -en "$name\t"; git log --author="$name" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }' -; done
```