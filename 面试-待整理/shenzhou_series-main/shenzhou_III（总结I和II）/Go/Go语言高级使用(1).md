# 1. 切片(slice)

相对于数组而言,其长度是可变的,可以使切片的容量变大,功能强悍的内置类型切片("动态数组")

**初始化切片**

```
1. var 切片名 []type =make([]type ,len)
var strArray []string=make([]string,3)

2. 切片名:=make([]type,len)
strArray=make([]string,len)

3. 切片名 :=[] type {val1,val2,val3}
strArray :=[] string{}

与数组的区别在于初始化的时候[]中不填入大小或者...
```

**新增元素**
array =append(array,新元素)

**复制切片**

copy(target,source)


**其他方法**

1. `len()`,获取当前切片的长度
2. `cap()`,获取当前切片设置的最大长度
3. 截取 `array[开始index:截止index]`.不包含开始节点和结束节点

# 范围(range)

结合切片使用,一般用来循环获取前片中的元素

```
    nums := []int{2, 3, 4}
    sum := 0
    for _, num := range nums {
        sum += num
    }
```
这样会便利nums中的所有元素一遍


# 集合Map

**初始化**
```go
var 变量名 map[key类型]value类型

变量名 :=make(map[key类型]value类型)
```

**赋值**

`变量名 [key1] =value1`

**删除**

`delete(map变量,map的key)`

```
delete(strMap,"cat")
```


# JSON
+ 序列化
  结构体->json
  []byte ,error=json.Marshal(v interface{})
+ 反序列化
  json->结构体
  json.Unmarshal(data []byte, v interface{})
  其中的v.传入一个参数的指针地址,这样结果就会直接赋值到这个v上

需要注意的是结构体中的成员名称,其首字母需要大写才能匹配上json串中的大/小写字符

序列化后的数据结构与json有以下类型映射
|go|json|
|--|--|
|bool   |  booleans|
|float64 | numbers|
|string  |strings|
|[]interface{} | arrays|
|map[string]interface{}  | objects|
|nil  |  null|

实例
```
package main

import (
	"encoding/json"
	"fmt"
)

const jsonStr = "{\"Servers\":[{\"serverName\":\"Shanghai\",\"serverIP\":\"127.0.0.1\"},{\"serverName\":\"Beijing\",\"serverIP\":\"127.0.0.2\"}]}"

type aaa struct {
	Servers []serverDetail
}

type serverDetail struct {
	ServerName string
	ServerIp string
}

func main() {
	var a aaa

	json.Unmarshal([]byte(jsonStr),&a)

	fmt.Println(a)
}
```