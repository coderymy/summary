<font size='64' color='green'>链表</font>



# 基础知识

[代码随想录](https://programmercarl.com/%E9%93%BE%E8%A1%A8%E7%90%86%E8%AE%BA%E5%9F%BA%E7%A1%80.html#%E9%93%BE%E8%A1%A8%E7%9A%84%E7%B1%BB%E5%9E%8B)

## 链表类型

- 单链表

  ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20200806194529815.png)

  一个指针域一个数据域，head节点也是一个数据节点

- 双向链表

  ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20200806194559317.png)

  两个指针域一个数据域，头节点为null

- 循环链表

  ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20200806194629603.png)



## 存储方式

不连续分布

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20200806194613920.png)





## 链表的操作

### 删除节点

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20200806195114541-20230310121459257.png)

### 添加节点

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20200806195134331-20230310121503147.png)

## 构建链表

核心在于，一个数据域和一个指针域

```java
public class ListNode {
    // 结点的值
    int val;

    // 下一个结点
    ListNode next;

    // 节点的构造函数(无参)
    public ListNode() {
    }

    // 节点的构造函数(有一个参数)
    public ListNode(int val) {
        this.val = val;
    }

    // 节点的构造函数(有两个参数)
    public ListNode(int val, ListNode next) {
        this.val = val;
        this.next = next;
    }
}
```





# 基础代码

单节点的结构，单节点增加节点，单节点输出

```java
public class ListNode {

    int val;
    ListNode next;

    public ListNode() {
    }

    public ListNode(int val) {
        this.val = val;
    }

    public ListNode(int val, ListNode next) {
        this.val = val;
        this.next = next;
    }


    public static ListNode convertToListNode(List<Integer> list) {
        ListNode headNode = new ListNode();
        addNext(0, headNode, list);
        return headNode.next;
    }

    public static ListNode addNext(Integer index, ListNode listNode, List<Integer> list) {
        if (index >= list.size()) {
            return null;
        }
        Integer val1 = list.get(index);
        ListNode listNode1 = new ListNode(val1);
        listNode.next = listNode1;
        addNext(++index, listNode1, list);
        return listNode1;
    }

    public static void printLinkNode(ListNode listNode) {
        System.out.printf(String.valueOf(listNode.val));
        if (listNode.next != null) {
            System.out.printf(",");
            printLinkNode(listNode.next);
        }
    }
}

```



# 删除节点

需要注意的有以下几点

1. 对于头节点的移除
   1. 设置虚拟头节点处理，最后返回的时候返回headNode.next
   2. 针对头节点的删除单独处理。移动头节点至下一个节点
   3. 递归
2. 内存释放
3. 当前检查的应该是当前节点的下一个节点，这样的话。当下一个节点与数据一致，则**节点指针不动**，下一个节点赋予下下一个节点



题目：

> 给你一个链表的头节点 head 和一个整数 val ，请你删除链表中所有满足 Node.val == val 的节点，并返回 新的头节点 。
>
> ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20250124142219.png)
>
> ```
> 输入：head = [1,2,6,3,4,5,6], val = 6
> 输出：[1,2,3,4,5]
> ```
>
> **示例 2：**
>
> ```
> 输入：head = [], val = 1
> 输出：[]
> ```
>
> **示例 3：**
>
> ```
> 输入：head = [7,7,7,7], val = 7
> 输出：[]
> ```

```java
/**
     * 给你一个链表的头节点 head 和一个整数 val ，请你删除链表中所有满足 Node.val == val 的节点，并返回 新的头节点 。
     * 输入：head = [1,2,6,3,4,5,6], val = 6
     * 输出：[1,2,3,4,5]
     *
     * @param args
     */
    public static void main(String[] args) {
        Integer[] ints = {6, 6, 6, 6};
        List<Integer> list = Arrays.asList(ints);
        ListNode listNode = ListNode.convertToListNode(list);
        ListNode listNode1 = removeElements(listNode, 6);
        ListNode.printLinkNode(listNode1);
    }


    public static ListNode removeElements(ListNode head, int val) {
        while (head != null && head.val == val)
            //头节点为val
            head = head.next;

        if (head == null) return null;
        ListNode curNode = head;
        while (true) {
            if (curNode.next == null) {
                break;
            }
            if (curNode.next.val == val) {
                curNode.next = curNode.next.next;
            } else {
                curNode = curNode.next;
            }
        }
        return head;
    }
```



# 算法题

## 总结

该类型题目无非几种解题思路

1. 哈希表
2. 快慢指针
3. 模拟

其中模拟类型的题目最多，此类题目需要熟知链表的结构。包括单链表、双链表、环形链表



其中链表由于头节点的特殊性，所以在解一些问题的时候，可以针对头节点设置**虚拟头节点**

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20250129145044.png)

## 设计链表

- 获取链表第index个节点的数值
- 在链表的最前面插入一个节点
- 在链表的最后面插入一个节点
- 在链表第index个节点前面插入一个节点
- 删除链表的第index个节点

```java
package linkedList;

import java.util.Arrays;
import java.util.List;

/**
 * @author coderymy
 * @date 2025/1/24 17:31
 */
public class MyLinkedList {

    public static LinkNode convertToLinkNode(List<Integer> list) {
        LinkNode headNode = new LinkNode();
        addNext(0, headNode, list);
        return headNode.next;
    }

    public static LinkNode addNext(Integer index, LinkNode LinkNode, List<Integer> list) {
        if (index >= list.size()) {
            return null;
        }
        Integer val1 = list.get(index);
        LinkNode LinkNode1 = new LinkNode(val1);
        LinkNode.next = LinkNode1;
        addNext(++index, LinkNode1, list);
        return LinkNode1;
    }

    public static void printLinkNode(LinkNode LinkNode) {
        System.out.printf(String.valueOf(LinkNode.val));
        if (LinkNode.next != null) {
            System.out.printf(",");
            printLinkNode(LinkNode.next);
        }
    }


    public static void main(String[] args) {
        MyLinkedList linkedList = new MyLinkedList();
//        linkedList.addAtHead(1);
//        linkedList.addAtTail(3);
//        linkedList.addAtIndex(1, 2);
//        System.out.printf(String.valueOf(linkedList.get(1)));
        linkedList.deleteAtIndex(0);
        System.out.printf(String.valueOf(linkedList.get(1)));
    }


    /**
     * 头节点
     */
    LinkNode head;

    int size;

    public MyLinkedList() {
        this.head = null;
        size = 0;
    }

    public MyLinkedList(LinkNode linkNode) {
        this.head = linkNode;
        size = getSize();
    }

    public int get(int index) {
        if (index >= getSize())
            return -1;
        int curIndex = 1;
        if (index == 0)
            return head.val;

        LinkNode curNode = head.next;
        while (true) {
            if (curNode == null)
                return -1;
            if (curIndex == index) {
                return curNode.val;
            } else {
                curNode = curNode.next;
                curIndex++;
            }
        }
    }

    public void addAtHead(int val) {
        LinkNode linkNode = new LinkNode(val);
        if (head == null) {
            head = linkNode;
            return;
        }
        linkNode.next = head;
        head = linkNode;
    }

    public void addAtTail(int val) {
        if (head == null) {
            addAtHead(val);
            return;
        }
        if (head.next == null) {
            LinkNode linkNode = new LinkNode(val);
            head.next = linkNode;
            return;
        }
        LinkNode tempNode = head.next;
        while (true) {
            if (tempNode.next == null) {
                LinkNode linkNode = new LinkNode(val);
                tempNode.next = linkNode;
                return;
            } else {
                tempNode = tempNode.next;
            }
        }
    }

    public void addAtIndex(int index, int val) {
        LinkNode linkNode = new LinkNode(val);
        if (index == 0) {
            addAtHead(val);
            return;
        }
        if (index == 1) {
            linkNode.next = head.next;
            head.next = linkNode;
            return;
        }

        int curIndex = 1;
        LinkNode curNext = head.next;
        while (true) {
            if (curNext.next == null) {
                addAtTail(val);
                return;
            }
            if (index == curIndex + 1) {
                linkNode.next = curNext.next.next;
                curNext.next.next = linkNode;
                return;
            } else {
                curNext = curNext.next;
                curIndex++;
            }
        }
    }

    public void deleteAtIndex(int index) {


        if (index == 0) {
            if (head == null) {
                return;
            }
            //删除头节点
            if (head.next == null) {
                head = null;
                return;
            }
            head = head.next;
            return;
        }

        int curIndex = 0;
        LinkNode curNext = head;
        while (true) {
            if (curNext == null) {
                return;
            }
            if (index == ++curIndex) {
                if (curNext.next==null){
                    return;
                }
                curNext.next = curNext.next.next;
                return;
            }
            curNext = curNext.next;
        }
    }

    public int getSize() {
        if (this.head == null) {
            return 0;
        }
        LinkNode node = head.next;
        int size = 1;
        while (true) {
            if (node != null) {
                size++;
                node = node.next;
            } else {
                return size;
            }
        }
    }

}

class LinkNode {
    int val;
    LinkNode next;

    public LinkNode() {
    }

    public LinkNode(int val) {
        this.val = val;
    }
}
```

## 翻转链表

思路：

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/206.%E7%BF%BB%E8%BD%AC%E9%93%BE%E8%A1%A8.gif)

```java
    /**
     * 给你单链表的头节点 head ，请你反转链表，并返回反转后的链表。
     * 输入：head = [1,2,3,4,5]
     * 输出：[5,4,3,2,1]
     *
     * @param args
     */

    public static void main(String[] args) {
        Integer[] listNodes = {1, 2, 3, 4, 5, 6};
        ListNode head = ListNode.convertToListNode(Arrays.asList(listNodes));
        ListNode listNode = reverseList(head);
        System.out.printf(String.valueOf(listNode.val));
    }


    public static ListNode reverseList(ListNode head) {
        //双指针法
        ListNode curNode = head;
        ListNode left = null;
        ListNode tempNode = null;
        while (curNode != null) {
            tempNode = curNode.next;
            curNode.next = left;
            left = curNode;
            curNode = tempNode;
        }
        return left;
    }
```



## 两两交换

注意，该题为模拟，注意画图解决（思路其实如果循环不能解决（因为循环操作的当前节点仍然不能变，指针变不了。所以可以考虑使用递归））

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20250127154216.png)

```java
    /**
     * 给你一个链表，两两交换其中相邻的节点，并返回交换后链表的头节点。你必须在不修改节点内部的值的情况下完成本题（即，只能进行节点交换）。
     * 输入：head = [1,2,3,4]
     * 输出：[2,1,4,3]
     */

    public static void main(String[] args) {
        Integer[] listNodes = {1, 2, 3, 4, 5, 6};
        ListNode head = ListNode.convertToListNode(Arrays.asList(listNodes));
        ListNode listNode = swapPairs(head);
        ListNode.printLinkNode(listNode);
    }


    public static ListNode swapPairs(ListNode head) {
        ListNode curNode = new ListNode(-1, head);
        if (curNode == null) {
            return curNode;
        }
        if (head == null || head.next == null) {
            return head;
        }
        //当前节点的下一个节点变成，当前节点的下一个节点的下一个节点
        //当前节点的上一个节点的下一个节点变成当前节点的下一个节点
        //当前节点的下一个节点的下一个节点变成当前节点
        //画图：1->2->3，变成1->3->2 1为操作节点
        ListNode tempNext = new ListNode(curNode.val, curNode.next);
        curNode.next = curNode.next.next;
        tempNext.next.next = tempNext.next.next.next;
        curNode.next.next = tempNext.next;
        curNode.next.next.next=swapPairs(curNode.next.next.next);
        return curNode.next;
    }
```

## 删除倒数多少的链表

针对类型删除倒数+需要一次一次遍历的结构，就可以使用递归的方式。

```java

    /**
     * 给你一个链表，删除链表的倒数第 n 个结点，并且返回链表的头结点。
     * <p>
     * 进阶：你能尝试使用一趟扫描实现吗？
     * 输入：head = [1,2,3,4,5], n = 2 输出：[1,2,3,5]
     * <p>
     * 示例 2：
     * <p>
     * 输入：head = [1], n = 1 输出：[]
     * <p>
     * 示例 3：
     * <p>
     * 输入：head = [1,2], n = 1 输出：[1]
     */

    public static void main(String[] args) {
        Integer[] listNodes = {1, 2, 3, 4, 5, 6};
        ListNode head = ListNode.convertToListNode(Arrays.asList(listNodes));
        ListNode listNode = removeNthFromEnd(head, 5);
        ListNode.printLinkNode(listNode);
    }

    public static ListNode removeNthFromEnd(ListNode head, int n) {
        if (head.next == null && n == 1) {
            return null;
        }
        Integer remove = remove(head, n, 0);
        if (remove == n) {
            return head.next;
        }
        return head;
    }

    public static Integer remove(ListNode head, int n, Integer cur) {
        if (head.next != null) {
            cur = remove(head.next, n, cur);
        }
        if (cur == n) {
            head.next = head.next.next;
        }
        cur++;
        return cur;
    }
```

## 求两个链表相交节点

解体思路：

1. 相交节点则后续所有节点都需要相等，所以可以将两个链表按照尾部对其。然后从对其之后的短节点的头部遍历

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20250129130247.png)

```java
    /**
     * 给你两个单链表的头节点 headA 和 headB ，请你找出并返回两个单链表相交的起始节点。如果两个链表没有交点，返回 null 。
     * <p>
     * <p>
     * 输入：intersectVal = 8, listA = [4,1,8,4,5], listB = [5,0,1,8,4,5], skipA = 2, skipB = 3
     * 输出：Intersected at '8'
     * 解释：相交节点的值为 8 （注意，如果两个链表相交则不能为 0）。
     * 从各自的表头开始算起，链表 A 为 [4,1,8,4,5]，链表 B 为 [5,0,1,8,4,5]。
     * 在 A 中，相交节点前有 2 个节点；在 B 中，相交节点前有 3 个节点。
     *
     * @param args
     */

    public static void main(String[] args) {
        Integer[] listNodes1 = {1};
        Integer[] listNodes2 = {1};
        ListNode head1 = ListNode.convertToListNode(Arrays.asList(listNodes1));
        ListNode head2 = ListNode.convertToListNode(Arrays.asList(listNodes2));

        ListNode listNode = getIntersectionNode(head1, head2);
        //ListNode.printLinkNode(listNode);
    }

    public static ListNode getIntersectionNode(ListNode headA, ListNode headB) {
        //方案一：使用递归，从headA进行递归，指针从后往前移比对headB中倒数该位置的数值是否一致


        //方案二：将链表转换成数组，获取结果之后再按照index获取对应链表节点

        //方案三：时间复杂度为O(n)，首先将两个链表按照尾部对其，然后每次移动指针指向两个链表的同一个下标位置。这样只需要移动到末尾即可判断结果

        if (headA == null || headB == null) {
            return null;
        }

        int aLen = 1;
        int bLen = 1;
        ListNode aTemp = headA;
        ListNode bTemp = headB;
        while (aTemp.next != null) {
            aLen++;
            aTemp = aTemp.next;
        }
        while (bTemp.next != null) {
            bLen++;
            bTemp = bTemp.next;
        }
        ListNode largeListNode = null;
        ListNode lowListNode = null;

        int count = 0;
        if (aLen > bLen) {
            largeListNode = headA;
            lowListNode = headB;
            count = aLen - bLen;
        } else {
            largeListNode = headB;
            lowListNode = headA;
            count = bLen - aLen;
        }

        //对其指针
        ListNode resultNode = largeListNode;
        for (int i = 0; i < count; ) {
            resultNode = resultNode.next;
            i++;
        }
        ListNode result = null;
        boolean flag = false;
        while (lowListNode != null) {
            if (lowListNode.val == resultNode.val) {
                if (!flag) {
                    result = resultNode;
                }
                lowListNode = lowListNode.next;
                resultNode = resultNode.next;
                flag = true;
                continue;
            }
            lowListNode = lowListNode.next;
            resultNode = resultNode.next;
            result = null;
            flag = false;
        }
        return result;
    }
```

## 环形链表

[算法题环形链表II](https://programmercarl.com/0142.%E7%8E%AF%E5%BD%A2%E9%93%BE%E8%A1%A8II.html#%E6%80%9D%E8%B7%AF)

提供的思路：

自己的思路，快慢指针，快指针从前往后遍历，慢指针遍历到快指针的当前节点。比对节点是否相等

```
/**
     * 给定一个链表的头节点  head ，返回链表开始入环的第一个节点。 如果链表无环，则返回 null。
     * <p>
     * 如果链表中有某个节点，可以通过连续跟踪 next 指针再次到达，则链表中存在环。 为了表示给定链表中的环，评测系统内部使用整数 pos 来表示链表尾连接到链表中的位置（索引从 0 开始）。如果 pos 是 -1，则在该链表中没有环。注意：pos 不作为参数进行传递，仅仅是为了标识链表的实际情况。
     * <p>
     * 不允许修改 链表。
     */

    public static void main(String[] args) {
        Integer[] listNodes = {1, 2, 3, 4, 5, 2};
        ListNode head = ListNode.convertToListNode(Arrays.asList(listNodes));

        ListNode listNode = detectCycle(head);
    }


    public static ListNode detectCycle(ListNode head) {
        if (head == null) {
            return null;
        }
        //快慢指针
        if (head.next == head) {
            return head;
        }


        ListNode fastNode = head;
        int fastCount = 0;
        while (fastNode != null) {
            ListNode slowNode = head;
            int slowCount = 0;
            while (slowCount++ < fastCount) {
                if (slowNode == fastNode) {
                    return slowNode;
                }
                slowNode = slowNode.next;
            }
            fastNode = fastNode.next;
            fastCount++;
        }
        return null;
    }