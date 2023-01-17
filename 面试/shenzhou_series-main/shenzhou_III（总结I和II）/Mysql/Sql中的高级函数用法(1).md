众所周知,sql是一种编程语言,只是它一般针对数据库进行一些增删改查的操作.但是我们也知道存储过程可以嵌套很强大的业务在其中.其实我们使用sql的一些函数,也可以完成很多业务处理.这些对于经常进行数据处理的人来说很常见

比如我想给出报表,报表显示姓名、年龄、性别等.但是表字段中只有idCode(身份证号).这个时候我们可以使用一些操作来获取这个信息

```sql
select t.name ,if(mod(substr(t.idCode,17,1),2),"男","女") from t_order as t where t.idCode is not null;
```

所以这些高级的函数还是很好用的.下面,简单的学习,简单的介绍.开始!!!

`🌟🌟🌟🌟🌟`表示重点掌握哦

# 字符串处理

**截取**

```sql
substring(val,begin,length); 🌟🌟🌟🌟🌟
表示将字符串val,从beign下标开始,截取length长度的字符串
下标从1开始

left(val,length); 🌟🌟🌟
表示将字符串val,从左边开始截取length个长度字符

right(val,length) 🌟🌟🌟
表示将字符串val,从右边开始截取length个长度字符

substring_index(val,delimiter,number) 🌟🌟
表示将字符串val,的第number个delimiter出现的地方开始向后截取

substr(val,begin,length) 🌟🌟🌟🌟🌟
与substring一样,只是substr()是基于Oracle的，substring()是基于SQL Server的.mysql都可以用
```

**格式化**

```sql
TRIM(val)  🌟🌟🌟🌟🌟
表示去除字符串val的开始和结尾的空格信息

LTRIM(val1) 🌟🌟
去除val1字符串开始的空格

RTRIM(val1) 🌟🌟
去除val1字符串结尾的空格

concat(val1,val2,...)  🌟
返回参数字符串拼接后的结果

concat_ws(x, val1,val2...valn)   🌟
返回参数字符串拼接后的结果,字符串之间使用x进行拼接

format(val,n)   🌟🌟🌟
格式化浮点数为###,###.##格式,其中n表示小数点后保留多少位,例如format(23456.12345,2)结果是“23,456.12”

insert(val1,index,len,val) 🌟
将val替换val1的index之后的len个字符

lower(val1) 🌟🌟🌟🌟🌟
将val1中所有字符变成小写

UPPER(val1)  🌟🌟🌟🌟🌟
将val1中的所有字符编程的大写 

REVERSE(val1)  🌟🌟🌟🌟🌟
反转字符串中的所有字符


```
**属性参数**

```sql
ascll(val) 🌟🌟
获取val第一个字符对应的ascll码值

chat_length(val) 🌟🌟🌟🌟🌟
返回val的字符数
```


# 数字运算

```
绝对值:abs(val1) 🌟🌟🌟🌟🌟

返回>=val1的最小整数: ceil(val1) 🌟

返回列表中的最大值:greatest(val1, val2, val3, ...) 🌟

返回列表中的最小值:least(val1, val2, val3, ...) 🌟

取余:mod(x,y),进行x/y获取余数 🌟🌟🌟🌟🌟

随机:rand(),获取0~1之间的随机数 🌟🌟🌟🌟🌟

取精:round(x,y),x进行取精度y位

还有类似cos()、ln()、log()之类的,和表达的意思一样,需要使用的话,可以直接将数学公式搬过来尝试
```

# 聚合函数

```sql
累加:sum(expression),返回指定列之和

返回该列最大值:max(expression) 🌟🌟🌟🌟🌟

返回该列最小值:min(expression) 🌟🌟🌟🌟🌟

计数: count(expression)该字段的数量 🌟🌟🌟🌟🌟

平均值:avg(expression) 🌟🌟🌟🌟🌟
```




# 日期处理
这里只列举一些用的较多的
```sql
now()、sqlServer是getDate()
返回当前的日期和时间

curDate()
返回当前的日期

curTime()
返回当前的时间

date_add()
给时间加时间间隔
类似:date_add(YY,1,now())给当前时间加一年

DATE_FORMAT(d,f)
按照表达式f的格式显示时间d
DATE_FORMAT('2011-11-11 11:11:11','%Y-%m-%d %r')

还有类似week(d)、month(d)、day(d)、hour(d)等都是返回d到0000-1-1的时间类型数量
```


# 高级运算符

1-true
0-false

if
```sql
IF(expr,v1,v2)
如果expr为true,就返回v1,如果为false就返回v2

```

user
```sql
User()
返回当前调用查询的用户信息
```

case
```sql
select case
    when 条件语句
    then 结果语句
    when 条件语句
    then 结果语句
    else 结果语句
    end


```

ifNull
判断是否`是null`,为null就返回1
```sql
ifNull(数据)
```

