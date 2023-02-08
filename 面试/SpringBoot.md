# 问题

## **为什么要用SpringBoot**

1. 简化各个组件的配置
2. 内置tomcat容器，开发者开发的时候支持一键启动。

## **spring boot 有哪些优点？**

1. 独立运行，内嵌servlet、tomcat，不需要打war包放到容器里，直接打jar包一键运行
2. 简化配置
3. springboot-starter管理包依赖，防止各种依赖版本冲突
4. 支持服务监控等

## **核心注解**

@SpringBootApplication，包含

+ `@SpringBootConfiguration()`:代表当前是一个配置类
+ `@EnableAutoConfiguration()`: 启动自动配置
+  `@ComponentScan()`：指定扫描哪些 Spring 注解

## SpringBoot的自动装配

是什么：

springboot的**自动装配**实际上就是为了从**spring.factories**文件中获取到对应的需要进行自动装配的类，并生成相应的Bean对象，然后将它们交给spring容器来帮我们进行管理

原理：

1. SpringBoot启动的时候加载主配置类，开启了自动配置功能@EnableAutoConfiguration。
2. 通过@ComponentScan注解扫描需要加载到ioc中的配置类。然后再扫描@Import类将第三方jar中的配置类导入进来。
3. 导入第三方jar配置的时候有些变量会指向性的去配置文件中找对应的属性值。就需要开发者手动写入。
2. 查看@EnableAutoConfiguration，其作用是利用AutoConfigurationImportSelector给容器中导入一些组件。
3. 查看AutoConfigurationImportSelector，其中public String[] selectImports(AnnotationMetadata annotationMetadata)方法内 最终调用getCandidateConfigurations()方法
4. 查看 getCandidateConfigurations(AnnotationMetadata metadata, AnnotationAttributes attributes)，获取候选的配置，这个是扫描所有jar包类路径下"META-INF/spring.factories"
5. 然后把扫描到的这些文件包装成Properties对象。
6. 从properties中获取到EnableAutoConfiguration.class类名对应的值，然后把他们添加在容器中。

## **SpringBoot启动流程**

第一步：创建IOC容器

第二步：加载源配置类，也就是被@SpringBootApplication修饰的类

第三步：加载所有的配置类，被@Configuration修饰的类

第四步：实例化所有的bean

第五步：启动web服务器（内嵌的tomcat）

![image-20221220180317384](C:\Users\coderymy\AppData\Roaming\Typora\typora-user-images\image-20221220180317384.png)

## **SpringBoot启动时都做了什么?**

启动主类之后，生成IOC容器对象之后。逐层扫描注解，将对应的配置类，实例Bean等都通过对应的配置信息创建出来，放到IOC容器中。

## **SpringBoot 中的starter到底是什么 ?**

启动类，帮助实现配置和业务处理。在项目启动的时候就可以直接将对应的对象装配在ioc容器中就可以直接使用了

如何做？

第一步：创建base_course空的maven项目，引入spring-boot-parents。

第二步：编写业务代码，同时创建properties类，使用`@ConfigurationProperties`注解从配置类中增加属性值信息

第三步：创建基于@Configuration配置类，去在别的项目引入的时候进行ioc注入

第三步：在resources下创建META-INF/spring.factories。其中写入需要启动的时候注入到ioc的配置类的全路径