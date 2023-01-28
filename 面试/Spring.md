# 问题

1、Spring的**事务机制**

> 1、基于Spring的AOP机制
>
> 2、当方法上有`@Transaction`注解，就生成这个Bean的代理，并创建数据库的链接
>
> 3、在调用该方法之前，先开启事务且关闭自动提交。
>
> 4、执行该方法，成功则提交，遇到异常抛出的时候检查是否是该事务捕获的异常，如果是就进行rollback
>
> spring的事务隔离级别也就是数据库的隔离级别

3、spring使用到了哪些**设计模式**

> 工厂模式：BeanFactory。根据传入一个唯一的标识来获得bean对象。比如我想获取A的bean，就传入a即可
>
> 适配器模式：各种Adapter接口。AdvisorAdapter，MethodBeforAdviceAdapter
>
> 代理模式：AOP
>
> 观察者模式：事件监听机制。通过java.util.EventListener来描述事件监听器

4、如何使用AOP

> 基于`@Aspect`注解的类，指定切点即可在切点插入具体的方法
>
> 常用在日志打印。所有的controller进来之前都打印出一些相关信息

5、如何**理解IOC**

>将对象的创建交给容器去处理，只需要关注对象的使用即可。然后通过DI，将对象注入到业务代码中即可使用。
>
>Spring底层是使用反射的机制来创建对象
>
>使用IOC的目的就是解耦合。
>
>为什么叫做控制反转：就是因为本来创建对象是开发者的事情，但是现在框架帮给创建了，所以就不需要开发者进行，所以就反转了

6、描述一下**SpringBean的生命周期**

> 四个阶段：实例化、属性填充、初始化、销毁
>
> 1. 实例化：当客户向容器请求一个尚未实例化的Bean（或者实例化一个Bean需要另外一个Bean的时候）。容器调用doCreateBean方法，通过反射的方式创建这个Bean。
> 2. 属性填充：也就是对这个Bean所需要的属性或其他Bean进行创建填充进去
> 3. 初始化：
>    1. 执行该Bean的各种后处理器。包括各种Aware方法、PostProcessor及自定义初始化方法
> 4. 初始化完成之后就可以使用这个Bean，当Bean不在受到依赖的时候就可以销毁。销毁前也需要执行一些后处理器

7、**Spring Bean 的作用域之间有什么区别？**

> **Spring器中的bean可以分为5个范围：**
>
> 1. singleton：这种bean范围是默认的，每个容器中只有一个bean的实例，单例模式；
> 2. prototype：每次都创建一个
> 3. request：在请求bean范围内为每一个来自客户端的网络请求创建一个实例，在请求完毕后，bean会失效并被垃圾回收器回收；
> 4. session：为每个session创建一个实例，session过期后，bean会随之消失；
> 5. global-session：全局Session一个。

8、**BeanFactory和ApplicationContext有什么区别？**

> ​	BeanFactory和ApplicationContext是Spring的两大核心接口，**都可以当做Spring的容器**。
>
> 1. BeanFactory是Spring里面最底层的接口，是IoC的核心，定义了IoC的基本功能，包含了各种Bean的定义、加载、实例化，依赖注入和生命周期管理。**ApplicationContext接口作为BeanFactory的子类**，除了提供BeanFactory所具有的功能外，还提供了更完整的框架功能：
>
> - 继承MessageSource，因此支持国际化。
> - 资源文件访问，如URL和文件（ResourceLoader）。
> - 载入多个（有继承关系）上下文（即同时加载多个配置文件） ，使得每一个上下文都专注于一个特定的层次，比如应用的web层。
> - 提供在监听器中注册bean的事件。
>
> 创建Bean的实际不同：BeanFactory使用延时加载创建Bean，用到的时候再创建。ApplicationContext是在容器启动的时候一次性创建所有的Bean，所以启动较慢。
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230128143839.png)

9、spring如何解决循环依赖

Spring在单例模式下的setter方法依赖注入引起的循环依赖问题，主要是通过**二级缓存和三级缓存**来解决的，其中三级缓存是主要功臣。解决的核心原理就是：**在对象实例化之后，依赖注入之前，Spring提前暴露的Bean实例的引用在第三级缓存中进行存储。**

10、事务的传播机制

本质就是处理多个事务的情况，如何进行事务的创建和加入

spring事务的传播机制说的是，当多个事务同时存在的时候，spring如何处理这些事务的行为。事务传播机制实际上是使用简单的ThreadLocal实现的，所以，如果调用的方法是在新线程调用的，事务传播实际上是会失效的。

>  ① PROPAGATION_REQUIRED：（默认传播行为）如果当前没有事务，就创建一个新事务；如果当前存在事务，就加入该事务。
>  ② PROPAGATION_REQUIRES_NEW：无论当前存不存在事务，都创建新事务进行执行。
>  ③ PROPAGATION_SUPPORTS：如果当前存在事务，就加入该事务；如果当前不存在事务，就以非事务执行。‘
>  ④ PROPAGATION_NOT_SUPPORTED：以非事务方式执行操作，如果当前存在事务，就把当前事务挂起。
>  ⑤ PROPAGATION_NESTED：如果当前存在事务，则在嵌套事务内执行；如果当前没有事务，则按REQUIRED属性执行。
>  ⑥ PROPAGATION_MANDATORY：如果当前存在事务，就加入该事务；如果当前不存在事务，就抛出异常。
>  ⑦ PROPAGATION_NEVER：以非事务方式执行，如果当前存在事务，则抛出异常。

11、Spring事务失效的几种原因

> 1、方法没有被public修饰
>
> 2、类不是被IOC管理的
>
> 3、异常捕捉失败
>
> 4、没有配置事务管理器
>
> 5、mysql不支持事务

12、代理模式

> **什么叫做代理模式**
>
> 使用代理类来实现代理对象。“为了防止直接使用对象带来复杂，并且可以增强业务（比如说**代理海购**，直接海购很麻烦，所以需要代理来中间做一些事情）”
>
> ![](C:\Users\coderymy\AppData\Roaming\Typora\typora-user-images\image-20230101153349225.png)
>
> 
>
> ```java
> Linux linux = (Linux) Proxy.newProxyInstance(jdkProxy.getClass().getClassLoader(), serverLinux.getClass().getInterfaces(), jdkProxy);
> ```
>
> 这样在实现代理对象的时候，可以将代理类的业务逻辑插入进去
>
> **动态代理和静态代理的区别**
>
> 动态代理，使用jdk内置的或者cglib来实现，不需要自己实现代理类，只需要按照提供的接口方法实现即可。相较于静态代理的代理对象，每次都动态的调配代理对象。
>
> 静态代理，就是基础的**代理模式**的代理方法，实现之后，使用代理类实现代理对象即可
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230128155301.png)
>
> **动态代理**
>
> 1. **jdk**使用Java内部的反射机制实现
> 2. **cglib**使用asm来加载并操作字节码生成子类实现
>
> **jdk代理和cglib代理**
>
> 1、实现机制不同：jdk代理使用反射机制实现；cglib在类加载的时候操作字节码生成子类来实现
>
> 2、代码实现不同：jdk代理要求目标类和代理对象需要实现同一接口；cglib不要求这个。（springAOP通过这个不同来选择使用什么样的代理方式实现）
>
> **Spring中实现代理的方式**
>
> 第一种：静态代理。
>
> 第二种：jdk代理，实现InvocationHandler来创建代理类
>
> 第三种：cglib代理，通过实现MethodIntercepter对象来创建代理类
>
> spring-aop优化了整个流程，使用注解的方式实现，本质还是基于上面三种

13、Spring的注入方式

>1、构造方法注入
>
>2、setter注入
>
>​	所谓setter注入就是根据类的set方法对属性进行属性值的赋值
>
>![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20230128143758.png)
>
>





# Spring要学什么

+ Spring是什么，为什么要用Spring
+ Spring的一些核心概念：IOC、AOP、事务
+ Spring的核心组件的原理实现
+ Spring中的设计模式
+ Spring的一些核心注解的实现方式



+ IOC的注入方式
+ Spring事务
+ AOP的实现原理
+ Bean的生命周期



# 1、BeanFactory和ApplicationContext

## 1.1、BeanFactory

### 做什么的

接口本身只有关于bean的一些管理
但是Spring的核心功能

- 控制反转
- 依赖注入
- 单例Bean的生命周期

都是由BeanFactory的子类进行管理的

### DefaultListableBeanFactory

1、是什么？
默认的BeanFactory接口的实现类，其中可以对Bean的创建进行一系列管理
包括管理Bean的单例/多例、Bean的名称等等

2、如何使用？
默认在项目启动的时候会去调用将所有需要注册的类（有相关注解、在目标位置、使用目标代码格式等）注册到工厂中。注册方式类似下面的代码

```java
    public static void main(String[] args) {
        //创建默认的BeanFactory对象
        DefaultListableBeanFactory defaultListableBeanFactory = new DefaultListableBeanFactory();
        //使用类创建Definition对象
        AbstractBeanDefinition beanDefinition =
                BeanDefinitionBuilder.genericBeanDefinition(CoderymyDemoApplication.class).setScope("singleton").getBeanDefinition();
        //将Definition 对象加入BeanFactory
        defaultListableBeanFactory.registerBeanDefinition("kcCouponApplication", beanDefinition);
        for (String name:defaultListableBeanFactory.getBeanDefinitionNames()){
            System.out.println(name);
        }
    }
```



### 后处理器

补充BeanFactory的功能

+ 不会主动调用BeanFactory后处理器
+ 不会主动调用Bean后处理器
+ 不会主动初始化对象（单例）
+ 等



是什么：基础的使用Definition注册到BeanFactory只是将Bean本身注册到了Spring池中。但是Spring还有其他的功能呢，比如我的类中的一些属性上标注了`@Bean`注解这些属性也需要注册进去呢；还有我的类方法中使用的一些对象是通过`@Autowried`注册进来的呢。

所以就需要后处理器来帮助进行一些其他辅助操作



+ BeanFactory后处理器

  BeanFactoryPostProcessor，可以用来处理注册进入的Bean其中的还有需要注册的对象

+ Bean 后处理器

  BeanPostProcessor，处理类似`@Autowried`，`@Value`等注解的功能

```java
        //将BeanFactory的后处理器加入到Bean的创建流程中
        defaultListableBeanFactory.getBeansOfType(BeanFactoryPostProcessor.class).values().stream().forEach(beanFactoryPostProcessor -> {
            beanFactoryPostProcessor.postProcessBeanFactory(defaultListableBeanFactory);
        });
        
        //将Bean的后处理器加入到Bean的创建流程中
        defaultListableBeanFactory.getBeansOfType(BeanPostProcessor.class).values().stream().forEach(defaultListableBeanFactory::addBeanPostProcessor);

```



## 1.2、ApplicationContext

应用上下文对象
除了BeanFactory的功能之外扩展的功能：

- 资源对象管理classpath:xxxx
- 环境数据管理[xxxx.properties](http://xxxx.properties)
- 国际化（翻译浏览器）：MessageSource
- 发布事件

```
ConfigurableApplicationContext context = SpringApplication.run(KcCouponApplication.class, args);
//国际化
context.getMessage();
//静态资源文件
context.getResources();
//环境相关 系统环境变量、properties等
context.getEnvironment();
//发布事件（用于代码解耦合，和MQ逻辑差不多） 继承PublishEvent接口就是事件 使用@EventListener进行事件监听
context.publishEvent();
```



1、ClassPathXmlApplicationContext

基于类路径，也就是`xxx.xml`文件对资源文件的管理，也就是对xml的bean的解析并注入进去

```xml
<bean id="beanService"  class="cn.coderymy.Service.BeanService"/>
```

2、FilesSystemXmlApplication

基于磁盘路径的xml文件。也就是需要在注入的时候将整个路径全部输入

3、AnnotationConfigApplicationContext

基于Java类的配置类的实现

4、AnnotationConfigServletWebServerApplicationContext

基于Java类的servelet也就是web环境创建



## 1.3、两者的关系

ApplicationContext的一部分功能是继承自BeanFactory

ApplicationContext除了BeanFactory继承来的数据之外，还通过和其他的接口获取的数据进行组合并扩展BeanFactory的功能



从上述后处理器可以看出来BeanFactory并不会主动加载那些后处理器，这样的话功能就很单一了，只会扫描并将对象加入BeanFactory中。那么其他的Spring扩展功能都没有实现。

所以ApplicationContext实现BeanFactory的时候就实现了一些其他的逻辑信息



# 2、Bean的生命周期

1. 先得找到需要初始化的Bean
2. 对Bean创建对象（调用构造方法）
3. 创建对象需要对标注的属性赋值
4. Spring对这个对象进行一些初始化操作，让他达到满足放入Spring池中的要求
5. 放入Map这个单例池中
6. 使用这个Bean
7. 不用了，以后也不用了就销毁这个Bean

构造->依赖注入->初始化->使用->销毁

```java
@Component
public class UserService{
  
  @Autowried
  public UserMapper userMapper;
  
  public void test(){
    System.out.Println("我是test")
  }
}
```



@ComponentScan->@Component->无参构造方法->对象实例

> 构造

**构造**：项目的启动类上面直接或间接的有`@ComponentScan`注解，表示要扫描包里面的`@Component`注解，扫描到了@Component注解。想要创建一个对象

创建对象的方法只有两种

1. 使用类的构造方法
2. 反射创建

所以这个地方就使用了类的默认都会有的无参构造创建了`UserService`的`bean`实例对象`userService`

> 依赖注入

对象实例->依赖注入->找这个bean实例上面加了`@Autowired`/xxx/xxx的注解->

**依赖注入**：找这个bean实例上加了`@Autowried`之类的一些注解。然后给这个bean实例的这个属性进行赋值。赋值来源就来源于Spring池中，先试用类进行获取，获取之后如果有多个就会再使用属性值进行获取。比如`private UserService userService`先去找UserService这个类，找到多个就找userService这个值对应的Bean对象



> 初始化

**初始化**：使用后处理器对这个bean进行一些设置；如果是单例将这个Bean实例对象放入Spring单例池中的Map<String,Object>中。之类的一些操作

包括一些自定义的操作，比如UserService中我想要在创建bean的时候就知道管理员的一些基本信息，也就是我有一个属性是`User admin`；然后这个数据需要从数据库中获取。 也就是userService默认带有一个动态的管理员信息

初始化前：`@PostConstruct`注解标注的方法会在初始化前进行执行，其中需要的参数会在SpringBean池中获取

初始化中：实现`InitializingBean`接口中的方法，可以做到在这个`bean`的初始化中进行执行该方法的方法体逻辑

初始化后：将AOP的切面注册到这个Bean的切点中。如果有切点，就会生成代理对象。并将这个代理对象注入到Bean池中

```java
    protected Object initializeBean(final String beanName, final Object bean, @Nullable RootBeanDefinition mbd) {
        // System.getSecurityManager()安全管理：因为下面初始化bean的时候会运行一些用户自定义的一些方法（实现BeanNameAware , BeanFactoryAware, BeanClassLoaderAware接口的方法）
        // Spring并不能保证这些方法会做一些违规操作，比如（删除系统文件、重启系统等）为了防止运行恶意代码对系统产生影响，需要对运行的代码的权限进行控制，这时候就要启用Java安全管理器。
        if (System.getSecurityManager() != null) {
            AccessController.doPrivileged((PrivilegedAction<Object>) () -> {
                // 对实现了 BeanNameAware , BeanFactoryAware, BeanClassLoaderAware的Bean进行处理
                invokeAwareMethods(beanName, bean);
                return null;
            }, getAccessControlContext());
        }
        else {
            invokeAwareMethods(beanName, bean);
        }
        Object wrappedBean = bean;
        if (mbd == null || !mbd.isSynthetic()) {
            //应用Bean的后处理器在初始化前
            wrappedBean = applyBeanPostProcessorsBeforeInitialization(wrappedBean, beanName);
        }
        try {
            //应用初始化方法（包括自定义的初始化方法）
            invokeInitMethods(beanName, wrappedBean, mbd);
        }
        catch (Throwable ex) {
            throw new BeanCreationException(
                    (mbd != null ? mbd.getResourceDescription() : null),
                    beanName, "Invocation of init method failed", ex);
        }
        if (mbd == null || !mbd.isSynthetic()) {
            //应用后处理器在初始化结束的时候
            wrappedBean = applyBeanPostProcessorsAfterInitialization(wrappedBean, beanName);
        }

        return wrappedBean;
    }
```

处理继承了Aware接口的Bean的一些方法`invokeAwareMethods`

```java
    /**
     * 处理继承Aware的bean的一些操作
     *      Aware有很多子接口，这些接口拥有一种感知能力，把你想要的对象注入到你的类中
     * 如果实现了BeanNameAware，则会有一个方法setBeanName，在方法里面可以自定义一些操作。然后这个地方就有调用这个方法。
     * 如果实现了BeanClassLoaderAware，就会调用setBeanClassLoader方法
     * 如果实现了BeanFactoryAware，就会调用setBeanFactory方法。
     * 区别在于参数不一样，具体的方法所能实现的功能也不一样
     * @param beanName
     * @param bean
     */
    private void invokeAwareMethods(final String beanName, final Object bean) {
        if (bean instanceof Aware) {
            if (bean instanceof BeanNameAware) {
                ((BeanNameAware) bean).setBeanName(beanName);
            }
            if (bean instanceof BeanClassLoaderAware) {
                ClassLoader bcl = getBeanClassLoader();
                if (bcl != null) {
                    ((BeanClassLoaderAware) bean).setBeanClassLoader(bcl);
                }
            }
            if (bean instanceof BeanFactoryAware) {
                ((BeanFactoryAware) bean).setBeanFactory(AbstractAutowireCapableBeanFactory.this);
            }
        }
    }

class A implements BeanNameAware , BeanFactoryAware, BeanClassLoaderAware {
    @Override
    public void setBeanName(String name) {
    }
    @Override
    public void setBeanClassLoader(ClassLoader classLoader) {
    }
    @Override
    public void setBeanFactory(BeanFactory beanFactory) throws BeansException {
    }
}
```

处理该工厂使用的后处理器作用在该bean上`applyBeanPostProcessorsBeforeInitialization`

```java
    /**
     * 在Bean的初始化前使用Bean的后处理器
     * 遍历使用此工厂创建的 bean 的 BeanPostProcessor 列表。对该bean进行应用这些后处理器
     * @param existingBean
     * @param beanName
     * @return
     * @throws BeansException
     */
    @Override
    public Object applyBeanPostProcessorsBeforeInitialization(Object existingBean, String beanName)
            throws BeansException {

        Object result = existingBean;
        for (BeanPostProcessor processor : getBeanPostProcessors()) {
            Object current = processor.postProcessBeforeInitialization(result, beanName);
            if (current == null) {
                return result;
            }
            result = current;
        }
        return result;
    }

```

按照用户自定义的规则开始初始化这个 Bean`invokeInitMethods`

```java
    /**
     * 应用用户自定义的规则进行初始化这个Bean
     * 如果自定义？
     * 1、实现InitializingBean接口的afterPropertiesSet方法
     * 2、该bean的RootBeanDefinition 中initMethod 方法
     */
    protected void invokeInitMethods(String beanName, final Object bean, @Nullable RootBeanDefinition mbd)
            throws Throwable {
        //1、判断是否实现了InitializingBean接口
        boolean isInitializingBean = (bean instanceof InitializingBean);
        if (isInitializingBean && (mbd == null || !mbd.isExternallyManagedInitMethod("afterPropertiesSet"))) {
            if (logger.isTraceEnabled()) {
                logger.trace("Invoking afterPropertiesSet() on bean with name '" + beanName + "'");
            }
            if (System.getSecurityManager() != null) {
                try {
                    AccessController.doPrivileged((PrivilegedExceptionAction<Object>) () -> {
                        ((InitializingBean) bean).afterPropertiesSet();
                        return null;
                    }, getAccessControlContext());
                }
                catch (PrivilegedActionException pae) {
                    throw pae.getException();
                }
            }
            else {
                ((InitializingBean) bean).afterPropertiesSet();
            }
        }
        if (mbd != null && bean.getClass() != NullBean.class) {
            //获取这个Bean的初始化方法。然后去执行他的invokeCustomInitMethod方法去调用初始化方法
            String initMethodName = mbd.getInitMethodName();
            if (StringUtils.hasLength(initMethodName) &&
                    !(isInitializingBean && "afterPropertiesSet".equals(initMethodName)) &&
                    !mbd.isExternallyManagedInitMethod(initMethodName)) {
                invokeCustomInitMethod(beanName, bean, mbd);
            }
        }
    }
```

初始化总结：初始化的时候Spring干了几件事

1、处理实现了BeanNameAware , BeanFactoryAware, BeanClassLoaderAware的Bean的方法

2、在初始化前调用这个工厂配置的后处理器

3、调用用户自定义的初始化方法（InitializingBean接口、RootBeanDefinition 中initMethod 方法）

4、在初始化结束调用这个工厂配置的后处理器



> Aware接口和InitializingBean接口：
>
> BeanNameAware：可以获取自己的Bean的名字
>
> ```java
> @Component
> public class AwareDemo implements BeanNameAware, ApplicationContextAware {
> //bean的名称
> private String beanName;
> //加载该类的容器对象
> private ApplicationContext applicationContext;
> @Override
> public void setBeanName(String name) {
>   this.beanName = name;
> }
> @Override
> public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
>   this.applicationContext = applicationContext;
> }
> 
> public String getBeanName() {
>   return beanName;
> }
> public ApplicationContext getApplicationContext() {
>   return applicationContext;
> }
> }
> 
> 
> @RunWith(SpringRunner.class)
> @SpringBootTest
> public class AwareTestDemo {
> @Autowired
> AwareDemo awareDemo;
> @Test
> public void testBeanNameAware() {
>   System.out.println("加载的beanName是：" + awareDemo.getBeanName());
>   //加载的beanName是：beanNameAwareDemo
> }
> @Test
> public void testApplicationContext() {
>   System.out.println("加载我的容器是：" + awareDemo.getApplicationContext());
>   //加载我的容器是：org.springframework.web.context.support.GenericWebApplicationContext@4c1909a3, started on Mon Apr 18 15:32:01 CST 2022
> }
> }
> 
> ```
>
> InitializingBean：可以进行一些初始化之后的一些操作
>
> ```java
> public class InitializingBeanDemo implements InitializingBean {
> //Bean初始化之后的自定义操作，在这个类中就可以将一些初始化的业务逻辑加载进来
> @Override
> public void afterPropertiesSet() throws Exception {
>   //业务逻辑
>   //@PostConstruct也是可以进行初始化之后的一些操作的。加到方法上即可。两者的区别在于注解需要针对ApplicationContext上下文处理对象增加后处理器，前者是逻辑自带的进行调用
> }
> }
> ```
>
> 总结：Aware接口和InitializingBean接口是属于Bean创建的内置功能，也就是内置逻辑代码实现。而类似@Autowried、@PostConstruct是借用后处理器进行加载的扩展功能



## 3、AOP的实现原理

## 3.1、概述

**什么是AOP？**

AOP并不是Spring专属的，他只是一种开发模式，在不修改源代码的情况下对代码进行增强。借助于动态代理的模式进行开发



**不使用Spring如何实现AOP？**

类的方法本身是**有实现接口来**的：使用JDK动态代理

> 实现：
>
> 创建**接口实现类代理对象**，增强类的方法
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/gMufk7.jpg)
>
> 1. 创建要增强的对象：创建要增强的接口和实现类
>
>    ```java
>    public interface UserInfo {
>        void sayHello();
>    }
>    public class UserInfoImpl implements UserInfo{
>        @Override
>        public void sayHello() {
>            System.out.print("hello");
>        }
>    }
>    ```
>
> 2. 创建增强对象：代理对象中参数需要实现了InvocationHandler的对象
>
>    ```java
>    class UserInfoProxy implements InvocationHandler {
>        private Object obj;
>        public UserInfoProxy(Object obj) {
>            this.obj = obj;
>        }
>        @Override
>        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
>            //增强的目标方法
>            method.invoke(obj, args);
>            //要增强的逻辑
>            System.out.println(" my Name is Tom");
>            return null;
>        }
>    }
>    ```
>
> 3. 创建接口实现类代理对象执行业务逻辑：业务执行的时候不直接使用对应的实现类来执行，而是使用接口的代理对象执行对应的方法。所以要创建接口的代理对象
>
>    ```java
>    public class JDKProxy {
>    
>        public static void main(String[] args) {
>            UserInfo userInfo = new UserInfoImpl();
>            //创建接口实现类代理对象
>            Class[] interfaces = {
>                    UserInfo.class
>            };
>          //newProxyInstance(classLoader：用来加载运行期间动态生成的字节码文件的，切入的那个接口，要切入的代码逻辑)
>            UserInfo info = (UserInfo) Proxy.newProxyInstance(JDKProxy.class.getClassLoader(), interfaces, new UserInfoProxy(userInfo));
>            info.sayHello();
>        }
>    }
>    ```
>
> 4. 结果输出：hello my Name is Tom



类的方法本身不是实现接口（是实现的也可以没关系）来的：使用CGLIB动态代理

> 实现：
>
> 创建**子类的代理对象**，增强类的方法
>
> UserInfo中sayHello。然后Person中继承UserInfo。在sayHello方法的实现先调用super.sayHello();然后写具体的增强逻辑
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/UdsPZC.jpg)
>
> ```java
> public static void main(String[] args) {
>   UserInfo userInfo = new UserInfoImpl();
> 
>   //代理是子类，目标是父类。所以父类本身不能是final类型
>   UserInfo userInfoProxy = (UserInfo) Enhancer.create(UserInfoImpl.class, new MethodInterceptor() {
>       //o：执行方法的本身
>       //method：要切入的方法
>       //args：执行方法的实际参数
>       //methodProxy：
>       @Override
>       public Object intercept(Object o, Method method, Object[] args, MethodProxy methodProxy) throws Throwable {
>           //增强的目标方法
>           method.invoke(userInfo, args);
>           //要增强的逻辑
>           System.out.println(" my Name is Tom");
>           return null;
>       }
>   });
>   userInfoProxy.sayHello();
> }
> ```
>
> 



**AOP概念**

+ 连接点：一个类中的可以被增强的方法就叫做连接点：比如上述的UserInfo中的sayHello()
+ 切点：实际被增强的方法，就称为切点
+ 切面：一个动作：将通知应用到切点的操作动作就是切面
+ 通知：增强的逻辑代码。`System.out.println(" my Name is Tom");`
  + 前置通知：
  + 后置通知：方法执行完
  + 环绕通知：前后都通知
  + 异常通知：出现异常才执行切面代码
  + 最终通知：有没有异常都会执行



AOP->面向切面编程->动态代理->CGLib/jdk



> AOP是如何生成的这个类的代理对象

在对象初始化之后。这个时候已经生成了这个类的普通对象，然后发现有切面逻辑切入了这个类的方法切点。就去生成一个代理对象，并最终放入Spring池中的也是这个代理对象。而本身的普通对象放在了JVM中

> 举例说明：

```java
public class UserService{
  public void test(){
  	System.out.println("test");  
  }
}


public void proxy{
  
  @Before("xxx.xxx.UserService.test()")
  public void testProxy(){
    System.out.println("proxyTest");
  }
}
```

在Spring生成UserService对象的初始化之后，发现有个切点是这个userService的test方法。所以就生成了类似下面的一个类及其对象，并将这个对象放入了Spring池中`map.put("userService",UserServicePorxy)`

```java
public class UserServiceProxy extends UserService{
  UserService target;
  
  public void proxyTest(){
    System.out.println("proxyTest");
    target.test();
  }
}
```





# 4、概述

## 1、Scope

+ singleton：每次都是同一个对象
+ prototype：每次都是不同的对象
+ request：每次的请求都是一个对象-web
+ session：每个请求的session相同就是一个对象-web
+ application：每个应用程序创建和销毁进行管理（WebServlet）-web

放在类的注解`@Scope("singleton")`上





# 5、Spring中的设计模式

## 5.1、简单工厂模式

> 什么是简单工厂？

通过一个xxxFactory的一个方法，可以通过唯一标示来获取到你想要的那个抽象类的实现对象

> 举例说明？

抽象类：球

实现类：红球、白球、大球、小球

工厂：球工厂，方法参数（颜色，大小）

这样就可以在工厂中获取到颜色为红大小为小的红色小球。

> Spring中如何体现？

Spring中的BeanFactory是简单工厂的最直接实现方式。

加入工厂：在项目启动的时候针对每个需要加入的类创建他的BeanDefinition对象，然后将其加入到Spring常量池ConcurrentHashMap中

获取：就使用ConcurrentHashMap的key进行获取。在整个项目中只要是命名为这个key的该类对象，无论是否实例化都会默认给new出一个对象赋值给它

> Spring为什么要这样用？

优点：

1. 松耦合
2. 工厂的统一化管理可以在Spring中增添很多扩展功能。比如各种的aware方法，Bean的初始化方法等。这也是Spring能集合各种框架进行统一开发的根本



## 5.2、工厂方法

> 什么事工厂方法？

也可以称为抽象工厂设计模式。通俗的讲就是工厂的工厂。

工厂方法将具体的对象的实例下放到具体的工厂去实现，而这个工厂的工厂要做的就是告诉这些工厂如何协调实现。

> 举例说明？

抽象类：球

抽象工厂：色彩工厂、材质工厂

实现类：塑料红球、玻璃白球

所以调用者需要先实例化出来具体的色彩工厂和材质工厂的对象，才能实例出来具体的实现类。

目的就是在球的颜色和材质的基础上扩宽功能的时候能更加方便。比如扩宽球的形状

> Spring中如何实现？

Spring中有一个接口叫做`FactoryBean`

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/RisW8Z.png)



> Spring为什么要这么用？

我们在将业务抽离出来形成抽象工厂的时候，Spring也在想怎么管理这些工厂。所以就建立了一个工厂的工厂

打个比方：Mapper文件，我们用的时候发现`@Mapper`注解的相关xml我们可以使用`@select`、`@update`注解直接进行操作。那么我们将Mapper作为一个工厂。那么Spring就将Mapper、Service、Controller的生产厂商叫做工厂的工厂来统一化管理这些工厂都具有`依赖注入`的功能



## 5.3、单例模式

> 什么是单例模式？

老生长谈了，就是这个对象只提供一个实例供所有的逻辑使用。

> 举例说明？

在开发OA系统的时候，总是会有直属上级的概念。直属上级一般只有一个，这个时候针对这个用户的直属上级对象就只能获取一个，无论什么时候都只能获取到的是同一个

实现上：

+ 禁止外部调用构造方法
+ 获取对象的时候判断对象是否存在，存在则返回原本的

> Spring如何使用单例模式？

1、在类的创建上可以增加注解`@Scope`来标明该类以后管理的模式是什么样的，其中可以用到的参数是：

+ singleton：每次都是同一个对象
+ prototype：每次都是不同的对象
+ request：每次的请求都是一个对象-web
+ session：每个请求的session相同就是一个对象-web
+ application：每个应用程序创建和销毁进行管理（WebServlet）-web

2、在项目启动Spring将每个类加载到Spring池中的时候会根据这个参数的结果来加入对应的池

3、获取的时候

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/xkpHuX.png)

```java
    @Nullable
    protected Object getSingleton(String beanName, boolean allowEarlyReference) {
        //从一级缓存Bean池中使用beanName获取对象
        Object singletonObject = this.singletonObjects.get(beanName);
        if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
            synchronized (this.singletonObjects) {
                //从二级缓存Bean池中使用beanName获取对象
                singletonObject = this.earlySingletonObjects.get(beanName);
                if (singletonObject == null && allowEarlyReference) {
                    //缓存Bean池都获取不到就获取这个BeanName对应的工厂类
                    ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
                    if (singletonFactory != null) {
                        //使用工厂类获取这个对象并放入一级二级缓存中
                        singletonObject = singletonFactory.getObject();
                        this.earlySingletonObjects.put(beanName, singletonObject);
                        this.singletonFactories.remove(beanName);
                    }
                }
            }
        }
        return singletonObject;
    }
```









## 5.4 适配器模式

> 什么是适配器模式？

为了满足两个业务本来不相关，但是现在想要将其关联起来的。比如本来有一个User服务，还有一个Account服务。现在想要用户的账户信息。就需要有一个适配器将这两个类关联起来。

重点在于Adapter

> Spring如何使用适配器模式？

HTTP请求SpringMVC的时候，通过HandlerAdatper发放到不同的Handler。然后不同的Handler执行结束之后再将结果转换成ModelAndView让HanderAdataper进行处理返回

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/h8MNcZ.png)



也就是我本身HTTP只要JSON格式的返回。但是Controller层给的是一个String。这个时候适配器就根据配置将String转换成JSON的数据。还有就是REQ给的是一个一个的key-value。适配器将其组装成一个完整的对象给到Controller进行处理逻辑。



## 5.5 装饰器模式

> 什么是装饰器模式？

就是给类本身增加一些功能，增强类。而且是动态的按照需要增强类的各个属性方法等

1. 动态增加功能，动态撤销
2. 类功能类似于子类的扩展

Decorator

> 举个例子

1. 杯子这个接口，有一个方法，takeInWater()；装水
2. 有大杯子和小杯子，大杯子可以装1000ml，小杯子可以装500ml
3. 有一个带有装饰物的杯子的抽象类，其中有一个属性是杯子，还有一个方法是挂件pendant()
4. 带有装饰物的杯子的实现类，pendant()方法是挂了一个小猪

> Spring如何实现装饰器模式？

Spring在进行Datasource配置的时候，有些是针对oracle的，有些是针对Mysql的。Spring需要在其中进行动态的切换来将SqlSessionFactory创建出来。



## 5.6 代理模式

> 什么是代理模式？

简单了解就是，在原本可以直接操作的类中间放一层代理层

也就是原本一个类的功能，可以被另一个代理类来使用

> Spring如何实现？

AOP的实现就是代理模式最大的例子。无论是动态代理还是静态的生成代理类都是一种代理的方式。都是从开发者的角度来增强方法

不再赘述代理模式的实现（AOP动态代理的实现）

## 5.7 观察者模式

> 什么是观察者模式？

一种行为型的模式

定义对象间的一种一对多的依赖关系，当一个对象的状态发生改变时，所有依赖于它的对象都得到通知并被自动更新。

> 实现案例？

不恰当的例子：我们使用的Cannl、MQ的通知型等等



> Spring中如何实现？

Spring的ApplicationEvent事件监听机制









# Q&A

## 1、Bean的创建是在项目初始化启动的时候嘛

考点：Bean的延迟创建

并不一定是，具体其实注册进入BeanFactory的时候只是指定说，这个Bean会注入到工厂中，也就是BeanName放入了Map的Key中。但是并不会创建这个对象



当这个Bean第一次使用的时候去工厂中去取，发现取不到，就会创建这个Bean然后放入Spring池中，并返回这个创建好了的Bean



DefaultListableBeanFactory中有一个方法`preInstantiateSingletons`表示针对单例对象在初始化的时候就创建其对象。这样针对单例对象就不会延迟创建



## 2、如果一个Bean的注入既有`@Autowried`又有`@Resource`会怎么样？

默认情况下会使用`@Autowried`进行注入。因为在注解扫描的时候会先处理所有扫描到的@Autowried注解。

如果想要让@Resource生效。可以在添加Bean后处理器的时候。添加比较器

```java
//将Bean的后处理器加入到Bean的创建流程中
        defaultListableBeanFactory.getBeansOfType(BeanPostProcessor.class).values().stream()        .sorted(defaultListableBeanFactory.getDependencyComparator())   .forEach(defaultListableBeanFactory::addBeanPostProcessor);
```



## 3、RootBeanDefinition是什么呢？

我可以理解就是一个Bean抽象概念嘛

其中存储了这个Bean的基本信息

1. 定义了id、别名与Bean的对应关系（BeanDefinitionHolder）
2. Bean的注解（AnnotatedElement）
3. 具体的工厂方法（Class类型），包括工厂方法的返回类型，工厂方法的Method对象
4. 构造函数、构造函数形参类型
5. Bean的class对象



## 4、从Bean生命周期看设计模式

纵观全局的初始化方法可以看出来Spring总是干这么一件事

我判断你是否继承了我一个接口：继承了我这个接口就说明你自定义了一些操作，我就去调用我这个接口的方法。



## 5、多个构造方法，Spring构造时候如何选择？

1、有注解`@Autowired`的构造方法优先

2、无参构造方法优先

3、多个有参构造且没有注解。多个构造都有注解，抛出异常



## 6、Spring事务？

原理其实就是基于Spring的AOP操作。在调用SQL的时候切点切入的切面逻辑是开启事务。在SQL执行出现任何问题的时候或者管理的整个方法抛出需要事务捕捉的异常的时候，就回滚事务



## 7、一定会使用代理方式实现AOP嘛

+ AspectJ插件可以帮助在**编译阶段**将“通知”业务代码切入到切点中。这样可以不用生成代理类来帮助实现

+ agent方式，在**类加载的阶段**将代码加载进去

  在运行Java代码的时候，加一个jvm参数

  `-javaagent:xxx/xxx/aspectjweaver-1.9.7.jar`



## 8、包扫描的代码实现

```java
ConfigurableApplicationContext context = SpringApplication.run(CoderymyDemoApplication.class, args);
        DefaultListableBeanFactory defaultListableBeanFactory = new DefaultListableBeanFactory();
        //获取要扫描的包路径，也就是@MapperScan("")
        MapperScan annotation = AnnotationUtils.findAnnotation(CoderymyDemoApplication.class, MapperScan.class);
        if (annotation != null) {
            String[] basePackages = annotation.basePackages();
            AnnotationBeanNameGenerator generator=new AnnotationBeanNameGenerator();
            for (String str : basePackages) {
                //要的目标查询路径是这样的classPath*:xxx/xxx/xxx.class
                String path = "classpath*:" + str + "**/*.class";
                System.out.println("查询的路径是：" + path);
                CachingMetadataReaderFactory readerFactory = new CachingMetadataReaderFactory();
                //使用路径获取Bean
                Resource[] resources = context.getResources(path);
                for (Resource resource : resources) {
                    MetadataReader metadataReader = readerFactory.getMetadataReader(resource);
                    //获取类的基本信息
                    ClassMetadata classMetadata = metadataReader.getClassMetadata();
                    //获取注解基本信息
                    AnnotationMetadata annotationMetadata = metadataReader.getAnnotationMetadata();
                    //获取注解是否有注解的派生注解
                    boolean hasMetaAnnotation = metadataReader.getAnnotationMetadata().hasMetaAnnotation(Mapper.class.getName());
                    //判断携带了Mapper或者Mapper的派生注解（也就是其注解上也引用了@Mapper注解）
                    if (metadataReader.getAnnotationMetadata().hasMetaAnnotation(Mapper.class.getName())
                            || metadataReader.getAnnotationMetadata().hasMetaAnnotation(Mapper.class.getName())) {
                        //创建Bean定义
                        AbstractBeanDefinition beanDefinition = BeanDefinitionBuilder.genericBeanDefinition(metadataReader.getAnnotationMetadata().getClassName())
                                .getBeanDefinition();
                        //将该bean命名并加入到Bean池中
                        defaultListableBeanFactory.registerBeanDefinition(generator.generateBeanName(beanDefinition,defaultListableBeanFactory), beanDefinition);
                    }
                }
            }
        }
```

