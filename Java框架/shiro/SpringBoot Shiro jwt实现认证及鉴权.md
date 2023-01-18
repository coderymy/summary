# 1. 概述

## 1.1 SpringBoot

这个就没什么好说的了，能看到这个教程的，估计都是可以说精通了`SpringBoot`的使用

## 1.2 Shiro

一个安全框架，但不只是一个安全框架。它能实现多种多样的功能。并不只是局限在web层。在国内的市场份额占比高于`SpringSecurity`，是使用最多的安全框架

可以实现用户的认证和授权。比`SpringSecurity`要简单的多。

## 1.3 Jwt

我的理解就是可以进行客户端与服务端之间验证的一种技术，取代了之前使用Session来验证的不安全性

> 为什么不适用Session？
>
> 原理是，登录之后客户端和服务端各自保存一个相应的SessionId，每次客户端发起请求的时候就得携带这个SessionId来进行比对
>
> 1. Session在用户请求量大的时候服务器开销太大了
> 2. Session不利于搭建服务器的集群（也就是必须访问原本的那个服务器才能获取对应的SessionId）

它使用的是一种令牌技术

Jwt字符串分为三部分

1. Header

   存储两个变量

   1. 秘钥（可以用来比对）
   2. 算法（也就是下面将Header和payload加密成Signature）

2. payload

   存储很多东西，基础信息有如下几个

   1. 签发人，也就是这个“令牌”归属于哪个用户。一般是`userId`
   2. 创建时间，也就是这个令牌是什么时候创建的
   3. 失效时间，也就是这个令牌什么时候失效
   4. 唯一标识，一般可以使用算法生成一个唯一标识

3. Signature

   这个是上面两个经过Header中的算法加密生成的，用于比对信息，防止篡改Header和payload

然后将这三个部分的信息经过加密生成一个`JwtToken`的字符串，发送给客户端，客户端保存在本地。当客户端发起请求的时候携带这个到服务端(可以是在`cookie`，可以是在`header`，可以是在`localStorage`中)，在服务端进行验证

> 好了，废话不多说了，下面开始实战，实战分为以下几个部分
>
> 1. `SpringBoot`整合`Shiro`
> 2. `SpringBoot`整合`Jwt`
> 3. `SpringBoot`+`Shiro`+`Jwt`
```xml
        <dependency>
            <groupId>com.auth0</groupId>
            <artifactId>java-jwt</artifactId>
            <version>3.11.0</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt</artifactId>
            <version>0.9.1</version>
        </dependency>
```

# 2. SpringBoot整合Shiro

两种方式：

1. 将ssm的整合的配置使用java代码方式在springBoot中写一遍
2. 使用官方提供的start

## 2.1 使用start整合springBoot

pom.xml

```
<dependency>
    <groupId>org.apache.shiro</groupId>
    <artifactId>shiro-spring-boot-web-starter</artifactId>
    <version>1.4.0</version>
</dependency>
<!--注意不要写成shiro-spring-boot-starter-->
```

application.properties

```
shiro.loginUrl="xxx"
#认证不通过的页面
shiro.UnauthorizedUrl="xxx"
#授权不通过的跳转页面
```

创建ShiroConfig.java进行一些简单的配置

```
@Configuration
public class SpringShiroConfig {
    @Bean
    public Realm customRealm() {
        return new CustomRealm();
    }
    @Bean
    public DefaultWebSecurityManager securityManager() {
        DefaultWebSecurityManager securityManager = new DefaultWebSecurityManager();
        securityManager.setRealm(customRealm());
        // 关闭 ShiroDAO 功能
        DefaultSubjectDAO subjectDAO = new DefaultSubjectDAO();
        DefaultSessionStorageEvaluator defaultSessionStorageEvaluator = new DefaultSessionStorageEvaluator();
        // 不需要将 Shiro Session 中的东西存到任何地方（包括 Http Session 中）
        defaultSessionStorageEvaluator.setSessionStorageEnabled(false);
        subjectDAO.setSessionStorageEvaluator(defaultSessionStorageEvaluator);
        securityManager.setSubjectDAO(subjectDAO);
        return securityManager;
    }
    @Bean
    public ShiroFilterChainDefinition shiroFilterChainDefinition() {
        DefaultShiroFilterChainDefinition chain = new DefaultShiroFilterChainDefinition();
        // 哪些请求可以匿名访问
        chain.addPathDefinition("/login", "anon");      // 登录接口
        chain.addPathDefinition("/notLogin", "anon");   // 未登录错误提示接口
        chain.addPathDefinition("/403", "anon");    // 权限不足错误提示接口
        // 除了以上的请求外，其它请求都需要登录
        chain.addPathDefinition("/**", "authc");
        return chain;
    }
    // Shiro 和 Spring AOP 整合时的特殊设置
    @Bean
    public DefaultAdvisorAutoProxyCreator getDefaultAdvisorAutoProxyCreator() {
        DefaultAdvisorAutoProxyCreator creator = new DefaultAdvisorAutoProxyCreator();
        creator.setProxyTargetClass(true);
        return creator;
    }
}

//还有关闭ShiroDao功能
```

创建自定义的Realm

```
public class CustomRealm extends AuthorizingRealm {
    private static final Set<String> tomRoleNameSet = new HashSet<>();
    private static final Set<String> tomPermissionNameSet = new HashSet<>();
    private static final Set<String> jerryRoleNameSet = new HashSet<>();
    private static final Set<String> jerryPermissionNameSet = new HashSet<>();
    static {
        tomRoleNameSet.add("admin");
        jerryRoleNameSet.add("user");
        tomPermissionNameSet.add("user:insert");
        tomPermissionNameSet.add("user:update");
        tomPermissionNameSet.add("user:delete");
        tomPermissionNameSet.add("user:query");
        jerryPermissionNameSet.add("user:query");
    }
    @Override
    protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
        String username = (String) principals.getPrimaryPrincipal();
        SimpleAuthorizationInfo info =  new SimpleAuthorizationInfo();
        if (username.equals("tom")) {
            info.addRoles(tomRoleNameSet);
            info.addStringPermissions(tomPermissionNameSet);
        } else if (username.equals("jerry")) {
            info.addRoles(jerryRoleNameSet);
            info.addStringPermissions(jerryPermissionNameSet);
        }
        return info;
    }
    @Override
    protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token) throws AuthenticationException {
        String username = (String) token.getPrincipal();
        if (username == null)
            throw new UnknownAccountException("用户名不能为空");
        SimpleAuthenticationInfo info = null;
        if (username.equals("tom"))
            return new SimpleAuthenticationInfo("tom", "123", CustomRealm.class.getName());
        else if (username.equals("jerry"))
            return new SimpleAuthenticationInfo("jerry", "123", CustomRealm.class.getName());
        else
            return null;
    }
}
```

## 2.2 不使用starter

```
<!-- 自动依赖导入 shiro-core 和 shiro-web -->
<dependency>
    <groupId>org.apache.shiro</groupId>
    <artifactId>shiro-spring</artifactId>
    <version>1.4.1</version>
</dependency>
```

编写 Shiro 的配置类：ShiroConfig

将 Shiro 的配置信息（spring-shiro.xml 和 spring-web.xml）以 Java 代码配置的形式改写：

```
@Configuration
public class ShiroConfig {
    @Bean
    public Realm realm() {
        return new CustomRealm();
    }
    @Bean
    public DefaultWebSecurityManager securityManager() {
        DefaultWebSecurityManager securityManager = new DefaultWebSecurityManager();
        securityManager.setRealm(realm());
        return securityManager;
    }
    @Bean
    public ShiroFilterFactoryBean shirFilter() {
        ShiroFilterFactoryBean shiroFilterFactoryBean = new ShiroFilterFactoryBean();
        shiroFilterFactoryBean.setSecurityManager(securityManager());

        shiroFilterFactoryBean.setLoginUrl("/loginPage");
        shiroFilterFactoryBean.setUnauthorizedUrl("/403");

        Map<String, String> filterChainDefinitionMap = new LinkedHashMap<>();
        filterChainDefinitionMap.put("/loginPage", "anon");
        filterChainDefinitionMap.put("/403", "anon");
        filterChainDefinitionMap.put("/login", "anon");
        filterChainDefinitionMap.put("/hello", "anon");
        filterChainDefinitionMap.put("/**", "authc");
        shiroFilterFactoryBean.setFilterChainDefinitionMap(filterChainDefinitionMap);

        return shiroFilterFactoryBean;
    }
    /* ################################################################# */
    @Bean
    public LifecycleBeanPostProcessor lifecycleBeanPostProcessor() {
        return new LifecycleBeanPostProcessor();
    }
    @Bean
    @DependsOn("lifecycleBeanPostProcessor")
    public DefaultAdvisorAutoProxyCreator getDefaultAdvisorAutoProxyCreator() {
        DefaultAdvisorAutoProxyCreator defaultAdvisorAutoProxyCreator = new DefaultAdvisorAutoProxyCreator();
        // 强制指定注解的底层实现使用 cglib 方案
        defaultAdvisorAutoProxyCreator.setProxyTargetClass(true);
        return defaultAdvisorAutoProxyCreator;
    }
    @Bean
    public AuthorizationAttributeSourceAdvisor authorizationAttributeSourceAdvisor(DefaultWebSecurityManager securityManager) {
        AuthorizationAttributeSourceAdvisor advisor = new AuthorizationAttributeSourceAdvisor();
        advisor.setSecurityManager(securityManager);
        return advisor;
    }
}
```

编写 Controller

与 Shiro 和 SSM 的整合一样。略

编写 Thymeleaf 页面

略

# 3. SpringBoot整合Jwt

## 3.1 依赖

```
1. springboot
2. java-jwt--核心依赖
3. jjwt--java版本的辅助帮助模块
```

## 3.2 代码

1. 创建JwtUtil

   ```java
   package cn.coderymy.utils;
   
   import java.util.*;
   import com.auth0.jwt.*;
   import com.auth0.jwt.algorithms.Algorithm;
   import io.jsonwebtoken.*;
   import org.apache.commons.codec.binary.Base64;
   
   import java.util.*;
   
   
   public class JwtUtil {
   
       // 生成签名是所使用的秘钥
       private final String base64EncodedSecretKey;
   
       // 生成签名的时候所使用的加密算法
       private final SignatureAlgorithm signatureAlgorithm;
   
       public JwtUtil(String secretKey, SignatureAlgorithm signatureAlgorithm) {
           this.base64EncodedSecretKey = Base64.encodeBase64String(secretKey.getBytes());
           this.signatureAlgorithm = signatureAlgorithm;
       }
   
       /**
        * 生成 JWT Token 字符串
        *
        * @param iss       签发人名称
        * @param ttlMillis jwt 过期时间
        * @param claims    额外添加到荷部分的信息。
        *                  例如可以添加用户名、用户ID、用户（加密前的）密码等信息
        */
       public String encode(String iss, long ttlMillis, Map<String, Object> claims) {
           if (claims == null) {
               claims = new HashMap<>();
           }
   
           // 签发时间（iat）：荷载部分的标准字段之一
           long nowMillis = System.currentTimeMillis();
           Date now = new Date(nowMillis);
   
           // 下面就是在为payload添加各种标准声明和私有声明了
           JwtBuilder builder = Jwts.builder()
                   // 荷载部分的非标准字段/附加字段，一般写在标准的字段之前。
                   .setClaims(claims)
                   // JWT ID（jti）：荷载部分的标准字段之一，JWT 的唯一性标识，虽不强求，但尽量确保其唯一性。
                   .setId(UUID.randomUUID().toString())
                   // 签发时间（iat）：荷载部分的标准字段之一，代表这个 JWT 的生成时间。
                   .setIssuedAt(now)
                   // 签发人（iss）：荷载部分的标准字段之一，代表这个 JWT 的所有者。通常是 username、userid 这样具有用户代表性的内容。
                   .setSubject(iss)
                   // 设置生成签名的算法和秘钥
                   .signWith(signatureAlgorithm, base64EncodedSecretKey);
   
           if (ttlMillis >= 0) {
               long expMillis = nowMillis + ttlMillis;
               Date exp = new Date(expMillis);
               // 过期时间（exp）：荷载部分的标准字段之一，代表这个 JWT 的有效期。
               builder.setExpiration(exp);
           }
   
           return builder.compact();
       }
   
   
       /**
        * JWT Token 由 头部 荷载部 和 签名部 三部分组成。签名部分是由加密算法生成，无法反向解密。
        * 而 头部 和 荷载部分是由 Base64 编码算法生成，是可以反向反编码回原样的。
        * 这也是为什么不要在 JWT Token 中放敏感数据的原因。
        *
        * @param jwtToken 加密后的token
        * @return claims 返回荷载部分的键值对
        */
       public Claims decode(String jwtToken) {
   
           // 得到 DefaultJwtParser
           return Jwts.parser()
                   // 设置签名的秘钥
                   .setSigningKey(base64EncodedSecretKey)
                   // 设置需要解析的 jwt
                   .parseClaimsJws(jwtToken)
                   .getBody();
       }
   
   
       /**
        * 校验 token
        * 在这里可以使用官方的校验，或，
        * 自定义校验规则，例如在 token 中携带密码，进行加密处理后和数据库中的加密密码比较。
        *
        * @param jwtToken 被校验的 jwt Token
        */
       public boolean isVerify(String jwtToken) {
           Algorithm algorithm = null;
   
           switch (signatureAlgorithm) {
               case HS256:
                   algorithm = Algorithm.HMAC256(Base64.decodeBase64(base64EncodedSecretKey));
                   break;
               default:
                   throw new RuntimeException("不支持该算法");
           }
   
           JWTVerifier verifier = JWT.require(algorithm).build();
           verifier.verify(jwtToken);  // 校验不通过会抛出异常
   
   
           /*
               // 得到DefaultJwtParser
               Claims claims = decode(jwtToken);
   
               if (claims.get("password").equals(user.get("password"))) {
                   return true;
               }
           */
   
           return true;
       }
   
       public static void main(String[] args) {
           JwtUtil util = new JwtUtil("tom", SignatureAlgorithm.HS256);
   
           Map<String, Object> map = new HashMap<>();
           map.put("username", "tom");
           map.put("password", "123456");
           map.put("age", 20);
   
           String jwtToken = util.encode("tom", 30000, map);
   
           System.out.println(jwtToken);
           /*
           util.isVerify(jwtToken);
           System.out.println("合法");
           */
   
           util.decode(jwtToken).entrySet().forEach((entry) -> {
               System.out.println(entry.getKey() + ": " + entry.getValue());
           });
       }
   }
   ```

   <font color="yellow">解析：</font>

   1. <font color="red">在创建JwtUtil对象的时候需要传入几个数值</font>
      1. 这个用户，用来生成秘钥
      2. 这个加密算法，用来加密生成jwt
   2. 通过jwt数据获取用户信息的方法（decode()）
   3. 判断jwt是否存在或者过期的方法
   4. 最后是测试方法

2. 创建一个Controller

   1. 登录的Controller
      1. 获取username和password，进行与数据库的校验，校验成功执行下一步，失败直接返回
      2. 使用创建JwtUtil对象，传入username和需要使用的加密算法
      3. 创建需要加在载荷中的一些基本信息的一个map对象
      4. 创建jwt数据，传入username，保存时间，以及基本信息的map对象
   2. 校验Controller
      1. 获取前台传入的Jwt数据
      2. 使用`JWTUtil`中的`isVerify`进行该jwt数据有效的校验



# 4. SpringBoot+Shiro+Jwt

1. 由于需要对shiro的SecurityManager进行设置，所以不能使用shiro-spring-boot-starter进行与springboot的整合，只能使用spring-shiro

   ```xml
   <!-- 自动依赖导入 shiro-core 和 shiro-web -->
   <dependency>
       <groupId>org.apache.shiro</groupId>
       <artifactId>shiro-spring</artifactId>
       <version>1.4.1</version>
   </dependency>
   ```

   

2. 由于需要实现无状态的web，所以使用不到Shiro的Session功能，严谨点就是将其关闭

   ```java
   public class JwtDefaultSubjectFactory extends DefaultWebSubjectFactory {
   
       @Override
       public Subject createSubject(SubjectContext context) {
           // 不创建 session
           context.setSessionCreationEnabled(false);
           return super.createSubject(context);
       }
   }
   ```

   这样如果调用`getSession()`方法会抛出异常

## 4.1 流程

1. 用户请求，不携带token，就在JwtFilter处抛出异常/返回没有登录，让它去登陆
2. 用户请求，携带token，就到JwtFilter中获取jwt，封装成JwtToken对象。然后使用JwtRealm进行认证
3. 在JwtRealm中进行认证判断这个token是否有效，也就是

```markdown
执行流程：1. 客户端发起请求，shiro的过滤器生效，判断是否是login或logout的请求<br/>    如果是就直接执行请求<br/>    如果不是就进入JwtFilter2. JwtFilter执行流程    1. 获取header是否有"Authorization"的键，有就获取，没有就抛出异常    2. 将获取的jwt字符串封装在创建的JwtToken中，使用subject执行login()方法进行校验。这个方法会调用创建的JwtRealm    3. 执行JwtRealm中的认证方法，使用`jwtUtil.isVerify(jwt)`判断是否登录过    4. 返回true就使基础执行下去
```



## 4.2 快速开始

### 0. JwtDeafultSubjectFactory

```java
package cn.coderymy.shiro;

import org.apache.shiro.subject.Subject;
import org.apache.shiro.subject.SubjectContext;
import org.apache.shiro.web.mgt.DefaultWebSubjectFactory;

public class JwtDefaultSubjectFactory extends DefaultWebSubjectFactory {

    @Override
    public Subject createSubject(SubjectContext context) {
        // 不创建 session
        context.setSessionCreationEnabled(false);
        return super.createSubject(context);
    }
}
```

### 1. 创建JwtUtil

这个一般是固定的写法，其中写了大量注释

```java
package cn.coderymy.util;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtBuilder;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.apache.commons.codec.binary.Base64;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
/*
* 总的来说，工具类中有三个方法
* 获取JwtToken，获取JwtToken中封装的信息，判断JwtToken是否存在
* 1. encode()，参数是=签发人，存在时间，一些其他的信息=。返回值是JwtToken对应的字符串
* 2. decode()，参数是=JwtToken=。返回值是荷载部分的键值对
* 3. isVerify()，参数是=JwtToken=。返回值是这个JwtToken是否存在
* */
public class JwtUtil {
    //创建默认的秘钥和算法，供无参的构造方法使用
    private static final String defaultbase64EncodedSecretKey = "badbabe";
    private static final SignatureAlgorithm defaultsignatureAlgorithm = SignatureAlgorithm.HS256;

    public JwtUtil() {
        this(defaultbase64EncodedSecretKey, defaultsignatureAlgorithm);
    }

    private final String base64EncodedSecretKey;
    private final SignatureAlgorithm signatureAlgorithm;

    public JwtUtil(String secretKey, SignatureAlgorithm signatureAlgorithm) {
        this.base64EncodedSecretKey = Base64.encodeBase64String(secretKey.getBytes());
        this.signatureAlgorithm = signatureAlgorithm;
    }

    /*
     *这里就是产生jwt字符串的地方
     * jwt字符串包括三个部分
     *  1. header
     *      -当前字符串的类型，一般都是“JWT”
     *      -哪种算法加密，“HS256”或者其他的加密算法
     *      所以一般都是固定的，没有什么变化
     *  2. payload
     *      一般有四个最常见的标准字段（下面有）
     *      iat：签发时间，也就是这个jwt什么时候生成的
     *      jti：JWT的唯一标识
     *      iss：签发人，一般都是username或者userId
     *      exp：过期时间
     *
     * */
    public String encode(String iss, long ttlMillis, Map<String, Object> claims) {
        //iss签发人，ttlMillis生存时间，claims是指还想要在jwt中存储的一些非隐私信息
        if (claims == null) {
            claims = new HashMap<>();
        }
        long nowMillis = System.currentTimeMillis();

        JwtBuilder builder = Jwts.builder()
                .setClaims(claims)
                .setId(UUID.randomUUID().toString())//2. 这个是JWT的唯一标识，一般设置成唯一的，这个方法可以生成唯一标识
                .setIssuedAt(new Date(nowMillis))//1. 这个地方就是以毫秒为单位，换算当前系统时间生成的iat
                .setSubject(iss)//3. 签发人，也就是JWT是给谁的（逻辑上一般都是username或者userId）
                .signWith(signatureAlgorithm, base64EncodedSecretKey);//这个地方是生成jwt使用的算法和秘钥
        if (ttlMillis >= 0) {
            long expMillis = nowMillis + ttlMillis;
            Date exp = new Date(expMillis);//4. 过期时间，这个也是使用毫秒生成的，使用当前时间+前面传入的持续时间生成
            builder.setExpiration(exp);
        }
        return builder.compact();
    }

    //相当于encode的方向，传入jwtToken生成对应的username和password等字段。Claim就是一个map
    //也就是拿到荷载部分所有的键值对
    public Claims decode(String jwtToken) {

        // 得到 DefaultJwtParser
        return Jwts.parser()
                // 设置签名的秘钥
                .setSigningKey(base64EncodedSecretKey)
                // 设置需要解析的 jwt
                .parseClaimsJws(jwtToken)
                .getBody();
    }

    //判断jwtToken是否合法
    public boolean isVerify(String jwtToken) {
        //这个是官方的校验规则，这里只写了一个”校验算法“，可以自己加
        Algorithm algorithm = null;
        switch (signatureAlgorithm) {
            case HS256:
                algorithm = Algorithm.HMAC256(Base64.decodeBase64(base64EncodedSecretKey));
                break;
            default:
                throw new RuntimeException("不支持该算法");
        }
        JWTVerifier verifier = JWT.require(algorithm).build();
        verifier.verify(jwtToken);  // 校验不通过会抛出异常
        //判断合法的标准：1. 头部和荷载部分没有篡改过。2. 没有过期
        return true;
    }

    public static void main(String[] args) {
        JwtUtil util = new JwtUtil("tom", SignatureAlgorithm.HS256);
        //以tom作为秘钥，以HS256加密
        Map<String, Object> map = new HashMap<>();
        map.put("username", "tom");
        map.put("password", "123456");
        map.put("age", 20);

        String jwtToken = util.encode("tom", 30000, map);

        System.out.println(jwtToken);
        util.decode(jwtToken).entrySet().forEach((entry) -> {
            System.out.println(entry.getKey() + ": " + entry.getValue());
        });
    }
}
```

### 2. 创建JwtFilter

也就是在Shiro的拦截器中多加一个，等下需要在配置文件中注册这个过滤器

```java
package cn.coderymy.filter;

import cn.coderymy.shiro.JwtToken;
import lombok.extern.slf4j.Slf4j;
import org.apache.shiro.web.filter.AccessControlFilter;

import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/*
 * 自定义一个Filter，用来拦截所有的请求判断是否携带Token
 * isAccessAllowed()判断是否携带了有效的JwtToken
 * onAccessDenied()是没有携带JwtToken的时候进行账号密码登录，登录成功允许访问，登录失败拒绝访问
 * */
@Slf4j
public class JwtFilter extends AccessControlFilter {
    /*
     * 1. 返回true，shiro就直接允许访问url
     * 2. 返回false，shiro才会根据onAccessDenied的方法的返回值决定是否允许访问url
     * */
    @Override
    protected boolean isAccessAllowed(ServletRequest request, ServletResponse response, Object mappedValue) throws Exception {
        log.warn("isAccessAllowed 方法被调用");
        //这里先让它始终返回false来使用onAccessDenied()方法
        return false;
    }

    /**
     * 返回结果为true表明登录通过
     */
    @Override
    protected boolean onAccessDenied(ServletRequest servletRequest, ServletResponse servletResponse) throws Exception {
        log.warn("onAccessDenied 方法被调用");
        //这个地方和前端约定，要求前端将jwtToken放在请求的Header部分

        //所以以后发起请求的时候就需要在Header中放一个Authorization，值就是对应的Token
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        String jwt = request.getHeader("Authorization");
        log.info("请求的 Header 中藏有 jwtToken {}", jwt);
        JwtToken jwtToken = new JwtToken(jwt);
        /*
         * 下面就是固定写法
         * */
        try {
            // 委托 realm 进行登录认证
            //所以这个地方最终还是调用JwtRealm进行的认证
            getSubject(servletRequest, servletResponse).login(jwtToken);
            //也就是subject.login(token)
        } catch (Exception e) {
            e.printStackTrace();
            onLoginFail(servletResponse);
            //调用下面的方法向客户端返回错误信息
            return false;
        }

        return true;
        //执行方法中没有抛出异常就表示登录成功
    }

    //登录失败时默认返回 401 状态码
    private void onLoginFail(ServletResponse response) throws IOException {
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        httpResponse.getWriter().write("login error");
    }
}

```

### 3. 创建JwtToken

其中封装了需要传递的`jwt`字符串

```java
package cn.coderymy.shiro;

import org.apache.shiro.authc.AuthenticationToken;

//这个就类似UsernamePasswordToken
public class JwtToken implements AuthenticationToken {

    private String jwt;

    public JwtToken(String jwt) {
        this.jwt = jwt;
    }

    @Override//类似是用户名
    public Object getPrincipal() {
        return jwt;
    }

    @Override//类似密码
    public Object getCredentials() {
        return jwt;
    }
    //返回的都是jwt
}
```

### 4. JwtRealm

创建判断`jwt`是否有效的认证方式的`Realm`

```java
package cn.coderymy.realm;

import cn.coderymy.shiro.JwtToken;
import cn.coderymy.util.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.apache.shiro.authc.*;
import org.apache.shiro.authz.AuthorizationInfo;
import org.apache.shiro.realm.AuthorizingRealm;
import org.apache.shiro.subject.PrincipalCollection;
@Slf4j
public class JwtRealm extends AuthorizingRealm {
    /*
     * 多重写一个support
     * 标识这个Realm是专门用来验证JwtToken
     * 不负责验证其他的token（UsernamePasswordToken）
     * */
    @Override
    public boolean supports(AuthenticationToken token) {
        //这个token就是从过滤器中传入的jwtToken
        return token instanceof JwtToken;
    }

    //授权
    @Override
    protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
        return null;
    }

    //认证
    //这个token就是从过滤器中传入的jwtToken
    @Override
    protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token) throws AuthenticationException {

        String jwt = (String) token.getPrincipal();
        if (jwt == null) {
            throw new NullPointerException("jwtToken 不允许为空");
        }
        //判断
        JwtUtil jwtUtil = new JwtUtil();
        if (!jwtUtil.isVerify(jwt)) {
            throw new UnknownAccountException();
        }
        //下面是验证这个user是否是真实存在的
        String username = (String) jwtUtil.decode(jwt).get("username");//判断数据库中username是否存在
        log.info("在使用token登录"+username);
        return new SimpleAuthenticationInfo(jwt,jwt,"JwtRealm");
        //这里返回的是类似账号密码的东西，但是jwtToken都是jwt字符串。还需要一个该Realm的类名

    }

}
```

### 5. ShiroConfig

配置一些信息

1. 因为不适用Session，所以为了防止会调用getSession()方法而产生错误，所以默认调用自定义的Subject方法
2. 一些修改，关闭SHiroDao等
3. 注册JwtFilter

```java
package cn.coderymy.config;

import cn.coderymy.filter.JwtFilter;
import cn.coderymy.realm.JwtRealm;
import cn.coderymy.shiro.JwtDefaultSubjectFactory;
import org.apache.shiro.mgt.DefaultSessionStorageEvaluator;
import org.apache.shiro.mgt.DefaultSubjectDAO;
import org.apache.shiro.mgt.SubjectFactory;
import org.apache.shiro.realm.Realm;
import org.apache.shiro.spring.web.ShiroFilterFactoryBean;
import org.apache.shiro.web.filter.authc.AnonymousFilter;
import org.apache.shiro.web.filter.authc.LogoutFilter;
import org.apache.shiro.web.mgt.DefaultWebSecurityManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.servlet.Filter;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

//springBoot整合jwt实现认证有三个不一样的地方，对应下面abc
@Configuration
public class ShiroConfig {
    /*
     * a. 告诉shiro不要使用默认的DefaultSubject创建对象，因为不能创建Session
     * */
    @Bean
    public SubjectFactory subjectFactory() {
        return new JwtDefaultSubjectFactory();
    }

    @Bean
    public Realm realm() {
        return new JwtRealm();
    }

    @Bean
    public DefaultWebSecurityManager securityManager() {
        DefaultWebSecurityManager securityManager = new DefaultWebSecurityManager();
        securityManager.setRealm(realm());
        /*
         * b
         * */
        // 关闭 ShiroDAO 功能
        DefaultSubjectDAO subjectDAO = new DefaultSubjectDAO();
        DefaultSessionStorageEvaluator defaultSessionStorageEvaluator = new DefaultSessionStorageEvaluator();
        // 不需要将 Shiro Session 中的东西存到任何地方（包括 Http Session 中）
        defaultSessionStorageEvaluator.setSessionStorageEnabled(false);
        subjectDAO.setSessionStorageEvaluator(defaultSessionStorageEvaluator);
        securityManager.setSubjectDAO(subjectDAO);
        //禁止Subject的getSession方法
        securityManager.setSubjectFactory(subjectFactory());
        return securityManager;
    }

    @Bean
    public ShiroFilterFactoryBean shiroFilterFactoryBean() {
        ShiroFilterFactoryBean shiroFilter = new ShiroFilterFactoryBean();
        shiroFilter.setSecurityManager(securityManager());
        shiroFilter.setLoginUrl("/unauthenticated");
        shiroFilter.setUnauthorizedUrl("/unauthorized");
        /*
         * c. 添加jwt过滤器，并在下面注册
         * 也就是将jwtFilter注册到shiro的Filter中
         * 指定除了login和logout之外的请求都先经过jwtFilter
         * */
        Map<String, Filter> filterMap = new HashMap<>();
        //这个地方其实另外两个filter可以不设置，默认就是
        filterMap.put("anon", new AnonymousFilter());
        filterMap.put("jwt", new JwtFilter());
        filterMap.put("logout", new LogoutFilter());
        shiroFilter.setFilters(filterMap);

        // 拦截器
        Map<String, String> filterRuleMap = new LinkedHashMap<>();
        filterRuleMap.put("/login", "anon");
        filterRuleMap.put("/logout", "logout");
        filterRuleMap.put("/**", "jwt");
        shiroFilter.setFilterChainDefinitionMap(filterRuleMap);

        return shiroFilter;
    }
}


```

### 6. 测试

```java
package cn.coderymy.controller;

import cn.coderymy.util.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;
@Slf4j
@Controller
public class LoginController {

    @RequestMapping("/login")
    public ResponseEntity<Map<String, String>> login(String username, String password) {
        log.info("username:{},password:{}",username,password);
        Map<String, String> map = new HashMap<>();
        if (!"tom".equals(username) || !"123".equals(password)) {
            map.put("msg", "用户名密码错误");
            return ResponseEntity.ok(map);
        }
        JwtUtil jwtUtil = new JwtUtil();
        Map<String, Object> chaim = new HashMap<>();
        chaim.put("username", username);
        String jwtToken = jwtUtil.encode(username, 5 * 60 * 1000, chaim);
        map.put("msg", "登录成功");
        map.put("token", jwtToken);
        return ResponseEntity.ok(map);
    }
    @RequestMapping("/testdemo")
    public ResponseEntity<String> testdemo() {
        return ResponseEntity.ok("我爱蛋炒饭");
    }

}

```





## 4.3 授权方面的信息

在JwtRealm中的授权部分，可以使用`JwtUtil.decode(jwt).get("username")`获取到username，使用username去数据库中查找到对应的权限，然后将权限赋值给这个用户就可以实现权限的认证了

