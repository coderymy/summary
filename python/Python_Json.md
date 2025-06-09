[](https://www.cnblogs.com/kylinxxx/p/16748045.html)



将Str转换成json对象

```
json.loads(str)
```

获取json对象中的节点

```python
somebody_info = '{"name": "Wenjie Ye", "age": 75, "nationality": "China"}'
json_text=json.loads(json.loads(str))
print(json_text['name'])
```

