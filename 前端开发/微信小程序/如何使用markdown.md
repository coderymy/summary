# 概述

首先了解两个东西

+ marked：将md解析成HTML语言
+ u-parse或者原生解析HTML语言成文本的工具

原理：在页面加载的时候向后台放松请求获取一个`markdown`的文本文件或者结果是`markdown`的响应体信息

比如：[文本文件](https://www.vvadd.com/wxml_demo/demo.txt?v=2)或者

```json
{"code":1,"msg":"成功","data":"# 问题\n\n答案\n\n> 解析\n\n","stime":1656326664105,"traceId":"83c7045b8e4747fa9f9ce8226e9166d7"}
```



然后使用marked的函数将这个文本信息解析成html语言。然后使用u-parse展示出来



# 实践

**第一步、引入marked插件：**

```
npm install marked
```

**第二步、引入`u-parse`：**

在Dcloud官网上搜索`uParse`然后直接点击使用`HbuilderX安装`

**第三步、使用插件：**

在vue项目中如下定义

```vue
<template>
	<view>
		<u-parse :content="article"></u-parse> 
	</view>
</template>
<script>
	import uParse from '@/components/u-parse/u-parse.vue'
	import {
		cardTest
	} from '@/config/api.js'
	var marked = require('marked');
	export default {
		data() {
			return {
				article: ''
			}
		},
		methods: {
			preview(src, e) {
				// do something
			},
			navigate(href, e) {
				// do something
			}
		},
		onLoad() {
			cardTest().then(res => {
				console.log(res),
					this.article = marked.parse(res)
			}).catch(() => {
				uni.showToast({
					title: this.errorNotice,
					duration: 2000
				});
			})
		}
	}
</script>
<style>
	@import url("@/components/u-parse/u-parse.css");
</style>

```

这里需要注意的有三个点

1. `<u-parse :content="article"></u-parse>`使用`u-parse`组件，并使用他的content属性进行赋值
2. `import uParse from '@/components/u-parse/u-parse.vue'`将uParse导入
3. `var marked = require('marked');`导入marked，下面使用的时候直接对str进行`this.article = marked.parse(res)`转换即可





# 坑点（未解决）

1. 这里的marked，一开始使用`import {marked} from 'marked'`导入不了，不知道为什么？
2. 如果使用了uview其本身就内置了一个uparse，就不需要单独引入一个解析的插件





# 简单的markdown（一级标题）

## 二级标题

测试一下代码

```java
public class testClass{
  private String name;
  private Integer id;
}
```

测试一下表格

| 属性 | 类型    | 名称 |
| ---- | ------- | ---- |
| id   | Integer | id   |
| name | String  | 名称 |

