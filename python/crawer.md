1、转换soup对象

```
    soup = BeautifulSoup(html, "html.parser")
```

2、使用class标签/Id标签获取集合

```
soup.select(".class")[0]

soup.select("#id")[0]
```

3、获取标签中的属性值

```
item["href"]
```

4、找到当前节点下所有xxx标签

```
soup.find_all("img")
```

5、pycharm下载python的包

Preferences-Project:xxx-Python Interpreter-"+"-搜索，下载即可

6、python转html到markdown

```
import html2text

markdown_text=html2text.html2text(html)
```

需要注意的是，需要按照html2text这个库的约束去设置html文件。比如img只识别src标签，其他的链接属性没有用

7、统计文件夹中文件的个数

```
ls -l |grep '^-'|wc -l
```
