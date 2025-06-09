https://www.cnblogs.com/auguse/articles/17361774.html





# key的数据结构

使用hashtable+链表的结构

当数据量超过hashtable的数组时就会进行扩容。同时使用渐进式rehash的方式将每个hash槽的数据重新放到新的数组中去。

渐进式rehash包括主动访问和被动轮询。在扩容rehash期间会进行两次访问，先访问老的再访问新的

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo%E5%BE%AE%E4%BF%A1%E6%88%AA%E5%9B%BE_20240418231617.png)