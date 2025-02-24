# 基础知识

## 概念

什么是哈希表？

一个数组结构，用来存储key经过hashCode之后的值

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20250129145456.png)

## 特点

### 查询值的时间复杂度为O(1)

因为可以将需要查询的key经过hash之后放入对应的槽内，所以时间复杂度为O(1)的精确匹配。

### 哈希碰撞

因为数组的长度是一定的，当两个值经过hashCode并取模之后放入hash槽，可能存在两个放入的是一个槽，所以这个时候就会产生hash碰撞。

解决哈希碰撞的一般办法为

- **拉链法**：即在对应的数组节点上再增加一个链表来存储出现哈希碰撞的节点

  ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20250129145754.png)

- **线性探测法**：即多个哈希槽对应一个取模的下标。

  ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/picgo/20250129145912.png)



## 使用特点

当遇到算法题目，需要判断某一个key是否存在这个数组/集合中时，可以使用哈希表来解决。



# 算法题目

## 总结

- 凡是需要在一个数组中找一个值的都可以使用哈希来解决
- 如果是需要字母是否寻在，则可以将字母-`a`来获取数组下标位置

## 有效的字母异位词

> 给定两个字符串 `s` 和 `t` ，编写一个函数来判断 `t` 是否是 `s` 的 字母异位词
>
> **示例 1:**
>
> ```
> 输入: s = "anagram", t = "nagaram"
> 输出: true
> ```
>
> **示例 2:**
>
> ```
> 输入: s = "rat", t = "car"
> 输出: false
> ```

```java
    public static boolean isAnagram(String s, String t) {
      	//解体思路：使用一个数组，下标标识每一个字符，值来标识当前字符出现的次数。s来加，t来剪，最后判断每一个位置下标是否为空则可以判断结果
        int[] temp = new int[26];

        if (s.length() != t.length()) {
            return false;
        }

        for (int i = 0; i < s.length(); i++) {
            temp[s.charAt(i) - 'a']++;
        }

        for (int i = 0; i < t.length(); i++) {
            temp[t.charAt(i) - 'a']--;
        }

        for (int i = 0; i < temp.length; i++) {
            if (temp[i] != 0) {
                return false;
            }
        }
        return true;
    }

    public static void main(String[] args) {

        System.out.printf(String.valueOf(isAnagram("aba","baa")));

    }
```

## 两个数组相交的结果

```java

    /**
     * 给定两个数组 nums1 和 nums2 ，返回 它们的 
     * 交集
     *  。输出结果中的每个元素一定是 唯一 的。我们可以 不考虑输出结果的顺序 。
     *
     *
     *
     * 示例 1：
     *
     * 输入：nums1 = [1,2,2,1], nums2 = [2,2]
     * 输出：[2]
     * 示例 2：
     *
     * 输入：nums1 = [4,9,5], nums2 = [9,4,9,8,4]
     * 输出：[9,4]
     * 解释：[4,9] 也是可通过的
     * @param args
     */
    public static void main(String[] args) {
        int[] nums1 = {9,4,9,8,4};
        int[] nums2 = {4,9,5};

        int[] intersection = intersection(nums1, nums2);
        Arrays.stream(intersection).forEach(System.out::println);
    }

    public static int[] intersection(int[] nums1, int[] nums2) {

        //int[] result = new int[nums1.length];
        Set<Integer> list = new HashSet<>();
        HashSet set = new HashSet();
        for (int i = 0; i < nums1.length; i++) {
            set.add(nums1[i]);
        }
        for (int i = 0; i < nums2.length; i++) {
            if (set.contains(nums2[i])) {
                list.add(nums2[i]);
            }
        }

        int[] result = new int[list.size()];
        int i = 0;
        for (Integer l : list) {
            result[i] = l;
            i++;
        }
        return result;
    }
```



## 快乐数

**当我们遇到了要快速判断一个元素是否出现集合里的时候，就要考虑哈希法了。**

```java
/**
     * 编写一个算法来判断一个数 n 是不是快乐数。
     * <p>
     * 「快乐数」 定义为：
     * <p>
     * 对于一个正整数，每一次将该数替换为它每个位置上的数字的平方和。
     * 然后重复这个过程直到这个数变为 1，也可能是 无限循环 但始终变不到 1。
     * 如果这个过程 结果为 1，那么这个数就是快乐数。
     * 如果 n 是 快乐数 就返回 true ；不是，则返回 false 。
     * <p>
     * <p>
     * <p>
     * 示例 1：
     * <p>
     * 输入：n = 19
     * 输出：true
     * 解释：
     * 12 + 92 = 82
     * 82 + 22 = 68
     * 62 + 82 = 100
     * 12 + 02 + 02 = 1
     * 示例 2：
     * <p>
     * 输入：n = 2
     * 输出：false
     */
    public static void main(String[] args) {

        System.out.printf(String.valueOf(isHappy(10)));

    }

    static List<Integer> list = new ArrayList<>();

    public static boolean isHappy(int n) {
        if (list.contains(n)) {
            return false;
        }
        list.add(n);
        Integer sum = sum(n);
        if (sum == 1) {
            return true;
        }
        return isHappy(sum);
    }

    public static Integer sum(int n) {

        List<Integer> sumList = new ArrayList<>();
        while (true) {
            if (n == 0) {
                break;
            }
            int e = n % 10;
            sumList.add(e);
            n = n / 10;
        }
        Integer result = 0;
        for (Integer i : sumList) {
            result += i * i;
        }
        return result;
    }
```

## 两数之和

解题思路：使用哈希，循环一次遍历数组，将目标值-当前值存储在哈希中。每次检查当前结果是否在哈希里面出现，出现则返回循环数喝当前temp值

```java

    /**
     * 给定一个整数数组 nums 和一个整数目标值 target，请你在该数组中找出 和为目标值 target  的那 两个 整数，并返回它们的数组下标。
     * <p>
     * 你可以假设每种输入只会对应一个答案，并且你不能使用两次相同的元素。
     * <p>
     * 你可以按任意顺序返回答案。
     * <p>
     * <p>
     * <p>
     * 示例 1：
     * <p>
     * 输入：nums = [2,7,11,15], target = 9
     * 输出：[0,1]
     * 解释：因为 nums[0] + nums[1] == 9 ，返回 [0, 1] 。
     * 示例 2：
     * <p>
     * 输入：nums = [3,2,4], target = 6
     * 输出：[1,2]
     * 示例 3：
     * <p>
     * 输入：nums = [3,3], target = 6
     * 输出：[0,1]
     */

    public int[] twoSum(int[] nums, int target) {

        if (nums == null || nums.length <= 1) {
            return null;
        }
        int[] result = new int[2];
        Map<Integer, Integer> set = new HashMap();
        Set<Integer> integers = set.keySet();
        for (int i = 0; i < nums.length; i++) {
            int temp = target - nums[i];
            if (integers.contains(temp)) {
                result[0] = set.get(temp);
                result[1] = i;
                return result;
            }
            set.put(nums[i], i);
        }
        return null;
    }
```

## 四数相加

**标准的Hash来解决的问题**，只需要关注两两相加的结果出现的次数，再计算0-两个的结果出现的次数即可

给你四个整数数组 `nums1`、`nums2`、`nums3` 和 `nums4` ，数组长度都是 `n` ，请你计算有多少个元组 `(i, j, k, l)` 能满足：

- `0 <= i, j, k, l < n`
- `nums1[i] + nums2[j] + nums3[k] + nums4[l] == 0`

 

**示例 1：**

```
输入：nums1 = [1,2], nums2 = [-2,-1], nums3 = [-1,2], nums4 = [0,2]
输出：2
解释：
两个元组如下：
1. (0, 0, 0, 1) -> nums1[0] + nums2[0] + nums3[0] + nums4[1] = 1 + (-2) + (-1) + 2 = 0
2. (1, 1, 0, 0) -> nums1[1] + nums2[1] + nums3[0] + nums4[0] = 2 + (-1) + (-1) + 0 = 0
```

**示例 2：**

```
输入：nums1 = [0], nums2 = [0], nums3 = [0], nums4 = [0]
输出：1
```

```java
		public static void main(String[] args) {
        int[] nums1 = {-1, -1};
        int[] nums2 = {-1, 1};
        int[] nums3 = {-1, 1};
        int[] nums4 = {1, -1};
        fourSumCount(nums1, nums2, nums3, nums4);
    }

    public static int fourSumCount(int[] nums1, int[] nums2, int[] nums3, int[] nums4) {
        //思路：将nums1、nums2数组进行循环遍历，得出相加结果，放入map中
        //再遍历nums3、nums4，判断0-(nums3[i]+nums4[j])的结果是否在map中，如果在则自增一

        //Map<Integer, Integer> map = new HashMap<>();
        Map<Integer, Integer> map = new HashMap<>();
        Set<Integer> integers = map.keySet();
        int result = 0;

        for (int i = 0; i < nums1.length; i++) {
            for (int j = 0; j < nums2.length; j++) {
                map.put(nums1[i] + nums2[j],
                        map.getOrDefault(nums1[i] + nums2[j], 0) + 1);
            }
        }
        for (int i = 0; i < nums3.length; i++) {
            for (int j = 0; j < nums4.length; j++) {
                int o = 0 - (nums3[i] + nums4[j]);
                if (integers.contains(o)) {
                    result += map.get(o);
                }
            }
        }
        return result;
    }
```



## 赎金信



### 题目

给你两个字符串：`ransomNote` 和 `magazine` ，判断 `ransomNote` 能不能由 `magazine` 里面的字符构成。

如果可以，返回 `true` ；否则返回 `false` 。

`magazine` 中的每个字符只能在 `ransomNote` 中使用一次。

 

**示例 1：**

```
输入：ransomNote = "a", magazine = "b"
输出：false
```

**示例 2：**

```
输入：ransomNote = "aa", magazine = "ab"
输出：false
```

**示例 3：**

```
输入：ransomNote = "aa", magazine = "aab"
输出：true
```

### 解题思路

该题目与`有效的字母异位词`是一个类型的题目。需要记住两个点

- 题目的字符是26个字母中的，所以可以使用当前字母与`a`之间的差值来放入数组中
- 寻找某一个字符是否在数组中可以使用哈希来解决

```java
    public boolean canConstruct(String ransomNote, String magazine) {
        int[] temp = new int[26];
        for (int i = 0; i < magazine.length(); i++) {
            temp[magazine.charAt(i) - 'a']++;
        }

        for (int i = 0; i < ransomNote.length(); i++) {
            char c = ransomNote.charAt(i);
            if (temp[c - 'a'] == 0) {
                return false;
            }
            temp[c - 'a']--;
        }
        return true;
    }
```



