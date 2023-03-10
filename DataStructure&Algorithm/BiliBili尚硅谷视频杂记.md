[视频地址](https://www.bilibili.com/video/BV13g41157hK?p=3&vd_source=04583682dcfc081369a4ee11b5704aca)



先学习：动态规划算法、KMP算法、BM算法（后面两个是解决str的通用算法（最优））

# 经典算法

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/iKO0iC.png)

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/6CbKVE.png)

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/CGOjAn.png)

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/J0JiKJ.png)

理解，存粹的刷leetcode，所有的题目都是暴力破解的方法进行解决，这并不能算是算法解决问题。每道题其实都匹配其中的一种或多种算法，这样才是用算法去解决问题

# 线性结构和非线形结构

## 线性结构

分类：

+ 顺序存储结构
+ 链式存储结构

队列、数组、链表、栈



## 非线形结构

二维数组、多维数组、广义表、树结构、图结构



# 常用数据结构

## 稀疏数组

当一个数组中大部分元素为０，或者为同一个值的数组时，可以使用稀疏数组来保存该数组

存在目的：二维数组0占用空间，浪费空间，压缩就变成了稀疏数组

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/nPPxGi.png)

稀疏数组的处理方法是: 

1) 记录数组一共有几行几列，有多少个不同的值 
2) 把具有不同值的元素的行列及值记录在一个小规模的数组中，从而缩小程序的规模



![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/crH6RV.png)

```java
public class SparseArray {
    // 做到稀疏数组和二维数组之间的转换
    public static void main(String[] args) {
        int[][] array = new int[11][11];
        array[1][2] = 1;
        array[2][3] = 2;
        for (int[] row : array) {
            for (int item : row) {
                System.out.printf("%d\t", item);
            }
            System.out.println();
        }
        int[][] sparseArray = convertToSparse(array);

        covertToArray(sparseArray);

    }

    /**
     * 将二维数组转换成稀疏数组
     *
     * @param array 二维数组
     * @return 压缩后的稀疏数组
     */
    public static int[][] convertToSparse(int[][] array) {
        int sum = 0;
        for (int i = 0; i < array.length; i++) {
            for (int j = 0; j < array[i].length; j++) {
                if (array[i][j] != 0) {
                    sum++;
                }
            }
        }
        int[][] sparseArray = new int[sum + 1][3];
        sparseArray[0][0] = 11;
        sparseArray[0][1] = 11;
        sparseArray[0][2] = sum;
        int count = 0;
        for (int i = 0; i < array.length; i++) {
            for (int j = 0; j < array[i].length; j++) {
                if (array[i][j] != 0) {
                    count++;
                    sparseArray[count][0] = i;
                    sparseArray[count][1] = j;
                    sparseArray[count][2] = array[i][j];
                }
            }
        }


        for (int i = 0; i < sparseArray.length; i++) {
            System.out.printf("%d\t%d\t%d\t", sparseArray[i][0], sparseArray[i][1], sparseArray[i][2]);
            System.out.println();
        }
        return sparseArray;
    }

    /**
     * 将稀疏数组转换成二维数组
     *
     * @param sparseArray 稀疏数组
     * @return 解压缩后的二维数组
     */
    public static int[][] covertToArray(int[][] sparseArray) {
        int[][] array = new int[sparseArray[0][0]][sparseArray[0][1]];
        for (int i = 1; i < sparseArray.length; i++) {
            array[sparseArray[i][0]][sparseArray[i][1]] = sparseArray[i][2];
        }


        for (int[] row : array) {
            for (int item : row) {
                System.out.printf("%d\t", item);
            }
            System.out.println();
        }
        return array;
    }
}
```

## 队列

数组或链表实现

先进先出

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/wKD83h.png)

从上图可知

1、队列的四个基础要素：

+ 头指针，指向队列头的前一个数据
+ 尾指针，指向最后一个数据
+ 最大容量
+ 队列的存储结构（数组）

2、队列入队从尾部入队，出队是从头部出队

```java
/**
 * 数组实现队列
 */
class ArrayQueue {
    int maxSize;
    int front;
    int rear;
    int[] arr;
    //初始化
    public ArrayQueue(int maxSize) {
        this.maxSize = maxSize;
        this.front = -1;
        this.rear = -1;
        this.arr = new int[maxSize];
    }
    //入队，去除校验队列是否满的方法
    public void addQueue(int n) {
        this.rear++;
        arr[this.rear] = n;
    }
    //出队，去除校验队列是否空的方法
    public int outQueue() {
        front++;
        return arr[this.front];
    }
}
```

问题：但是这种队列是否问题的，数组每个节点使用一次就不能使用了。也就是明明最大maxSize，但是每个节点只能使用一次，之后即使取出来数据了也不能继续往里面增加数据。

解决方式：将数组转换成环形队列



## 环形队列

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/wKD83h.png)

重点理解以下几个概念

首先与之前不一样的是，front指向第一个数据，rear指向最后一个数据的下一个位置

1、如何判断队列是否满：(rear+1)%maxSize=front%maxSize（为什么，如果rear在front后面，那么rear+1只会小于等于maxSize，所以结果还是rear+1（也就是真实的那个位置index）。如果rear+1在front前面，取模还是会获取具体的index地址。所以这个时候就可以和front的位置进行比较）

2、数组有效数据的个数：(rear+maxSize-front)%maxSize

3、增加数据的时候，需要考虑取模的情况。也就是之前是rear++。现在是(rear+1)%maxSize



![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/LanUI3.png)



## 链表

笔记丢了，一直到线性查找二分查找，中间记录的笔记都找不到了



## 栈

```java
class ArrayStack {
    //数组大小
    int maxSize;
    //栈结构依赖的数组
    int[] stack;
    //栈顶指针
    int top;

    public boolean isFull() {
        if (maxSize == (top + 1)) {
            return true;
        }
        return false;
    }

    public void push(int val) {

    }
}

```



## 单链表

```java
public class SignleLinkedListDemo {
    public static void main(String[] args) {
        Node node1 = new Node(1, "小明");
        Node node2 = new Node(2, "小红");
        Node node3 = new Node(3, "小华");
        NodeList nodeList = new NodeList();
        nodeList.addByNo(node3);
        nodeList.addByNo(node1);
        nodeList.addByNo(node2);
        nodeList.list();
        System.out.println("反转之后");
        printRevernt(nodeList);
    }

    //逆序打印链表
    public static void printRevernt(NodeList nodeList) {
        Node headNode = nodeList.getHeadNode();
        Node temp = headNode.next;
        Stack<Node> stack = new Stack<>();
        while (true) {
            if (temp == null) {
                break;
            }
            stack.add(temp);
            stack.push(temp);
            temp = temp.next;
        }

        while (true) {
            if (stack.empty()) {
                break;
            }
            System.out.println(stack.pop());
        }
    }
}

class NodeList {
    //需要一个头节点，头节点不能动
    private Node headNode = new Node(0, "");

    public Node getHeadNode() {
        return headNode;
    }

    //添加节点的方法
    public void add(Node node) {
        Node temp = headNode;
        //遍历链表将新增的节点加到最后
        while (true) {
            if (temp.next == null) {
                temp.next = node;
                break;
            }
            temp = temp.next;
        }
    }


    //根据排名添加节点
    public void addByNo(Node node) {
        Node temp = headNode;
        //遍历链表将新增的节点加到最后
        while (true) {
            if (temp.next == null) {
                //表示只有头节点
                temp.next = node;
                break;
            }
            if (temp.next.no == node.no) {
                System.out.println("添加" + node + "失败");
                break;
            }
            //找到位置
            if (temp.next.no > node.no) {
                //将该节点的next指向新节点，然后新节点的next指向之前的next节点
                Node oldNextNode = temp.next;
                temp.next = node;
                node.next = oldNextNode;
                break;
            }
            temp = temp.next;
        }
    }


    //遍历节点
    public void list() {
        if (headNode.next == null) {
            System.out.println("链表为空");
        }
        Node temp = headNode.next;
        while (true) {
            System.out.println(temp);
            if (temp.next == null) {
                break;
            }
            temp = temp.next;
        }
    }
}

//重点在于有一个属性next类型也是Node
class Node {
    int no;
    String name;
    Node next;

    public Node(int no, String name) {
        this.no = no;
        this.name = name;
    }

    @Override
    public String toString() {
        return "Node{" +
                "no=" + no +
                ", name='" + name + '\'' +
                '}';
    }
}
```

环形链表

```java
class NodeCricelLinkedList {


    private NodeCircle headNode = new NodeCircle(1, "");

    //根据排名添加节点
    public void addByNo(NodeCircle node) {
        if (headNode.next == null) {
            headNode = node;
            headNode.next = headNode;
        }
        NodeCircle temp = headNode.next;
        while (true) {
            if (temp.no < node.no) {
                //

                if (temp.next.no>node.no);

            } else if (temp.no == node.no) {
                System.out.println("插入失败");
                break;
            } else {
                //插入前面

            }
        }


        //遍历链表将新增的节点加到最后
        while (true) {
            if (temp.next == null) {
                //表示只有头节点
                temp.next = node;
                break;
            }
            if (temp.next.no == node.no) {
                System.out.println("添加" + node + "失败");
                break;
            }
            //找到位置
            if (temp.next.no > node.no) {
                //将该节点的next指向新节点，然后新节点的next指向之前的next节点
                NodeCircle oldNextNode = temp.next;
                temp.next = node;
                node.next = oldNextNode;
                break;
            }
            temp = temp.next;
        }
    }
}


class NodeCircle {
    int no;
    String name;
    NodeCircle next;

    public NodeCircle(int no, String name) {
        this.no = no;
        this.name = name;
    }

    @Override
    public String toString() {
        return "NodeCircle{" +
                "no=" + no +
                ", name=" + name +
                '}';
    }
}
```







## 递归

```java
public class RecursionDemo {

    //迷宫问题
    public static void main(String[] args) {
        int[][] map = initArray();
        System.out.println("================");
        if (setWay(map, 1, 1)) {
            printMap(map);
        }
    }
    public static int[][] initArray() {
        int[][] map = new int[8][7];
        for (int i = 0; i < 7; i++) {
            map[0][i] = 1;
            map[7][i] = 1;
        }
        for (int i = 0; i < 8; i++) {
            map[i][0] = 1;
            map[i][6] = 1;
        }
        map[3][1] = 1;
        map[3][2] = 1;
        printMap(map);
        return map;
    }
    public static void printMap(int[][] map) {
        for (int i = 0; i < 8; i++) {
            for (int j = 0; j < 7; j++) {
                System.out.print(map[i][j] + " ");
            }
            System.out.println();
        }
    }

    /**
     * 规定：
     * 1、map[i][j]的值 0表示未走过该条路 1表示墙 2表示这条路走过了 3表示此路不通
     * 2、右下左上的顺序探路
     *
     * @param map 地图
     * @param i   要走的i
     * @param j   要走的j
     * @return
     */
    public static boolean setWay(int[][] map, int i, int j) {
        if (map[6][5] == 2) {
            //说明已经到达重点了
            return true;
        } else {
            if (map[i][j] == 0) {
                map[i][j] = 2;
                //没有走过这条路，所以可以探路试试
                if (setWay(map, i, j + 1)) {
                    //返回true说明可以走
                    return true;
                }
                if (setWay(map, i + 1, j)) {
                    //返回true说明可以走
                    return true;
                }
                if (setWay(map, i, j - 1)) {
                    //返回true说明可以走
                    return true;
                }
                if (setWay(map, i - 1, j)) {
                    //返回true说明可以走
                    return true;
                }
                map[i][j] = 3;
                //上下左右都不能走
                return false;
            } else {
                //该点不为0，就是1、2、3。1表示墙，所以不能走；2表示该条路已经走过了，再走下去也没意义了；3表示该条路是不通的，不能走
                return false;
            }
        }
    }

}

```



# 排序

## 桶排序

```java
public class BubbleSortDemo {


    public static void main(String[] args) {
        int arr[] = {3, 9, -1, 10, -2};
        //一共需要size-1趟排序，每趟需要比较(size-当前次数)次比较
        int arrSize = arr.length;
        for (int i = 0; i < arrSize - 1; i++) {
            boolean flag = false;
            //需要多少趟排序
            for (int j = 0; j < arrSize - 1 - i; j++) {
                //比较当前数字和后面的数字的大小
                if (arr[j] <= arr[j + 1]) {
                    int tmp = arr[j + 1];
                    arr[j + 1] = arr[j];
                    arr[j] = tmp;
                    flag = true;
                }
            }
            //加一个flag判断当前这趟排序是否进行过交换，如果没有交换过就说明已经是有序的
            if (!flag) {
                break;
            }
            flag = false;
        }

        System.out.println(Arrays.toString(arr));
    }


}

```



## 快速排序

```java

```



## 选择排序

```java
    public static void main(String[] args) {
        int arr[] = {101, 34, 119, 1};
        for (int i = 0; i < arr.length - 1; i++) {
            //进行多少轮选择
            int min = arr[i];
            int minIndex = i;
            for (int j = i + 1; j < arr.length; j++) {
                //依次与后面的数据进行比较
                if (arr[j] < min) {
                    min = arr[j];
                    minIndex = j;
                }
            }
            //将当前位置的数据与对应下标的数据进行交换
            int tmp = arr[i];
            arr[i] = min;
            arr[minIndex] = tmp;
        }
        System.out.println(Arrays.toString(arr));
    }
```









## 排序算法总结

1、快速排序：找到一个中间值，然后将大于放在右边，小于放在左边。然后再递归对两边分别进行快排

2、选择排序：从前往后，取一个数字比较，如果后面的数字比当前小就替换。最后比较完了之后将该数字放在最前面（每次确定最前面的一个数字是当前最小的，下一次就可以从前面少比较一个数字）

3、冒泡排序：从前往后依次比较相邻的两个数的大小，如果不符合顺序就替换位置。一直比较（每轮比较都能得到一个最大值，下一次就可以少比较一个数）

4、插入排序：依次从数据中取出来一个数字，与下面设定的有序表的从前往后遍历比较，当大于当前位置且小于下一位置的时候，就放在这个地方

5、归并排序：分治思想。先分，取mid将数据分成两边，然后两边继续分，直到都是单独的一个数字；再治，依次比较每组数据（采用两个指针的方式比较数字，当一组数字比较完另外一组直接放在当前tmp数组后面）

6、基数排序：桶排序的变形，设置0-9十个桶，按照每个数字的从小往大的位数放置在每个桶中，每轮确定一个位数。

# 查找算法

## 二分查找

思想：首先数据是有序的。每次找到中间数值，比较要查找的数大小。小往前找，大往后找

步骤：

1、找到mid=(left+right)/2

2、比较查找数与mid的大小，选择对应要去找的地方（前还是后）

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/Ypdl30.png)



结束递归：

1、找到了结束

2、递归完整个数组，没有这个值。left>right

```java
//二分查找需要数组是有序的
    public static void main(String[] args) {
        int arr[] = {1, 8, 10, 89, 1000, 1222};
        System.out.println(binarySearch(arr, 0, arr.length, 1222));
    }

    /**
     * 很多有效性判断没加上
     *
     * @param arr     要遍历的数组
     * @param left    左边接（递归）
     * @param right   右边界（递归）
     * @param findVal 要查找的值
     * @return
     */
    public static int binarySearch(int[] arr, int left, int right, int findVal) {
        int mid = (left + right) / 2;
        if (arr[mid] > findVal) {
            //向左查找
            return binarySearch(arr, left, mid - 1, findVal);
        } else if (arr[mid] < findVal) {
            //向右查找
            return binarySearch(arr, mid + 1, right, findVal);
        } else if (arr[mid] == findVal) {
            return mid;
        }
        return mid;
    }
```

重点记住

```java
public static int binarySearch(int[] arr, int left, int right, int findVal)
```

## 插值查找

二分查找没有最优和最坏。查找次数是根据数据大小一定的。所以如果是对于正态分布的数据，本质看起来很简单但是查找次数也很大



原理： 插值查找相对于二分，只是每次获取mid的方式不同。

二分是(left+right)/2=left+(right-left)/2/

插值是left+(findVal-arr[left])/(arr[right]-arr[left])*(right-left)

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/isrmdm.png)

目的就是将值（顺序）参与到运算中

## 斐波那契/黄金分割

黄金分割点：分割之后一部分比上另外一部分=0.618

斐波那契数列：后面的数值=前面两个数值相加（越往后前面的数值比上后面的数值无限趋近于0.618）{1,1,2,3,5,8,13,21}

斐波那契查找算法原理：和前面的二分一样，只是mid的取值是使用黄金分割点=left+F(k-1)-1

F(k-1)-1

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/KmfG65.png)



# 数据结构

## 哈希表

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/e7oXWj.png)

HashTable、HashMap的底层实现就是哈希表

