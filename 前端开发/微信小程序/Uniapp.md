# 1. Uni-app基础

+ js、html、css都在一个文件中

  ```js
  <template>
  	<view>
  	</view>
  </template>
  <script>
  	export default {
  		data() {
  			return {
  			}
  		},
  		methods: {
  		}
  	}
  </script>
  <style>
  </style>
  ```

+ 组件标签靠近小程序规范

  ```
  <template>
  	<view></view>
  	<view></view>
  </template>
  ```

+ API接口规范

  ```
  uni.request({
      url: 'request/login', //仅为示例，并非真实接口地址。
      success: (res) => {
          console.log(res.data);
          // 打印： {code:1,...}
      }
  });
  ```

+ 数据绑定和事件处理

  ```js
  <template>
  	<view @click="changeMsg" value="msg">{{msg}}</view>
  </template>
  ```

特色：

+ 条件编译，针对只有满足的端才能编译

  可以写在js或者css等文件中

  ```
  #ifdef H5||MP_WEIXIN
  xxx
  #endif
  ```

+ APP端食用nvue页面，会使用原生渲染，提升性能

+ HTML5+

  内置了HTML5+引擎，比如一些安卓、IOS的具体插件

项目构建方式：

1. HBuilderX创建
2. 使用vue-cli创建

目录结构：

```
pages    存放页面的地方
static   存放静态资源的目录
App.vue    Vue的入口文件，有项目的生命周期函数，也可以写一些全局的样式
main.js    注册一些插件、注册Vue等
mainfest.json   针对不同的平台对不同的平台进行配置的页面
pages.json    项目的配置信息，可以在文档-配置中找到所有配置参数
uni.scss     可以写一些全局的变量，比如全局颜色切换等


自定义的目录

common   存放公共的文件
components    存放组件
store   vuex目录（本地缓存）
unpackage    打包发行的目录，生成的对应的编译后文件
```



# 2. Uni-app学习项目

## 2.1 基础组件和自定义组件

### 基础组件

`<view>`会换行

`<text>`不会换行

[官方文档](https://uniapp.dcloud.net.cn/component/)

### 自定义组件

1. 创建目录components
2. 创建组件，同时创建目录
3. 引入组件：直接在template中写入组件`<xxx></xxx>`：这个要求就要求不需要在components中创建了同名目录的文件。否则需要手动引入

#### 父子组件通讯

**组件数据传输**：比如不同的地方使用这个组件展示不同的颜色。就需要在调用的时候将这个颜色传给子组件

```
1. 创建组件的时候，script中有一个pops的信息，和data一样的结构。用来接受外部传入的属性

2. 使用组件时候，直接在组件的属性上使用
```

```js
<template>
	<view>
		<text :style="{background: color}">我爱吃蛋炒饭</text>
	</view>
</template>
<script>
	export default {
		name:"card",
		props:{
			color:{
				type: String,
				default:'red'
			}
		},
		data() {
			return {
				
			};
		}
	}
</script>
```



```js
<template>
	<view class="content">
		<card color="yellow"></card>
	</view>
</template>

<script>
	export default {
		data() {
			return {
			}
		},
		methods: {

		}
	}
</script>
```

**自定义组件方法调用传入参数**

点击子组件，去触发父组件的方法

1. 子组件也有点击方法

2. 父组件也有点击方法

3. 子组件的点击方法中去调用父组件的点击方法

   `this.$emit('父组件方法名')`

4. 同时如果需要进行子组件向父组件传值，也可以在`this.$emit('父组件方法名',xxxx)`的第二个参数xxx处赋值。然后在父组件的方法处进行数据接收

```
# 子组件
<template>
	<view>
		<text @click="clickZ">我爱吃蛋炒饭</text>
	</view>
</template>
<script>
	export default {
		name:"card",
		data() {
			return {
			};
		},
		methods: {
			clickZ() {
				console.log('点击了子组件')
				this.$emit('fClickName')
			}
		},
	}
</script>


# 父组件
<template>
	<view class="content">
		<!-- 注意@后面的名称才是子组件需要this.$emit('')中的参数。然后clickF是父组件中要调用的方法 -->
		<card @fClickName="clickF"></card>
	</view>
</template>

<script>
	export default {
		data() {
			return {}
		},
		methods: {
			clickF() {
				console.log('点击了父组件')
			}
		}
	}
</script>
```



将父组件调用子组件的时候其中的值传入子组件显示。使用插槽

```js
父组件调用子组件的时候
<card>我要在子组件中显示出来</card>

子组件显示的时候
<view>
	<slot></slot>  
</view>
```





总结：

1. uniapp使用规范的创建组件方式可以直接在别的地方引入组件而不需要import
2. 父组件向子组件传递数据，使用props
3. 子组件向父组件传递数据，父组件创建自定义事件，子组件使用emit触发父组件自定义事件在参数中传递数据
4. 使用插槽在子组件中显示父组件调用的输出数据

## 2.2 API：网络请求

[官方文档](https://uniapp.dcloud.net.cn/api/)

### Toast提示

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/RWOwCS.png)



### 路由：页面跳转等

tarber的跳转使用`uni.switchTab`

+ uni.navigateTo 保留当前页面，跳转到应用内的某个页面
+ uni.redirectTo 关闭当前页面，跳转到应用内的某个页面 被关闭的页面，点击返回按钮不会返回这个页面
+ uni.reLaunch 关闭所有页面，打开到应用内的某个页面。
+ uni.switchTab跳转到 tabBar 页面，并关闭其他所有非 tabBar 页面。
+ uni.navigateBack关闭当前页面，返回上一页面或多级页面。
+ uni.preloadPage 预加载页面，是一种性能优化技术。被预载的页面，在打开时速度更快。



## 2.3 生命周期

> 应用的生命周期

App.vue

<script>
	export default {
    //应用初始化完成执行一次，全局只会执行一次。一般在这个地方进行一些登陆的处理
		onLaunch: function() {
			console.log('App Launch')
		},
    //应用显示的时候，从后台进入前台
		onShow: function() {
			console.log('App Show')
		},
    //应用隐藏的时候，从前台进入后台
		onHide: function() {
			console.log('App Hide')
		}
	}
</script>

> 页面的生命周期

```js
	//页面初次加载的时候触发
	onLoad(){
		
	},
	//页面加载完成的时候触发
	onReady(){
		
	},
	//页面显示的时候触发
	onShow(){
		
	},
	//页面隐藏的时候触发
	onHide(){
		
	}
	//页面卸载的时候触发
	onUnload(){
		
	}
```



> 组件的生命周期

[官网](https://uniapp.dcloud.net.cn/tutorial/page.html#nvue-%E5%BC%80%E5%8F%91%E4%B8%8E-vue-%E5%BC%80%E5%8F%91%E7%9A%84%E5%B8%B8%E8%A7%81%E5%8C%BA%E5%88%AB)

| 函数名        | 说明                                                         | 平台差异说明 | 最低版本 |
| :------------ | :----------------------------------------------------------- | :----------- | :------- |
| beforeCreate  | 在实例初始化之前被调用。[详见(opens new window)](https://cn.vuejs.org/v2/api/#beforeCreate) |              |          |
| created       | 在实例创建完成后被立即调用。[详见(opens new window)](https://cn.vuejs.org/v2/api/#created) |              |          |
| beforeMount   | 在挂载开始之前被调用。[详见(opens new window)](https://cn.vuejs.org/v2/api/#beforeMount) |              |          |
| mounted       | 挂载到实例上去之后调用。[详见 (opens new window)](https://cn.vuejs.org/v2/api/#mounted)注意：此处并不能确定子组件被全部挂载，如果需要子组件完全挂载之后在执行操作可以使用`$nextTick`[Vue官方文档(opens new window)](https://cn.vuejs.org/v2/api/#Vue-nextTick) |              |          |
| beforeUpdate  | 数据更新时调用，发生在虚拟 DOM 打补丁之前。[详见(opens new window)](https://cn.vuejs.org/v2/api/#beforeUpdate) | 仅H5平台支持 |          |
| updated       | 由于数据更改导致的虚拟 DOM 重新渲染和打补丁，在这之后会调用该钩子。[详见(opens new window)](https://cn.vuejs.org/v2/api/#updated) | 仅H5平台支持 |          |
| beforeDestroy | 实例销毁之前调用。在这一步，实例仍然完全可用。[详见(opens new window)](https://cn.vuejs.org/v2/api/#beforeDestroy) |              |          |
| destroyed     | Vue 实例销毁后调用。调用后，Vue 实例指示的所有东西都会解绑定，所有的事件监听器会被移除，所有的子实例也会被销毁。[详见](https://cn.vuejs.org/v2/api/#destroyed) |              |          |

```js
		// 实例初始化之后 数据观测（data observer）和event/watcher事件配置之前执行
		beforeCreate(){
			
		},
		//数据观测（data observer）和event/watcher事件配置之后，但是还没挂载
		created(){
			
		},
		//实例挂载之后执行
		mounted(){
			
		}
```





## 2.4 语法

> v-bind，数据绑定

给组件的属性赋予data中的值、属性中需要写入表达式（`<view v-bind:value="true?'对的':'错的'"></view>`）。

比如给image的src赋予从后端获取的值

```
<image v-bind:src="userInfo.headImg"></image>
```

比如切换主题颜色class属性赋予不同的颜色值

```
<view v-bind:class="theme"></view>
可以直接简写成:
<view :class="theme"></view>
```

### 数据绑定

> {{msg}}，数据绑定

在组件的括号内使用来调用data中的值

> 方法中修改数据

小程序需要使用this.setdata才能访问data中的数据。

uniapp中直接使用this就可以访问

```js
onLoad(){
  setTimeout(()=>{
    this.msg="x x x"
  },2000)
}
```

> v-model

双向数据绑定，主要应用于在进行表单数据同步的情况下进行使用

### 事件绑定

> v-on，事件绑定

v-on:click表示点击事件

v-on:tap覆盖事件等

```
<button v-on:click="clickMe"></view>

clickMe为method中的方法

可以直接简写成@
<button @click="clickMe"></view>


<button @click="flag= !flag">点击去修改flag</button>
```



**事件穿透**

```html
<view @click="c1">
  父组件
	<view @click="c2">子组件</view>
</view>

此时点击子组件的时候，父组件也会被惦记触发

解决办法，不想影响到外层就在子组件上加上stop
<view @click="c1">
  父组件
	<view @click.stop="c2">子组件</view>
</view>
```

### 条件判断

> v-if

条件判断，只有为true的时候该区块或者内容才显示

```
<view v-if="a==1">1的时候显示我</view>
<view v-else-if="a==2">2的时候显示我</view>
<view v-else>其他情况的时候显示我</view>
```

> v-show

show和if的区别：

+ 在于if是false的时候根本没有组件。

+ show只是不显示而已

> Block 空标签

也就是不想要外层标签，但是想要用if来判断显不显示内部的标签信息

```html
<block v-if="rlag">
	<view>a</view>
  <view>b</view>
</block>
```

此时显示的时候实际上是没有block标签的

view中的空标签是template

### 循环

循环数组

```html
<view v-for="item in arr">
	{{item.xxx}}
</view>

<view v-for="(item,index) in arr">
{{index}}:{{item.xxx}}
</view>
```

循环对象

```html
<view v-for="(value,key) in person">
	{{key}}:{{value}}
</view>

person:{
	name:"tom",
	age: 22
}



sout:
name:tom
age:22
```



循环操作的时候如果不想要外层的标签就可以使用block

## 2.5 页面布局样式

约束：template内层只能有一个view

如果使用scss，则需要在`<style lang="scss"></style>`



引入外部样式表：在`<style>`标签中，使用@import '路径'来引入



















# 开发小程序

[简单了解——大佬](https://www.jianshu.com/p/d98050a57949)

Uniapp在开发H5的时候支持所有Vue语法，但是在开发小程序和app的时候只支持部分的vue语法

使用`<view>`替换`<div>`

uniApp开发的小程序，在微信小程序软件中运行的时候

+ 可以在“运行”->运行到小程序->微信开发者工具中直接使用（前提是配置好了微信的开发者工具的app目录）
+ 可以将目录中的`unpackage/dist/dev`这个项目直接在微信小程序中直接打开



Hbuilderx官网

https://www.dcloud.io/hbuilderx.html

微信开发者工具下载

https://developers.weixin.qq.com/miniprogram/dev/devtools/download.html

问题：无法在Hbuildx中启动小程序

解决：在微信开发者工具中设置打开安全端口即可

![img](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/Z1VYD3.jpg)

uniapp官方文档

https://uniapp.dcloud.net.cn/collocation/pages.html

颜色参考网站

http://xh.5156edu.com/page/z1015m9220j18754.html

安装uni-ui组件库

https://ext.dcloud.net.cn/plugin?id=55

问题：uniapp启动小程序出现错误

![img](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/PcAo7S.jpg)



解决：在uniapp中配置 wxid即可

可以使用测试号：wx181cc686ca3cdee7

![img](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/kxtR7p.jpg)



问题：配置微信小程序请求后台接口

解决：在详情中配置勾选不校验域名

![img](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/Btikk7.jpg)



