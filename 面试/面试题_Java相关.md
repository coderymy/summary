# JVM

## 什么是java字节码

jvm可以理解的代码，`.class`文件

它不面向任何特定的处理器，只面向虚拟机。Java 语言通过字节码的方式，在一定程度上解决了传统解释型语言执行效率低的问题，同时又保留了解释型语言可移植的特点。所以， Java 程序运行时相对来说还是高效的（不过，和 C++，Rust，Go 等语言还是有一定差距的），而且，由于字节码并不针对一种特定的机器，因此，Java 程序无须重新编译便可在多种不同操作系统的计算机上运行。

## 为什么说 Java 语言“编译与解释并存”？

这是因为 Java 语言既具有编译型语言的特征，也具有解释型语言的特征。因为 Java 程序要经过先编译，后解释两个步骤，由 Java 编写的程序需要先经过编译步骤，生成字节码（`.class` 文件），这种字节码必须由 Java 解释器来解释执行。

## 静态方法为什么不能调用非静态成员?

1、静态方法是属于类的，在类加载的时候就会分配内存，可以通过类名直接访问。而非静态成员属于实例对象，只有在对象实例化之后才存在，需要通过类的实例对象去访问。

2、在类的非静态成员不存在的时候静态成员就已经存在了，此时调用在内存中还不存在的非静态成员，属于非法操作。



# 其他

## Oracle JDK vs OpenJDK的区别

1、版本速度。Oracle JDK 大概每 6 个月发一次主要版本，而 OpenJDK 版本大概每三个月发布一次。但这不是固定的，我觉得了解这个没啥用处。详情参见：[https://blogs.oracle.com/java-platform-group/update-and-faq-on-the-java-se-release-cadence  (opens new window)](https://blogs.oracle.com/java-platform-group/update-and-faq-on-the-java-se-release-cadence) 。

2、开源必源。OpenJDK 是一个参考模型并且是完全开源的，而 Oracle JDK 是 OpenJDK 的一个实现，并不是完全开源的；

3、稳定性。Oracle JDK 比 OpenJDK 更稳定。OpenJDK 和 Oracle JDK 的代码几乎相同，但 Oracle JDK 有更多的类和一些错误修复。因此，如果您想开发企业/商业软件，我建议您选择 Oracle JDK，因为它经过了彻底的测试和稳定。某些情况下，有些人提到在使用 OpenJDK 可能会遇到了许多应用程序崩溃的问题，但是，只需切换到 Oracle JDK 就可以解决问题；

4、效率。在响应性和 JVM 性能方面，Oracle JDK 与 OpenJDK 相比提供了更好的性能；

5、支持。Oracle JDK 不会为即将发布的版本提供长期支持，用户每次都必须通过更新到最新版本获得支持来获取最新版本；



# Java基础

## 各个数据类型大小及范围

| 数据类型 | 大小 | 范围                              |
| -------- | ---- | --------------------------------- |
| byte     | 1bit | -128～127（8-1）                  |
| short    | 2    | （(2^-15)~(2^15-1)）(16-1)        |
| int      | 4    | （-2的31次方到2的31次方-1）(32-1) |
| long     | 8    | （-2的63次方到2的63次方-1）(64-1) |
| float    | 4    |                                   |
| double   | 8    |                                   |
| char     | 2    |                                   |
| string   | 不定 |                                   |

## i++和++i的区别

i++先赋值后自增

++i先自增后赋值

## 重写和重载

重写：子类重写父类的方法

重载：同一个类中函数名相同参数列表不同

## == 和 equals() 

**`==`** 对于基本类型和引用类型的作用效果是不同的：

- 对于基本数据类型来说，`==` 比较的是值。
- 对于引用数据类型来说，`==` 比较的是对象的内存地址。

> 因为 Java 只有值传递，所以，对于 == 来说，不管是比较基本数据类型，还是引用数据类型的变量，其本质比较的都是值，只是引用类型变量存的值是对象的地址。

`equals`一般判断两个值是否相等，`==`一般判断两个变量的内存地址是否相等

**`equals()`** 不能用于判断基本数据类型的变量，只能用来判断两个对象是否相等。`equals()`方法存在于`Object`类中，而`Object`类是所有类的直接或间接父类。

`Object` 类 `equals()` 方法：

```java
public boolean equals(Object obj) {
     return (this == obj);
}
```

`equals()` 方法存在两种使用情况：

- **类没有覆盖 `equals()`方法** ：通过`equals()`比较该类的两个对象时，等价于通过“==”比较这两个对象，使用的默认是 `Object`类`equals()`方法。
- **类覆盖了 `equals()`方法** ：一般我们都覆盖 `equals()`方法来比较两个对象中的属性是否相等；若它们的属性相等，则返回 true(即，认为这两个对象相等)。

举个例子（这里只是为了举例。实际上，你按照下面这种写法的话，像 IDEA 这种比较智能的 IDE 都会提示你将 `==` 换成 `equals()` ）：

```java
String a = new String("ab"); // a 为一个引用
String b = new String("ab"); // b为另一个引用,对象的内容一样
String aa = "ab"; // 放在常量池中
String bb = "ab"; // 从常量池中查找
System.out.println(aa == bb);// true
System.out.println(a == b);// false
System.out.println(a.equals(b));// true
System.out.println(42 == 42.0);// true
```

`String` 中的 `equals` 方法是被重写过的，因为 `Object` 的 `equals` 方法是比较的对象的内存地址，而 `String` 的 `equals` 方法比较的是对象的值。

**当创建 `String` 类型的对象时，虚拟机会在常量池中查找有没有已经存在的值和要创建的值相同的对象，如果有就把它赋给当前引用。如果没有就在常量池中重新创建一个 `String` 对象。**

`String`类`equals()`方法：

```java
public boolean equals(Object anObject) {
    if (this == anObject) {
        return true;
    }
    if (anObject instanceof String) {
        String anotherString = (String)anObject;
        int n = value.length;
        if (n == anotherString.value.length) {
            char v1[] = value;
            char v2[] = anotherString.value;
            int i = 0;
            while (n-- != 0) {
                if (v1[i] != v2[i])
                    return false;
                i++;
            }
            return true;
        }
    }
    return false;
}
```

## hashCode() 与 equals()

#### hashCode() 有什么用？

`hashCode()` 的作用是获取哈希码（`int` 整数），也称为散列码。这个哈希码的作用是确定该对象在哈希表中的索引位置。

`hashCode()`定义在 JDK 的 `Object` 类中，这就意味着 Java 中的任何类都包含有 `hashCode()` 函数。另外需要注意的是： `Object` 的 `hashCode()` 方法是本地方法，也就是用 C 语言或 C++ 实现的，该方法通常用来将对象的内存地址转换为整数之后返回。

```java
public native int hashCode();
```

散列表存储的是键值对(key-value)，它的特点是：**能根据“键”快速的检索出对应的“值”。这其中就利用到了散列码！（可以快速找到所需要的对象）**

#### 为什么要有 hashCode？

我们以“`HashSet` 如何检查重复”为例子来说明为什么要有 `hashCode`？

下面这段内容摘自我的 Java 启蒙书《Head First Java》:

> 当你把对象加入 `HashSet` 时，`HashSet` 会先计算对象的 `hashCode` 值来判断对象加入的位置，同时也会与其他已经加入的对象的 `hashCode` 值作比较，如果没有相符的 `hashCode`，`HashSet` 会假设对象没有重复出现。但是如果发现有相同 `hashCode` 值的对象，这时会调用 `equals()` 方法来检查 `hashCode` 相等的对象是否真的相同。如果两者相同，`HashSet` 就不会让其加入操作成功。如果不同的话，就会重新散列到其他位置。。这样我们就大大减少了 `equals` 的次数，相应就大大提高了执行速度。

其实， `hashCode()` 和 `equals()`都是用于比较两个对象是否相等。

**那为什么 JDK 还要同时提供这两个方法呢？**

这是因为在一些容器（比如 `HashMap`、`HashSet`）中，有了 `hashCode()` 之后，判断元素是否在对应容器中的效率会更高（参考添加元素进`HastSet`的过程）！

我们在前面也提到了添加元素进`HastSet`的过程，如果 `HashSet` 在对比的时候，同样的 `hashCode` 有多个对象，它会继续使用 `equals()` 来判断是否真的相同。也就是说 `hashCode` 帮助我们大大缩小了查找成本。

**那为什么不只提供 `hashCode()` 方法呢？**

这是因为两个对象的`hashCode` 值相等并不代表两个对象就相等。

**那为什么两个对象有相同的 `hashCode` 值，它们也不一定是相等的？**

因为 `hashCode()` 所使用的哈希算法也许刚好会让多个对象传回相同的哈希值。越糟糕的哈希算法越容易碰撞，但这也与数据值域分布的特性有关（所谓哈希碰撞也就是指的是不同的对象得到相同的 `hashCode` )。

总结下来就是 ：

- 如果两个对象的`hashCode` 值相等，那这两个对象不一定相等（哈希碰撞）。
- 如果两个对象的`hashCode` 值相等并且`equals()`方法返回 `true`，我们才认为这两个对象相等。
- 如果两个对象的`hashCode` 值不相等，我们就可以直接认为这两个对象不相等。

相信大家看了我前面对 `hashCode()` 和 `equals()` 的介绍之后，下面这个问题已经难不倒你们了。

#### 为什么重写 equals() 时必须重写 hashCode() 方法？

两个方法没有定义统一的实现规则的时候，会导致两者比较的结果不想等。从而导致使用hash

因为两个相等的对象的 `hashCode` 值必须是相等。也就是说如果 `equals` 方法判断两个对象是相等的，那这两个对象的 `hashCode` 值也要相等。

如果重写 `equals()` 时没有重写 `hashCode()` 方法的话就可能会导致 `equals` 方法判断是相等的两个对象，`hashCode` 值却不相等。

**思考** ：重写 `equals()` 时没有重写 `hashCode()` 方法的话，使用 `HashMap` 可能会出现什么问题。

**总结** ：

- `equals` 方法判断两个对象是相等的，那这两个对象的 `hashCode` 值也要相等。
- 两个对象有相同的 `hashCode` 值，他们也不一定是相等的（哈希碰撞）。

更多关于 `hashCode()` 和 `equals()` 的内容可以查看：[Java hashCode() 和 equals()的若干问题解答  (opens new window)](https://www.cnblogs.com/skywang12345/p/3324958.html)



## 什么是自动拆装箱

- **装箱**：将基本类型用它们对应的引用类型包装起来；xxx.inteValue()
- **拆箱**：将包装类型转换为基本数据类型；Integer.valueof(xxx)



## 面向对象和面向过程的区别

两者的主要区别在于解决问题的方式不同：

- 面向过程把解决问题的过程拆成一个个方法，通过一个个方法的执行解决问题。
- 面向对象会先抽象出对象，然后用对象执行方法的方式解决问题。

另外，面向对象开发的程序一般更易维护、易复用、易扩展。



## 什么是深拷贝和浅拷贝

+ 深拷贝：所有都是新创建的
+ 浅拷贝：新创建一个对象，然后内部的成员对象是拷贝原本的

## 什么是引用拷贝

不创建对象，只是将对应的对象地址拷贝过来



## String

### String_`new String("ab")`会创建几个对象

两个对象，可以通过字节码指令看出来

+ `new`的一个字符串对象，存放在堆空间中
+ 还有一个"ab"在常量池中的对象。



> new String("a")+new String("b")？
>
> 
>
> 1. StringBuilder 涉及拼接，就需要StringBuilder
> 2. new String("a")
> 3. ldc将"a"放入常量池中
> 4. new String("b")
> 5. ldc将"b"放入常量池中
> 6. 结果调用toString()方法：new String()。这里的toString()方法的调用，在字符串常量池中不会生成result
>
> **所以最终创建了六个对象。且不会在常量池中生成"ab"字符串对象**



### String_intern()方法的使用

```java
public class StringInternTest{
  	public static void main(String[] args){
      	String s=new String("1");//创建了对象，s中保存的是对象在堆中的地址信息
      	s.intern();//此时是将"1"放入字符串常量池中。但是已经有了，所以该操作相当于什么都没做，只是返回了字符串常量池中的地址信息。但是没有接收
      	String s2="1";//返回字符串常量池"1"的地址信息
      	System.out.println(s==s2);
      
      	String s3=new String("1")+new String("1");//创建了"1"的对象，并在常量池中生成了"1"（忽视上面）。创建了"11"的对象，将对象在堆中的地址赋值给了s3
      	s3.intern();//将"11"放到字符串常量池中
      	//JDK6，将"11"当到了永久代中的字符串常量池中
      	//JDK7～，欲要将"11"放到堆的字符串常量池中，但是发现堆空间中有"11"的对象，所以字符串常量池中记录的就是堆空间这个对象的地址信息
      	String s4="11";//获取字符串常量池中的"11"的地址信息
      	System.out.println(s3==s4);//JDK6-false，JDK7-true
    }
}
```

JDK6：false、false

s!=s2：s是通过new出来的，保存的是堆中的地址。s2是获取的"1"常量池中的地址

s3!=s4：s3经过intern()之后会在字符串常量池中创建"11"

JDK7/8及其之后（和6的区别就是字符串常量池从永久代到了堆中）：false 、true

s!=s2：s是通过new出来的，保存的是堆中的地址。s2是获取的"1"常量池中的地址

s3==s4：s3经过intern()之后发现堆中有这个对象，所以就直接在字符串常量池中记录的是堆中这个对象的地址信息

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/字符串常量池.drawio.png)

## Comparable和Comparator的区别

### Comparable是什么

> 简介：实现该接口的类可以进行自比较

自比较：自己对象本身和参数进行比较

一个接口，实现了这个接口的类对象可以根据接口的方法compareTo进行比较来获取比较结果。同时这些对象可以被增加到Collaction集合中，使用`Collections.sort(xxx)`进行排序

```java
/**
 * 实现一个业务逻辑
 * 多张优惠券。
 * 1，金额大的在前面
 * 2，金额相同时，距离有效期最近的在前面
 * 3，前两个结果相同时，id小的在前面
 */
public class ComparableDemo {
    public static void main(String[] args) {
        List<Coupon> coupons = new ArrayList<>();
        //添加了一堆coupon。然后调用下面方法就可以对coupon进行排序。这个方法参数必须是实现了Comparable接口并按照业务实现了compareTo方法
        Collections.sort(coupons);
    }
}

@Data
class Coupon implements Comparable<Coupon> {
    private String id;
    private Date endTime;
    private int price;

    @Override
    public int compareTo(Coupon o) {
        if (o.getPrice() > this.price) {
            return 1;
        } else if (o.getPrice() == this.price) {
            if (this.endTime.compareTo(o.getEndTime()) == 0) {
                return id.compareTo(o.getId());
            } else {
                return this.endTime.compareTo(o.getEndTime());
            }
        } else {
            return -1;
        }
    }
}
```



### Comparator是什么

> 简介：可以辅助比较没有实现/想重写对方实现方法Comparable接口的对象进行比较

作用场景一般是

+ 预比较的对象没有实现Comparable接口或者实现的compareTo逻辑不是自己想要的，而且无法使用继承来实现（final）

比如我觉得String的自比较方式我不喜欢，那么就可以

```java
class Express implements Comparator<String> {
    public static void main(String[] args) {
        List<String> strings = new ArrayList<>();
        //表示不使用String自带的compareTo方法而是使用Express对象中的比较方法
        Collections.sort(strings, new Express());
    }
    @Override
    public int compare(String o1, String o2) {
        //xxxx各种逻辑实现
        return 0;
    }
}
```

### 两者的区别

Comparable侧重于**自比较**。也就是对象本身和一个对象的比较。compareTo方法参数是一个对象。

业务场景：将优惠券排序。

Comparator侧重于**外比较**，就像是帮助别人进行比较一样

业务场景：对名称排序（有时候想按照首字母的拼音排序，有时候想按首字母的笔画排序。）这个时候就可以创建多个类实现Comparator接口。



共同点：都可以使用Collections.sort()方法来对集合对象进行排序。

### 「扩展」TreeMap

相较于HashMap，TreeMap的主要特点在于可以比较元素的大小。在进行put的时候进行排序。其原理就是在创建Map的时候传入了一个比较器。在put方法的时候会调用这个比较器进行比较

```java
Map<String, String> map2 = new TreeMap<String, String>(
                new Comparator<String>() {
                    public int compare(String obj1, String obj2) {
                        //升序排序（反过来就是降序排序）
                        return obj1.compareTo(obj2);
                    }
                });
```

其中实现的逻辑可以用来进行比较；下面进行put的时候就会自动按照比较结果进行排序。

## 序列化

### 什么是序列化?什么是反序列化?

简单来说：

- **序列化**： 将数据结构或对象转换成二进制字节流的过程
- **反序列化**：将在序列化过程中所生成的二进制字节流转换成数据结构或者对象的过程

### Java 序列化中如果有些字段不想进行序列化，怎么办？

使用`transient`关键字修饰





# stack的push和add方法的区别

通过[stack类](https://so.csdn.net/so/search?q=stack类&spm=1001.2101.3001.7020)**add方法**和**push方法**源代码可知，

**add方法**其实调用的是[Vector](https://so.csdn.net/so/search?q=Vector&spm=1001.2101.3001.7020)类的add方法，返回的是一个boolean类型的值，

而**push方法**则是Stack类在Vector类的addElement方法基础上进修了一些修改，返回当前添加的元素。