# #{}和${}的区别是什么？
${}是字符串替换，#{}是预处理；使用#{}可以有效的防止SQL注入，提高系统安全性。

Mybatis在处理${}时，就是把${}直接替换成变量的值。而Mybatis在处理#{}时，会对sql语句进行预处理，将sql中的#{}替换为?号，调用PreparedStatement的set方法来赋值；
# **通常一个mapper.xml文件，都会对应一个Dao接口，这个Dao接口的工作原理是什么？Dao接口里的方法，参数不同时，方法能重载吗？**

   Mapper 接口的工作原理是JDK动态代理，Mybatis运行时会使用JDK动态代理为Mapper接口生成代理对象 MappedProxy，代理对象会拦截接口方法，根据类的全限定名+方法名，唯一定位到一个MapperStatement并调用执行器执行所代表的sql，然后将sql执行结果返回。

  Mapper接口里的方法，是不能重载的，因为是使用 全限名+方法名 的保存和寻找策略。

# Mybatis的Xml映射文件中，不同的Xml映射文件，id是否可以重复？

不同的Xml映射文件，如果配置了namespace，那么id可以重复；如果没有配置namespace，那么id不能重复；原因就是namespace+id是作为Map的key使用的，如果没有namespace，就剩下id，那么，id重复会导致数据互相覆盖。有了namespace，自然id就可以重复，namespace不同，namespace+id自然也就不同。

# 分页插件的原理是什么？

拦截待执行的sql，然后重写sql，根据dialect方言，添加对应的物理分页语句和物理分页参数。

# Xml映射文件中，除了常见的select|insert|updae|delete标签外，还有哪些标签？

<resultMap>、<parameterMap>、<sql>、<include>、<selectKey>，加上动态sql的9个标签 trim | where | set | foreach | if | choose | when | otherwise | bind 等，其中 <sql> 为sql片段标签，通过<include>标签引入sql片段，<selectKey>为不支持自增的主键生成策略标签。



# 如何获取自动生成的(主)键值?

  insert 方法总是返回一个int值 ，这个值代表的是插入的行数。 如果采用自增长策略，自动生成的键值在 insert 方法执行完后可以被设置到传入的参数对象中。

```html

<insert id=”insertname” usegeneratedkeys=”true” keyproperty=”id”>
     insert into names (name) values (#{name})
</insert>	

    name name = new name();
    name.setname(“fred”);
 
    int rows = mapper.insertname(name);
    // 完成后,id已经被设置到对象中
    system.out.println(“rows inserted = ” + rows);
    system.out.println(“generated key value = ” + name.getid());
```

# 怎么利用Mybatis实现批量数据的插入？

首先创建一个简单的insert语句，然后结合java程序，将代码和xml结合实现批量插入。

```java
<insert id=”insertname”>
insert into names (name) values (#{value})
</insert>
```

  对应的java程序利用sessionFactory去创建一个SqlSession

```java
List <string> names = new ArrayList();
names.add(“zhangsan”);
names.add(“lisi”);
names.add(“wangwu”);
// 注意这里 executortype.batch
Sqlsession sqlsession =
        sessionfactory.opensession(executortype.batch);
try {
Namemapper mapper = sqlsession.getmapper(namemapper.class);
for (string name: names) {
    mapper.insertname(name);
}
    sqlsession.commit();
} catch (Exception e) {
      e.printStackTrace();
      sqlSession.rollback();
      throw e;
}finally {
    sqlsession.close();
}
```

 这个地方建议使用excutortype.batch, 如果在xml里使用**foreach标签性能会明显下降** 。