# 简述

stream对象是java8之后的一种便捷操作集合实现筛选、排序、聚合等操作的一个`工具`

可以将stream分为两种操作模式(我发现其实这部分和mysql的事务隔离级别很类似,可以类比学习,只是个人见解)

| Stream操作分类                    |                            |                                                              |
| --------------------------------- | :------------------------: | ------------------------------------------------------------ |
| 中间操作(Intermediate operations) |     无状态(Stateless)      | unordered() filter() map() mapToInt() mapToLong() mapToDouble() flatMap() flatMapToInt() flatMapToLong() flatMapToDouble() peek() |
|                                   |      有状态(Stateful)      | distinct() sorted() sorted() limit() skip()                  |
| 结束操作(Terminal operations)     |         非短路操作         | forEach() forEachOrdered() toArray() reduce() collect() max() min() count() |
|                                   | 短路操作(short-circuiting) | anyMatch() allMatch() noneMatch() findFirst() findAny()      |

**中间操作**:只是一种标记,并不计算最终的结果
   + 无状态:指元素的处理不会受到前面元素操作的影响(即未提交不会影响后续的操作)
   + 有状态:指该操作,必须便利所有元素获取到一个类似锁的概念之后才会操作.当然这里没有锁那么严谨,只是借用锁名词帮助自己理解
**结束操作**:只有在结束的时候才会进行实际的结果计算
     + 非短路操作:需要处理所有元素才能获得结果,比如从100人中挑选所有男生
     + 短路操作:只要找到符合条件的就可以获得结果,从100人中选一个男生

所以一个完整的stream表达式,先使用中间操作进行一些计算,再使用结束操作进行统计结果.比如:从一百个人中获取一个男生.中间操作就是判断哪些是男生,结束操作就是将获得的第一个男生返回并结束整个流程


# 简单使用——简单使用

## 创建

`list.stream()`创建顺序流

`list.parallelStream()`创建并行流(处理处理集合的方式是并行执行外其他都与顺序流概念一致)、并行流需要考虑是否并行效率就一定高,而且还有一些资源的共享状态等.而且需要判定流中数据的处理不能有顺序的情况,比如我要找第一个男生.并行执行你知道返回的是哪个男生(举个例子而已,不要较真).可以使用`list.stream().parallel()`将stream顺序流转换成stream并行流

`Array.stream(array)`创建

`Stream`静态方法"Stream.of"、"Stream.iterate"、"Stream.generate"




## 中间操作——筛选

**filter**

顾名思义,进行过滤操作,流经过过滤之后,只会保留满足过滤条件的元素

`students.stream().filter(student->student.getSex==男生).结束操作()`

接受一个函数式接口Predicate<T>为入参，过滤流中的数据。

**distinct**

去重复

`Stream.of("1","2","1","3").distinct().结束操作()`

**skip**
跳过,参数为跳过的元素,下标从1开始

`Stream.of("a","b","c").skip(1)`跳过了a

**limit**
获取其中参数规定的元素

`Stream.of("a","b","c").limit(1,2)`


## 中间操作——映射

**map**
将对象集合转换成需要的某个字段集合
`List<String> names=students.stream().map(Student::getName())`

**flatMap**

与上面唯一的差别就是返回的仍然是一个Stream对象流

## 结束操作——归约

将所有参数进行一些聚合(类比Mysql的聚合函数,很多条数据,返回的是一条或者一个数据)

比如获取年龄总和、求最大值
`list.stream().reduce(Integer::sum)`

`personList.stream().reduce(0, (max, p) -> max > p.getSalary() ? max : p.getSalary(),
				Integer::max)`


## 结束操作——获取结果

**findFirst**
返回一个对象
获取第一个
`Student stu=students.stream().filter(student->student.getSex=="男生").findFirst();`



**findAny()**
返回一个对象
任意获取其中一个元素

**anyMatch()**

返回布尔
判断是否包含判定规则的元素(是否有男生)

**allMatch()**

返回布尔
判断是否全部满足判定规则(是否全是男生)

**noneMatch()**

返回布尔
判断是否没有满足判定规则的(判断是否没有男生)


**collect**

收集,其中参数类似`toList()`、`toSet`、`toMap`

简单的说就是将前面的计算结果进行一个收集返回对应的参数类型结果对象

`personList.stream().filter(p -> p.getSalary() > 8000)
				.collect(Collectors.toMap(Person::getName, p -> p))`

**count**

类似mysql的count,其中参数表示待统计字段


**sorted**

排序

```
Stream<T> sorted();
Stream<T> sorted(Comparator<? super T> comparator);

Stream.of("3", "1", "2").sorted().forEach(System.out::println);
```

