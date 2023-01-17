# 函数/方法

## 函数的定义

结构
```
func 方法名( [参数列表] ) [返回值类型] {
   逻辑处理
}
```
例如
```
func mulit100(val *int32) (bool,error){
   val=val*100
   return (true,errors.New("没有报错信息返回"))
}
```
参数列表和返回值类型不是必须的

## 函数的调用

```
返回值结果=函数名(参数列表)
```



# 内置函数

|名称	|说明|
|--|--|
|close	|用于关闭管道通信channel|
|len、cap	len |用于返回某个类型的长度或数量（字符串、数组、切片、map 和管道）；cap 是容量的意思，用于返回某个类型的最大容量（只能用于切片和 map）|
|new、make	|new 和 make 均是用于分配内存：new 用于值类型和用户定义的类型，如自定义结构,内建函数new分配了零值填充的元素类型的内存空间，并且返回其地址，一个指针类型的值。make 用于内置引用类型（切片、map 和管道）创建一个指定元素类型、长度和容量的slice。容量部分可以省略,在这种情况下,容量将等于长度。。它们的用法就像是函数，但是将类型作为参数：new(type)、make(type)。new(T) 分配类型 T 的零值并返回其地址，也就是指向类型 T 的指针）。它也可以被用于基本类型：v := new(int)。make(T) 返回类型 T 的初始化之后的值，因此它比 new 进行更多的工作,new() 是一个函数，不要忘记它的括号|
|copy、append|	copy函数用于复制,copy返回拷贝的长度，会自动取最短的长度进行拷贝(min(len(src), len(dst))),append函数用于向slice追加元素|
|panic、recover	|两者均用于错误处理机制,使用panic抛出异常，抛出异常后将立即停止当前函数的执行并运行所有被defer的函数，然后将panic抛向上一层，直至程序carsh。recover的作用是捕获并返回panic提交的错误对象、调用panic抛出一个值、该值可以通过调用recover函数进行捕获。主要的区别是，即使当前goroutine处于panic状态，或当前goroutine中存在活动紧急情况，恢复调用仍可能无法检索这些活动紧急情况抛出的值。|
|print、println	|底层打印函数|
|complex、real imag	|用于创建和操作复数,imag返回complex的实部,real返回complex的虚部|
|delete	|从map中删除key对应的value|

# 匿名函数

```go
func() {//定义一个匿名
    //func body
}() //花括号后加()表示函数调用，此处声明时为指定参数列表，
```