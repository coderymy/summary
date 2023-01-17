# 变量类型

基本数据类型为:
+ bool
+ string
+ int、int8、int16、int32、int64
+ uint、uint8、uint16、uint32、uint64、uintptr
+ byte // uint8 的别名
+ rune // int32 的别名 代表一个 Unicode 码
+ float32、float64
+ complex64、complex128

# 变量的声明和初始化

**标准声明方式**

var name type
其中var是关键字,name是变量名,type是变量类型
如`var abc string`

当一个变量被声明之后，系统自动赋予它该类型的零值：int 为 0，float 为 0.0，bool 为 false，string 为空字符串，指针为 nil 等。

**批量声明方式**

var (
    a int
    b string
    c []float32
    d func() bool
    e struct {
        x int
    }
)

**初始化声明方式**

var name type =value


**推导声明**

即类似python的声明方式,不给类型由值决定
var x ="aaa"

**简短格式**
name :=value
类似`bananaColor:=yellow`
1. 不能提供类型
2. 简短声明必须在函数内部使用

```go
//标准声明
var cat string
//批量声明
var(
	rabbit string
	dog string
	fish string
)
//初始化声明
var horse string ="tall"
//推导声明
var sheep="white"

//简短声明
func main(){
    bananaColor:="yellow"
}

```

初始化即上述的在声明时初始化与简短声明时带有的初始化

## 多重赋值

`var a , b = "yellow","red"`
即按照,拆开,两边分别进行对应字段的赋值

也可以这样进行数值交换
```go
var a=100
var b=200

a,b=b,a
```

## 匿名变量
```go
func getData()(int ,int ){
    return 100,200
}
func main(){
    a,_:=getData
    _,b:=getData

    fmt.Println(a,b)
}
结果为100,200
```

这里面的_就是一个匿名变量,匿名变量初始化之后就会被抛弃,相当于只是一个占位符,没有实际效用.
匿名变量不占用内存空间,不会分配内存匿名变量与匿名变量之间也不会因为多次声明而无法使用。

# 变量的作用域

函数内定义的变量称为局部变量
函数外定义的变量称为全局变量
函数定义中的变量称为形式参数


#  常量

使用const修饰,`const 常量名 [类型]=常量值`

常量不能被修改,必须有初始值,可以用来做枚举类型

```
const (
    Unknown = 0
    Female = 1
    Male = 2
)
```

# 运算符
|运算符	|描述|	实例|
|--|--|--|
|+|	相加|	A + B 输出结果 30|
|-|	相减|	A - B 输出结果 -10|
*|	相乘	|A * B 输出结果 200|
/	|相除	|B / A 输出结果 2|
%|	求余	|B % A 输出结果 0|
++	|自增	|A++ 输出结果 11|
--|	自减	|A-- 输出结果 9|


# 数组

**声明方式**

`var 数组名 [数组长度] 数组类型`

```go
var balance [10] float32
```

数组是线性的具有相同类型的一段连续空间

**初始化**

`数组名 :=[数组长度]数组类型{初始化参数}`

如果数组长度不确定,可以使用...代替,编译器会自动按照后面指定的数组数量给定长度
```
balance := [5]float32{1000.0, 2.0, 3.4, 7.0, 50.0}
```

**访问数组**

直接使用`val[index]`即可访问,第一个数值index=0


# model类

创建方式为

```
type 名称 struct {
   member definition
   member definition
   ...
   member definition
}
```

使用`variable_name := structure_variable_type {value1, value2...valuen}`

**声明**
(Java解释)  `var 对象名 类名`

使用其中的成员,直接使用使用`对象名.成员`即可进行set和get
