# ptr
go中的指针有两个核心概念
+ 类型指针,允许对这个指针类型的数据进行修改，传递数据可以直接使用指针，而无须拷贝数据，类型指针不能进行偏移和运算。
+ 切片,由指向起始元素的原始指针、元素数量和容量组成。

指针地址和指针类型
+ 指针地址,每个指针变量,**其中存储的就是这个值的内存地址**.也就是说,这个内存地址在32位机和64位机上分别占用4个字节和8个字节的空间,这个空间大小和这个值没关系
+ 指针类型,



**获取指针地址"&"**

ptr := &aaa

其中aaa是一个值,ptr就是赋值后的指针参数

**获取指针的值"*"**

str := *ptr

使用*获取指针中指向的那个值的内容

## 给指针赋值和获取指针的值
```
package main
import "fmt"
func main() {

	var cat string = "我爱蛋炒饭"

	catAddress := &cat

	catValue := *catAddress

	fmt.Println("", &cat, catAddress, catValue)
}

 0x14000010240 0x14000010240 我爱蛋炒饭
```

取地址操作符&和取值操作符*是一对互补操作符，&取出地址，*根据地址取出地址指向的值。

# 修改指针的值

```
package main

import "fmt"

func main() {

	var cat string = "我爱蛋炒饭"
	catAddress := &cat
	catValue := *catAddress
	fmt.Println("", &cat, catAddress, catValue)

	a:=1
	b:=2
	swap(&a,&b)
	fmt.Println("",a,b)
}

func swap(a, b *int) {
	t := *a
	*a = *b
	*b = t
}

```

## 另一种创建指针的方式

`new (类型)`

```
aaa :=new (string)

*aaa="我爱蛋炒饭"

fmt.Println(*str)

```



# 指针的使用场景

1. 直接对指针指向的地址操作,可以最完全的改变这个参数的值信息,所以可以用在方法的传递上,直接方法的入参传入一个参数的指针类型,这个参数在这个方法中的修改.会导致调用方也修改
	所以一般函数的参数列表都是以`*xxx`来做为参数传递的


```go
package main

import (
	"errors"
	"fmt"
)

func testMap(strs *[]string) (bool, error) {

	for _, str := range *strs {

		fmt.Println(str)
	}
	*strs = append(*strs, "小黑")
	return true, errors.New("没有错误结果信息")

}

func main() {
	strs := []string{"小白", "小红", "小蓝"}
	b, err := testMap(&strs)

	fmt.Printf("", b, err)
	fmt.Printf("", strs)
}

```