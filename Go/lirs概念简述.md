# 是什么？

go语言本身携带的NET/HTTP标准库，并不能满足一个web应用程序开发的需要，所以就需要有一个类似于`springMVC`封装了`servlet`的web曾框架来支持

# 安装

lris只是一个go的一个包，在进行`go mod`包管理下，可以使用`go get -u github.com/kataras/iris`命令直接下载


# 启动端口监听

调用app.Run()给定参数为`http.Server`实例

app.Run(iris.Addr(":8080"))



```go
package main

import "github.com/kataras/iris"

func main() {
    app := iris.New()
    app.Get("/", func(ctx iris.Context){})
    app.Run(iris.Addr(":8080"))
}
```
# 注册接口

在调用`app.Run()`方法之前，需要将需要注册的接口绑定到这个要启动的app上

第一种方式：

app.Handle("","",func())


+ 第一个参数：**请求方式**GET/POST
+ 第二个参数：**路由路径**，访问的接口，默认从`localhost:port`开始拼接
+ 第三个参数：**个或者多个 iris.Handler**

```go
app := iris.New()

app.Handle("GET", "/contact", func(ctx iris.Context) {
    ctx.HTML("<h1> Hello from /contact </h1>")
})

app.Run(iris.Addr(":8080"))
```




# 实例：

```go

package main

//导入包
import (
	"github.com/kataras/iris"

	"github.com/kataras/iris/middleware/logger"
	"github.com/kataras/iris/middleware/recover"
	"github.com/kataras/iris/mvc"
)

//可执行方法
func main() {

    //创建要启动的app
	app := iris.New()
	//给定需要启动的项目参数
	app.Use(recover.New())
	app.Use(logger.New())
    //注册所有启动的接口参数
	mvc.New(app).Handle(new(ExampleController))

    
	// http://localhost:8080
	// http://localhost:8080/ping
	// http://localhost:8080/hello
	app.Run(iris.Addr(":8080"))
}

// ExampleController serves the "/", "/ping" and "/hello".
type ExampleController struct {}

// Get serves
// Method:   GET
// Resource: http://localhost:8080
func (c *ExampleController) Get() mvc.Result {
	return mvc.Response{
		ContentType: "text/html",
		Text:        "<h1>Welcome</h1>",
	}
}

// GetPing serves
// Method:   GET
// Resource: http://localhost:8080/ping
func (c *ExampleController) GetPing() string {
	return "pong"
}

// GetHello serves
// Method:   GET
// Resource: http://localhost:8080/hello
func (c *ExampleController) GetHello() interface{} {

	return map[string]string{"message": "Hello Iris!"}
}


```


请求的参数路径可以使用方法名来代替。例如GetHello表示，使用的是Get方式请求`/hello`接口