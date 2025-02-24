# 算法题目

## 总结

[总结](https://programmercarl.com/%E6%95%B0%E7%BB%84%E6%80%BB%E7%BB%93%E7%AF%87.html#%E6%95%B0%E7%BB%84%E7%90%86%E8%AE%BA%E5%9F%BA%E7%A1%80)

### 数组的基本概念

1. **数组下标都是从0开始的。**
2. **数组内存空间的地址是连续的**
3. 一个数组的数据类型是相同的

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/%E7%AE%97%E6%B3%95%E9%80%9A%E5%85%B3%E6%95%B0%E7%BB%84.png)



**因为数组在内存空间的地址是连续的，所以我们在删除或者增添元素的时候，就难免要移动其他元素的地址。**

**数组的元素是不能删的，只能覆盖。**

二维数组的内存空间不是连续的

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/%E7%AE%97%E6%B3%95%E9%80%9A%E5%85%B3%E6%95%B0%E7%BB%843.png)





### 算法题目

### 

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/%E6%95%B0%E7%BB%84%E6%80%BB%E7%BB%93.png)

考察数组，几种常见类型

1. 二分法

   **循环不变量原则**，只有在循环中坚持对区间的定义，才能清楚的把握循环中的各种细节。

2. 双指针法

   **通过一个快指针和慢指针在一个for循环下完成两个for循环的工作。**

3. 滑动窗口

   **滑动窗口的精妙之处在于根据当前子序列和大小的情况，不断调节子序列的起始位置。从而将O(n^2)的暴力解法降为O(n)。**

4. 模拟行为

   **循环不变量原则**



循环不变量原则：定义一个计算逻辑，这个逻辑中的变量可能变，但是这个计算逻辑不会变

**区间的定义就是不变量**。要在二分查找的过程中，保持不变量，就是在while寻找中每一次边界的处理都要坚持根据区间的定义来操作，这就是**循环不变量**规则。

写二分法，区间的定义一般为两种，左闭右闭即[left, right]，或者左闭右开即[left, right)。



## 删除数组元素（双指针）

> 暴力破解法

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/27.%E7%A7%BB%E9%99%A4%E5%85%83%E7%B4%A0-%E6%9A%B4%E5%8A%9B%E8%A7%A3%E6%B3%95.gif)



> 双指针法

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/27.%E7%A7%BB%E9%99%A4%E5%85%83%E7%B4%A0-%E5%8F%8C%E6%8C%87%E9%92%88%E6%B3%95.gif)

- 快指针：寻找新数组的元素 ，新数组就是不含有目标元素的数组
- 慢指针：指向更新 新数组下标的位置

代码实现：

```java

    /**
     * 给你一个数组 nums 和一个值 val，你需要 原地 移除所有数值等于 val 的元素，并返回移除后数组的新长度。
     * <p>
     * 不要使用额外的数组空间，你必须仅使用 O(1) 额外空间并原地修改输入数组。
     * <p>
     * 元素的顺序可以改变。你不需要考虑数组中超出新长度后面的元素。
     * <p>
     * 示例 1: 给定 nums = [3,2,2,3], val = 3, 函数应该返回新的长度 2, 并且 nums 中的前两个元素均为 2。 你不需要考虑数组中超出新长度后面的元素。
     * <p>
     * 示例 2: 给定 nums = [0,1,2,2,3,0,4,2], val = 2, 函数应该返回新的长度 5, 并且 nums 中的前五个元素为 0, 1, 3, 0, 4。
     */


    /**
     * 双指针法，只计算不需要交换的数据进行自加
     *
     * @param integers
     * @param val
     * @return
     */
    public static int removeValRe(Integer[] integers, Integer val) {
        //双指针法
        Integer slow = 0;
        for (int fast = 0; fast < integers.length; fast++) {
            //相等时候，慢指针不动，快指针自增

            //不想等的时候，快指针的元素指给满指针元素
            if (integers[fast] != val) {
                integers[slow] = integers[fast];
                slow++;
            } else {
                //如果要返回去除元素后的数组，则开启下面的。不过此时slow会再增加
                /*if (fast == integers.length - 1) {
                    for (; slow < integers.length; slow++) {
                        integers[slow] = null;
                    }
                }*/
            }
        }
        return slow;
    }

```

> 删除数组中重复元素

```java

    /**
     * 给你一个 非严格递增排列 的数组 nums ，请你 原地 删除重复出现的元素，使每个元素 只出现一次 ，返回删除后数组的新长度。元素的 相对顺序 应该保持 一致 。然后返回 nums 中唯一元素的个数。
     *
     * 考虑 nums 的唯一元素的数量为 k ，你需要做以下事情确保你的题解可以被通过：
     *
     * 更改数组 nums ，使 nums 的前 k 个元素包含唯一元素，并按照它们最初在 nums 中出现的顺序排列。nums 的其余元素与 nums 的大小不重要。
     * 返回 k 。
     */
    /**
     * 示例 1：
     *
     * 输入：nums = [1,1,2]
     * 输出：2, nums = [1,2,_]
     * 解释：函数应该返回新的长度 2 ，并且原数组 nums 的前两个元素被修改为 1, 2 。不需要考虑数组中超出新长度后面的元素。
     */
    /**
     * 示例 2：
     * <p>
     * 输入：nums = [0,0,1,1,1,2,2,3,3,4]
     * 输出：5, nums = [0,1,2,3,4]
     * 解释：函数应该返回新的长度 5 ， 并且原数组 nums 的前五个元素被修改为 0, 1, 2, 3, 4 。不需要考虑数组中超出新长度后面的元素。
     */

    public static void main(String[] args) {
        Integer[] nums = {0, 0, 1, 1, 1, 2, 2, 3, 3, 4};
        Integer i = removeRepeVal(nums);
        System.out.printf(String.valueOf(i));
    }


    public static Integer removeRepeVal(Integer[] integers) {
        int slow = 0;
        for (int fast = 0; fast < integers.length; fast++) {
            if (slow == fast) {
                //slow不动，fast+1
                continue;
            }

            if ((integers[slow] == integers[fast])) {
                continue;
            }
            slow++;
            integers[slow] = integers[fast];
        }
        slow++;
        return slow;
    }
```

> 移动0

```java
		/**
     * 给定一个数组 nums，编写一个函数将所有 0 移动到数组的末尾，同时保持非零元素的相对顺序。
     * <p>
     * 请注意 ，必须在不复制数组的情况下原地对数组进行操作。
     * <p>
     * <p>
     * <p>
     * 示例 1:
     * <p>
     * 输入: nums = [0,1,0,3,12]
     * 输出: [1,3,12,0,0]
     * 示例 2:
     * <p>
     * 输入: nums = [0]
     * 输出: [0]
     */
		//重点在于，如果不为0的时候，就交换左指针，此时左指针的下标到右指针之间的值肯定是0或者没有值。应该不为0的左指针已经前进了
    public static void main(String[] args) {
        int[] nums = {0, 1, 0, 3, 12};
        moveZeroes(nums);
    }
    public static void moveZeroes(int[] nums) {
        int slow = 0;
        for (int fast = 0; fast < nums.length; fast++) {
            if (nums[fast] == 0) {
                continue;
            }
            int temp = nums[slow];
            nums[slow] = nums[fast];
            nums[fast] = temp;
            slow++;
        }

        Arrays.stream(nums).forEach(System.out::println);
    }
```

> [比较含退格的字符串](https://leetcode.cn/problems/backspace-string-compare/)

```java
    /**
     * 给定 s 和 t 两个字符串，当它们分别被输入到空白的文本编辑器后，如果两者相等，返回 true 。# 代表退格字符。
     * <p>
     * 注意：如果对空文本输入退格字符，文本继续为空。
     * <p>
     * <p>
     * <p>
     * 示例 1：
     * <p>
     * 输入：s = "ab#c", t = "ad#c"
     * 输出：true
     * 解释：s 和 t 都会变成 "ac"。
     * 示例 2
     * <p>
     * 输入：s = "ab##", t = "c#d#"
     * 输出：true
     * 解释：s 和 t 都会变成 ""。
     * 示例 3：
     * <p>
     * 输入：s = "a#c", t = "b"
     * 输出：false
     * 解释：s 会变成 "c"，但 t 仍然是 "b"。
     */

使用双指针思路：从后往前遍历，遇到#记录跳过一次，遇到字符则将记录的跳过次数-1。然后比较当没有跳过的时候所在的字符是否相等，遇到不想等则返回false，遍历结束则返回true
  
但是感觉这道题不该用双指针，用栈来解决更合适（如果有#，则栈顶元素推出，否则则押入栈顶）
```

> 有序数组平方排序

```java
 /**
     * 给你一个按 非递减顺序 排序的整数数组 nums，返回 每个数字的平方 组成的新数组，要求也按 非递减顺序 排序。
     * <p>
     * <p>
     * <p>
     * 示例 1：
     * <p>
     * 输入：nums = [-4,-1,0,3,10]
     * 输出：[0,1,9,16,100]
     * 解释：平方后，数组变为 [16,1,0,9,100]
     * 排序后，数组变为 [0,1,9,16,100]
     * 示例 2：
     * <p>
     * 输入：nums = [-7,-3,2,3,11]
     * 输出：[4,9,9,49,121]
     */
    public static void main(String[] args) {
        int[] nums = {-5, -3, -2, -1};
        int[] ints = sortedSquares(nums);
        Arrays.stream(ints).forEach(System.out::println);
    }

    public static int[] sortedSquares(int[] nums) {
        //双指针，指向0和length-1。比较结果，将更大的结果放在最右边然后移动对应指针
        int[] result = new int[nums.length];
        for (int left = 0, right = nums.length - 1, max = nums.length - 1; left <= right; max--) {
            if (nums[left] * nums[left] <= nums[right] * nums[right]) {
                result[max] = nums[right] * nums[right];
                right--;
            } else {
                result[max] = nums[left] * nums[left];
                left++;
            }
        }
        return result;
    }
```

## 滑动窗口（双指针）

总结：滑动窗口的解法，并不一定是要两次循环，根据题意可以一次循环，然后后面滑动窗口的起始位置自增即可

题目：

```java
给定一个含有 n 个正整数的数组和一个正整数 s ，找出该数组中满足其和 ≥ s 的长度最小的 连续 子数组，并返回其长度。如果不存在符合条件的子数组，返回 0。

示例：
- 输入：s = 7, nums = [2,3,1,2,4,3]
- 输出：2
- 解释：子数组 [4,3] 是该条件下的长度最小的子数组。
提示：
- 1 <= target <= 10^9
- 1 <= nums.length <= 10^5
- 1 <= nums[i] <= 10^5
```

> 暴力解法

使用两个for循环，一个表示起始节点一个表示终止节点。循环来判断结果



> 滑动窗口（双指针）

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/209.%E9%95%BF%E5%BA%A6%E6%9C%80%E5%B0%8F%E7%9A%84%E5%AD%90%E6%95%B0%E7%BB%84.gif)

精髓在于：使用一个循环来解决，这个循环来控制终止位置。起始位置自增即可，不会比当前小所以不用循环

```java
    /**
     * 给定一个含有 n 个正整数的数组和一个正整数 target 。
     * <p>
     * 找出该数组中满足其总和大于等于 target 的长度最小的
     * 子数组
     * [numsl, numsl+1, ..., numsr-1, numsr] ，并返回其长度。如果不存在符合条件的子数组，返回 0 。
     * <p>
     * <p>
     * <p>
     * 示例 1：
     * <p>
     * 输入：target = 7, nums = [2,3,1,2,4,3]
     * 输出：2
     * 解释：子数组 [4,3] 是该条件下的长度最小的子数组。
     * 示例 2：
     * <p>
     * 输入：target = 4, nums = [1,4,4]
     * 输出：1
     * 示例 3：
     * <p>
     * 输入：target = 11, nums = [1,1,1,1,1,1,1,1]
     * 输出：0
     */

    public static void main(String[] args) {
        int target = 7;
        int[] nums = {2, 3, 1, 2, 4, 3};
        int i = minSubArrayLen(target, nums);
        System.out.printf(String.valueOf(i));
    }

    public static int minSubArrayLen(int target, int[] nums) {

        int left = 0,sum = 0,result = 0;
        for (int right = 0; right < nums.length; right++) {
            int curResult = (right - left) + 1;
            sum += nums[right];
            boolean curResultIsOk = false;
            while (sum >= target) {
                curResultIsOk = true;
                sum -= nums[left];
                left++;
                curResult--;
            }
            if (curResultIsOk) {
                if (result > curResult || result == 0)
                    result = curResult + 1;
            }
        }
        return result;
    }
```

> 摘水果，题解：双指针滑动窗口

```java
/**
     * 你正在探访一家农场，农场从左到右种植了一排果树。这些树用一个整数数组 fruits 表示，其中 fruits[i] 是第 i 棵树上的水果 种类 。
     * 你想要尽可能多地收集水果。然而，农场的主人设定了一些严格的规矩，你必须按照要求采摘水果：
     * 你只有 两个 篮子，并且每个篮子只能装 单一类型 的水果。每个篮子能够装的水果总量没有限制。
     * 你可以选择任意一棵树开始采摘，你必须从 每棵 树（包括开始采摘的树）上 恰好摘一个水果 。采摘的水果应当符合篮子中的水果类型。每采摘一次，你将会向右移动到下一棵树，并继续采摘。
     * 一旦你走到某棵树前，但水果不符合篮子的水果类型，那么就必须停止采摘。
     * 给你一个整数数组 fruits ，返回你可以收集的水果的 最大 数目。
     * <p>
     * 示例 1：
     * <p>
     * 输入：fruits = [1,2,1]
     * 输出：3
     * 解释：可以采摘全部 3 棵树。
     * 示例 2：
     * <p>
     * 输入：fruits = [0,1,2,2]
     * 输出：3
     * 解释：可以采摘 [1,2,2] 这三棵树。
     * 如果从第一棵树开始采摘，则只能采摘 [0,1] 这两棵树。
     * 示例 3：
     * <p>
     * 输入：fruits = [1,2,3,2,2]
     * 输出：4
     * 解释：可以采摘 [2,3,2,2] 这四棵树。
     * 如果从第一棵树开始采摘，则只能采摘 [1,2] 这两棵树。
     * 示例 4：
     * <p>
     * 输入：fruits = [3,3,3,1,2,1,1,2,3,3,4]
     * 输出：5
     * 解释：可以采摘 [1,2,1,1,2] 这五棵树。
     */
    public static void main(String[] args) {
        int[] fruits = {1, 1, 6, 5, 6, 6, 1, 1, 1, 1};
        int i = totalFruit(fruits);
        System.out.printf(String.valueOf(i));
    }

    public static int totalFruit(int[] fruits) {
        int result = 1;
        int left = 0;
        Integer[] fruitType = {fruits[0], null};
        for (int right = 1; right < fruits.length; right++) {
            int curResult = right - left + 1;
            boolean curInvalid = false;
            if (fruitType[1] == null) {
                //第二个篮子空，但是类型相同
                curInvalid = true;
                if (fruitType[0] != fruits[right]) {
                    fruitType[1] = fruits[right];
                }
            } else {
                if (fruitType[0] == fruits[right] || fruitType[1] == fruits[right]) {
                    //篮子中有该类型水果
                    curInvalid = true;
                } else {
                    //篮子中没有这种水果
                    fruitType[0] = null;
                    fruitType[1] = fruits[right];
                    int lleft = right - 1;
                    Boolean flag = true;
                    while (flag) {
                        flag = false;
                        if (fruitType[1] == fruits[lleft]) {
                            //当前为右节点
                            flag = true;
                            lleft--;
                            continue;
                        }
                        if (fruitType[0] == null) {
                            flag = true;
                            fruitType[0] = fruits[lleft];
                            lleft--;
                        } else {
                            if (fruits[lleft] == fruitType[0]) {
                                lleft--;
                                flag = true;
                            }
                        }
                    }
                    left = lleft + 1;
                    curResult = right - left + 1;
                    curInvalid = true;
                }
            }

            if (curInvalid) {
                if (result == 1) {
                    result = curResult;
                }
                if (result < curResult) {
                    result = curResult;
                }
            }
        }
        return result;
    }
```

> 最小覆盖子串。
>
> 精髓有两部分
>
> 1. 滑动窗口来选择子串
> 2. 使用Map来记录子串数量，并跟随滑动窗口的子串来调整Map中的元素数量

```java
/**
     * 给你一个字符串 s 、一个字符串 t 。返回 s 中涵盖 t 所有字符的最小子串。如果 s 中不存在涵盖 t 所有字符的子串，则返回空字符串 "" 。
     * <p>
     * 注意：
     * <p>
     * 对于 t 中重复字符，我们寻找的子字符串中该字符数量必须不少于 t 中该字符数量。
     * 如果 s 中存在这样的子串，我们保证它是唯一的答案。
     * <p>
     * 示例 1：
     * 输入：s = "ADOBECODEBANC", t = "ABC"
     * 输出："BANC"
     * 解释：最小覆盖子串 "BANC" 包含来自字符串 t 的 'A'、'B' 和 'C'。
     * <p>
     * 示例 2：
     * <p>
     * 输入：s = "a", t = "a"
     * 输出："a"
     * 解释：整个字符串 s 是最小覆盖子串。
     * 示例 3:
     * <p>
     * 输入: s = "a", t = "aa"
     * 输出: ""
     * 解释: t 中两个字符 'a' 均应包含在 s 的子串中，
     * 因此没有符合条件的子字符串，返回空字符串。
     */
    public static void main(String[] args) {
        String s = "a";
        String t = "aa";
        String string = minWindow(s, t);
        System.out.printf(string);
    }

    public static String minWindow(String s, String t) {
        //思路：滑动窗口，再增加一个指针从滑动窗口的头节点遍历到尾节点

        //思路2:滑动窗口上的滑动窗口

        //思路3:sL指针

        Map<Character, Integer> mapT = new HashMap<Character, Integer>();
        for (int i = 0; i < t.length(); i++) {
            Integer i1 = mapT.get(t.charAt(i));
            mapT.put(t.charAt(i), i1 == null ? 1 : ++i1);
        }
        Map<Character, Integer> mapB = new HashMap<Character, Integer>();
        int left = 0;
        String result = "";
        for (int right = 0; right < s.length(); right++) {
            String curResult = s.substring(left, right);
            boolean ik = false;
            Integer value = mapB.get(s.charAt(right));
            mapB.put(s.charAt(right), value == null ? 1 : ++value);

            while (left <= right) {
                if (convert(mapB, mapT)) {
                    curResult = s.substring(left, right + 1);
                    Integer a = mapB.get(s.charAt(left));
                    mapB.put(s.charAt(left), a == null ? 0 : --a);
                    left++;
                    ik = true;
                    continue;
                }
                break;
            }
            if (ik) {
                if (result.length() == 0 || result.length() >= curResult.length()) {
                    result = s.substring(--left, right + 1);
                    Integer e = mapB.get(s.charAt(left));
                    mapB.put(s.charAt(left), e == null ? 1 : ++e);
                }
            }
        }
        return result;
    }

    public static boolean convert(Map<Character, Integer> mapB, Map<Character, Integer> mapT) {
        Map<Character, Integer> map = new HashMap<>();
        map.putAll(mapB);
        for (Character key : mapT.keySet()) {
            Integer i = mapB.get(key);
            if (i == null || i == 0 || i < mapT.get(key)) {
                return false;
            }
        }
        return true;
    }
```



## 螺旋矩阵（模拟）

总结：需要注意几个点

1. 循环多少次，应该是n/2。因为每一圈其实会处理两列/两行
2. 拆分成从左到右、从上到下、从右到左、从下到上。而且每次操作都需要定好边界，比如都遵循左开右闭或者左闭右开
3. 需要处理奇数的中心点位置（可能不是一个，如果长宽不一致的时候，需要处理）。因为我们n/2会漏掉最中心的结果
   1. 如果行是奇数行，则rowNum/2那一行的i~colNum-i数值没有处理
   2. 如何列是奇数列，则colNum/2那一列的i~rowNum-i数值没有处理
   3. 如果两者皆为奇数，则只处理一次

概念：什么是螺旋矩阵

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/spiraln.jpg)

题目类型：

```java
给你一个正整数 n ，生成一个包含 1 到 n2 所有元素，且元素按顺时针顺序螺旋排列的 n x n 正方形矩阵 matrix 。
  
输入：n = 3
输出：[[1,2,3],[8,9,4],[7,6,5]]
示例 2：

输入：n = 1
输出：[[1]]

* 输入：4 输出：
* [1 ,2 ,3 ,4]
* [12,13,14,5]
* [11,16,15,6]
* [10,9 ,8 ,7]
```

```java
/**
     * 给定一个正整数 n，生成一个包含 1 到 n^2 所有元素，且元素按顺时针顺序螺旋排列的正方形矩阵。
     *
     * 示例:
     *
     * 输入: 3 输出: [ [ 1, 2, 3 ], [ 8, 9, 4 ], [ 7, 6, 5 ] ]
     *
     * 输入：4 输出：
     * [1 ,2 ,3 ,4]
     * [12,13,14,5]
     * [11,16,15,6]
     * [10,9 ,8 ,7]
     *
     */
    /**
     * 思路提示：
     * 1. 循环判定旋转多少次
     * 2. 做好控制每次到拐点需要操作多少次（n-循环次数）
     * 3. 判定好每次什么时候算作到拐点，比如从左到右，左闭右开
     */

    public static void main(String[] args) {
        int[][] ints = generateMatrix(5);
        for (int i = 0; i < ints.length; i++) {
            // 内层循环遍历列
            for (int j = 0; j < ints[i].length; j++) {
                System.out.print(ints[i][j] + " ");
            }
            // 每一行输出完后换行
            System.out.println();
        }
    }

    public static int[][] generateMatrix(int n) {
        int criNum = n / 2;
        int[][] result = new int[n][n];
        int number = 1;
        int max = n * n;
        for (int i = 0; i < criNum; i++) {
            //从左到右
            for (int j = i; j < n - i - 1; j++) {
                //每一轮从左到右操作的都是第i行
                result[i][j] = number++;
            }
            //从上到下
            for (int j = i; j < n - i - 1; j++) {
                //每一轮从上到下操作的都是第n-i+1列
                result[j][n - i - 1] = number++;
            }
            //从右到左
            for (int j = n - i - 1; j > i; j--) {
                //每一轮从右到左操作的都是第n-i+1行
                result[n - i - 1][j] = number++;
            }
            //从下到上
            for (int j = n - i - 1; j > i; j--) {
                //每一轮从右到左操作的都是第n-i+1行
                result[j][i] = number++;
            }
        }
        if (n % 2 != 0) {
            result[n / 2][n / 2] = number;
        }
        return result;
    }
```



```java

    /**
     * 给你一个 m 行 n 列的矩阵 matrix ，请按照 顺时针螺旋顺序 ，返回矩阵中的所有元素。
     * 输入：matrix = [[1,2,3],[4,5,6],[7,8,9]]
     * 输出：[1,2,3,6,9,8,7,4,5]
     * <p>
     * 输入：matrix = [[1,2,3,4],[5,6,7,8],[9,10,11,12]]
     * 输出：[1,2,3,4,8,12,11,10,9,5,6,7]
     */
    public static void main(String[] args) {
//        int[][] martrix = {
//                {1, 2, 3, 4},
//                {5, 6, 7, 8},
//                {9, 10, 11, 12}
//        };
//        int[][] martrix = {
//                {1, 2, 3}, {5, 6, 7}, {9, 10, 11}
//        };

        int[][] martrix = {
                {7}, {9}, {6}
        };
        List<Integer> integers = spiralOrder(martrix);
        integers.stream().forEach(System.out::print);
    }

    public static List<Integer> spiralOrder(int[][] matrix) {
        List<Integer> result = new ArrayList<>();
        int rowNum = matrix.length;
        int colNum = matrix[0].length;
        //遍历轮数
        int loop = rowNum / 2;
        int i = 0;
        int max = rowNum * colNum;
        for (; i < loop; i++) {
            //从左到右
            for (int j = i; j < colNum - i - 1; j++) {
                if (result.size()==max){
                    break;
                }
                result.add(matrix[i][j]);
            }
            //从上到下
            for (int j = i; j < rowNum - i - 1; j++) {
                if (result.size()==max){
                    break;
                }
                result.add(matrix[j][colNum - i - 1]);
            }
            //从右到左
            for (int j = colNum - i - 1; j > i; j--) {
                if (result.size()==max){
                    break;
                }
                result.add(matrix[rowNum - i - 1][j]);
            }
            //从下到上
            for (int j = rowNum - i - 1; j > i; j--) {
                if (result.size()==max){
                    break;
                }
                result.add(matrix[j][i]);
            }
        }
        //处理循环不到的地方
        //如果行是奇数行，则rowNum/2那一行的i~colNum-i数值没有处理
        if (rowNum % 2 != 0) {
            for (int j = i; j < colNum - i; j++) {
                result.add(matrix[rowNum / 2][j]);
            }
        }
        //如何列是奇数列，则colNum/2那一列的i~rowNum-i数值没有处理
        if (colNum % 2 != 0 && rowNum % 2 == 0) {
            for (int j = i; j < rowNum - i; j++) {
                result.add(matrix[j][colNum / 2]);
            }
        }

        return result;
    }
```

