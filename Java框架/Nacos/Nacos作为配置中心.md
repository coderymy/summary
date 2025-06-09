# 概念

首先理解Nacos到底是干什么的？
+ 配置中心
+ 服务注册中心

## 配置中心
所谓**配置中心**：一般SpringBoot项目都使用在resources下创建类似`application.yml`之类的配置文件来管理整个项目的一些配置信息
+ mysql、redis、es、mq等地址账号密码
+ 业务场景信息
+ 主站ip前缀
+ 。。。。。。

那么就会有人想了，为啥要将这些本来是动态配置的信息写死在代码中呢。而且如果有人登陆上了服务器，获取了Jar文件，是不是就可以有了各种数据库的链接信息了呢。所以**配置中心**应运而生了。

通过一个配置平台来管理注册中心下所有的服务的配置文件信息，也就是说以后服务不需要去resource中获取相应需要的配置信息了，直接去这个服务中获取即可

优点：
+ 灵活配置
+ 统一管理
+ 权限控制
+ ......



# Nacos-client使用配置中心
1. 创建一个SpringBoot项目
2. 导入相关的依赖
3. 增加基本的配置信息
4. 修改启动类
5. 新增测试类

## 初始化项目

基于SpringBoot的所需依赖及注意事项
```xml
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <!-- https://mvnrepository.com/artifact/com.alibaba.cloud/spring-cloud-starter-alibaba-nacos-config -->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
            <version>2.2.1.RELEASE</version>
        </dependency>
        <!-- https://mvnrepository.com/artifact/com.alibaba.cloud/spring-cloud-starter-alibaba-nacos-discovery -->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
            <version>2.2.1.RELEASE</version>
        </dependency>
        <!-- https://mvnrepository.com/artifact/org.springframework.boot/spring-boot-starter-actuator -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
            <version>2.2.1.RELEASE</version>
        </dependency>
    </dependencies>

<!--
注意：这里并没有列出SpringBoot-parent的版本信息，需要注意的是SpringBoot与这个Nacos的版本需要保持一致
（其实一般来说只要使用SpringBoot相关的包都尽量保持一致好了，因为很多相关的Service的注入在多个Jar文件都有注入，保持一致防止触发多处实例化Bean的问题）
-->
```

## 基础配置信息

bootstrap.yml,在存在该文件时，会优先加载改文件数据，bootstrap的意思是“引导程序”
```yaml
spring:
  application:
    name: nacos-config-client
  profiles:
    active: dev
  cloud:
    nacos:
      discovery:
        # Nacos服务注册中心地址
        server-addr: http://yourIp:8848
      config:
        # 指定Nacos配置中心的地址
        server-addr: http://yourIp:8848
        file-extension: yaml # 指定yaml格式的配置 默认properties
server:
  port: 8080
```

## 基础启动类

```java
@SpringBootApplication
@EnableDiscoveryClient
public class NacosClientApplication {

    public static void main(String[] args) {
        SpringApplication.run(NacosClientApplication.class, args);
    }

}

```

## 基础测试验证类


```java
@RestController
//@RefreshScope用于动态刷新
@RefreshScope
public class ConfigClientController {
    @Value("${config.info}")
    private String configInfo;

    @GetMapping("/config/info")
    public String getConfigInfo() {
        return configInfo;
    }
}
```

注意此时yml配置文件中并不能获取到${config.info}。所以为了启动不报错，需要提前在配置中心的页面中进行数据配置

![配置中心进行配置1](https://raw.githubusercontent.com/coderymy/oss/main/uPic/TOGxdL.png)
![配置中心进行配置2](https://raw.githubusercontent.com/coderymy/oss/main/uPic/nXJufi.png)。

## 启动服务
![](https://raw.githubusercontent.com/coderymy/oss/main/uPic/TMgnMT.png)

在浏览器中调用`localhost:8080/config/info`接口，获取到配置中心配置的数据即表示无误





## dataId

dataId=${prefix}-${spring.profile.active}.${file-extension}

其中profix默认为${spring.application.name}
![](https://raw.githubusercontent.com/coderymy/oss/main/uPic/SYLGaT.png)

file-extension表示配置的类型，默认为properties。与页面上相呼应!![file-extension配置项](https://raw.githubusercontent.com/coderymy/oss/main/uPic/lZNIIQ.png)

如果没有指定spring.profile.active，那么dataId就变成了${profix}.${file-extension}

1. 启动时会发现启动日志中会打出多个，
    + ${prefix}
    + ${prefix}-${spring.profile.active}
    + ${prefix}-${spring.profile.active}.${file-extension}。说明其实是可以匹配配置中心中配置的多条配置名称
2. 匹配优先级是：3>2>1，精确匹配







> 学习自：
> [大佬1号](https://sutianxin.top/posts/87309235.html)
> [大佬2号](https://blog.csdn.net/qq_32352777/article/details/86560333)<br/>
> 遇到的问题：
> + [Error creating bean with name ‘configurationPropertiesBeans‘ defined in class path resource](https://blog.csdn.net/zlbdmm/article/details/111202052)
> + 「nested exception is java.lang.IllegalArgumentException: Could not resolve placeholder 'config.info' in value "${config.info}"」配置中心指定的配置与测试中注入的配置信息不一致