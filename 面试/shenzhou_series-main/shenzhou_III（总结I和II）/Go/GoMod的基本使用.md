# go mod简介

类似与maven的一个依赖管理工具,可以去网上下载项目所需的依赖信息,在项目中会生成一个go mod的文件来管理需要的依赖信息

go mod是go安装包自带的,只需要将其开启就可以来,需要将go升级到1.11以上


# 配置
配置环境变量,增加如下两行
```bash
export GO111MODULE=on
export GOPROXY=https://goproxy.cn,direct
```

# 使用

初始化项目
`go mod init 文件夹名称`,需要在项目目录下使用,会生成一个go.mod


# idea配置

配置在Preferences>Go>Go Modules,开启`Enable Go modules integration`

然后配置Enviroment

```
GOPROXY = https://goproxy.cn,direct
GOSUMDB = off
```
保存ok即可


