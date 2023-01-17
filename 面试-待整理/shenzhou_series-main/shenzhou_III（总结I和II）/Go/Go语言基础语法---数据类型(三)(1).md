# 类型介绍

## 数值类型

数值类型包括
+ 整数
+ 浮点数
+ 复数

### 整型

每个类型都包含其对应大小的类型
例如整型有int8、int16、int32、int64等

而且又分有符号和无符号
int8-「unit8」
int16-「unit16」
int32-「unit32」
int64-「unit64」

这里的8、16、32、64表示多少bit(二进制位)

还有一种无符号的整数类型 uintptr，它没有指定具体的 bit 大小但是足以容纳指针。uintptr 类型只有在底层编程时才需要，特别是Go语言和C语言函数库或操作系统接口相交互的地方。

### 浮点数

float32、float64

用 Printf 函数打印浮点数时可以使用“%f”来控制保留几位小数

    fmt.Printf("%.2f\n", math.Pi)
    
    3.14


### 复数

complex128（64 位实数和虚数）和 complex64（32 位实数和虚数）

复数是由两个浮点数表示的
```go
var name complex128 = complex(x, y)
var x complex128 = complex(1, 2) // 1+2i
```

第一个表示实数,第二个表示虚数

复数也可以用==和!=进行相等比较，只有两个复数的实部和虚部都相等的时候它们才是相等的。


## 布尔类型

结果只有true和false两种类型

取反使用`!`一元运算符

&&和||用法与Java一致

## 字符串类型

字符串是字节的定长数组

转义字符
+ \n：换行符
+ \r：回车符
+ \t：tab 键
+ \u 或 \U：Unicode 字符
+ \\：反斜杠自身

一般的比较运算符（==、!=、<、<=、>=、>）是通过在内存中按字节比较来实现字符串比较的

**方法**

字符串所占的字节长度可以通过函数 len() 来获取，例如 len(str)。

字符串的内容（纯字节）可以通过标准索引法来获取，在方括号[ ]内写入索引，索引从 0 开始计数：
字符串 str 的第 1 个字节：str[0]
第 i 个字节：str[i - 1]
最后 1 个字节：str[len(str)-1]

使用`+`进行字符串的拼接


**多行字符串**

使用`包括住
```go
const str = `第一行
第二行
第三行
\r\n
`
```

**其他字符串方法**

学习网站:
[字符串方法](http://c.biancheng.net/view/17.html)


## 字符类型


Go语言的字符有以下两种：
一种是 uint8 类型，或者叫 byte 型，代表了 ASCII 码的一个字符。
另一种是 rune 类型，代表一个 UTF-8 字符，当需要处理中文、日文或者其他复合字符时，则需要用到 rune 类型。rune 类型等价于 int32 类型。

```go
等效:
var ch byte = 65 或 var ch byte = '\x41'      //（\x 总是紧跟着长度为 2 的 16 进制数）
```


# 类型转换

go语言必须显式的声明进行类型转换

`valueOfTypeB = typeB(valueOfTypeA)`

如
```go
a := 5.0
b := int(a)
```

# 接口

```
/* 定义接口 */
type interface_name interface {
   method_name1 [return_type]
   method_name2 [return_type]
   method_name3 [return_type]
   ...
   method_namen [return_type]
}

/* 定义结构体 */
type struct_name struct {
   /* variables */
}

/* 实现接口方法 */
func (struct_name_variable struct_name) method_name1() [return_type] {
   /* 方法实现 */
}
...
func (struct_name_variable struct_name) method_namen() [return_type] {
   /* 方法实现*/
}
```

```go
package main
import (
    "fmt"
)
type Phone interface {
    call()
}
type NokiaPhone struct {
}
func (nokiaPhone NokiaPhone) call() {
    fmt.Println("I am Nokia, I can call you!")
}
type IPhone struct {
}
func (iPhone IPhone) call() {
    fmt.Println("I am iPhone, I can call you!")
}
func main() {
    var phone Phone

    phone = new(NokiaPhone)
    phone.call()

    phone = new(IPhone)
    phone.call()

}
```

# 附加

UTF-8和unicode有什么关系

unicode和ASCLL类似,都是一种字符集

UTF-8是一种编码规则.在utf-8中中文每个字符占用三个字节

