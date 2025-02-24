# 总结

对于字符串方面的题目，有以下几种方式

- 双指针
- KMP

# 题目

## 字符串反转

```java
 		/**
     * 编写一个函数，其作用是将输入的字符串反转过来。输入字符串以字符数组 s 的形式给出。
     * <p>
     * 不要给另外的数组分配额外的空间，你必须原地修改输入数组、使用 O(1) 的额外空间解决这一问题。
     * <p>
     * <p>
     * <p>
     * 示例 1：
     * <p>
     * 输入：s = ["h","e","l","l","o"]
     * 输出：["o","l","l","e","h"]
     * 示例 2：
     * <p>
     * 输入：s = ["H","a","n","n","a","h"]
     * 输出：["h","a","n","n","a","H"]
     */


    public static void main(String[] args) {
        String a = "abc";
        char[] charArray = a.toCharArray();
        reverseString(charArray);
        for (char c : charArray) {
            System.out.printf(String.valueOf(c));
        }
    }

    public static void reverseString(char[] s) {
        //解题思路：双指针
        for (int i = 0, j = s.length - 1; i < j; i++, j--) {
            char temp = s[i];
            s[i] = s[j];
            s[j] = temp;
        }
    }
```



## 字符串反转2

```java
    //给定一个字符串 s 和一个整数 k，从字符串开头算起，每计数至 2k 个字符，就反转这 2k 字符中的前 k 个字符。
    //
    //如果剩余字符少于 k 个，则将剩余字符全部反转。
    //如果剩余字符小于 2k 但大于或等于 k 个，则反转前 k 个字符，其余字符保持原样。
    //
    //
    //示例 1：
    //
    //输入：s = "abcdefg", k = 2
    //输出："bacdfeg"
    //示例 2：
    //
    //输入：s = "abcd", k = 2
    //输出："bacd"

    public static void main(String[] args) {
        System.out.printf(reverseStr("a", 2));
    }

    public static String reverseStr(String s, int k) {

        //第一步，循环访问s，每次移动至2k+index（即跳过一个key的范围）
        //第二步，操作当前index+key的值进行倒序
        char[] charArray = s.toCharArray();
        for (int i = 0; i < s.length(); i = i + (2 * k)) {
            reverseString(charArray, i, (i + k - 1) >= s.length() ? s.length()-1 : (i + k - 1));
        }
        String result = "";
        for (char a : charArray) {
            result += a;
        }
        return result;
    }

    public static void reverseString(char[] s, int begin, int end) {
        //解题思路：双指针
        for (int i = begin, j = end; i < j; i++, j--) {
            char temp = s[i];
            s[i] = s[j];
            s[j] = temp;
        }
    }
```

## 翻转字符串中的单词

```java

    //给你一个字符串 s ，请你反转字符串中 单词 的顺序。
    //
    //单词 是由非空格字符组成的字符串。s 中使用至少一个空格将字符串中的 单词 分隔开。
    //
    //返回 单词 顺序颠倒且 单词 之间用单个空格连接的结果字符串。
    //
    //注意：输入字符串 s中可能会存在前导空格、尾随空格或者单词间的多个空格。返回的结果字符串中，单词间应当仅用单个空格分隔，且不包含任何额外的空格。
    //
    //
    //
    //示例 1：
    //
    //输入：s = "the sky is blue"
    //输出："blue is sky the"
    //示例 2：
    //
    //输入：s = "  hello world  "
    //输出："world hello"
    //解释：反转后的字符串中不能存在前导空格和尾随空格。
    //示例 3：
    //
    //输入：s = "a good   example"
    //输出："example good a"
    //解释：如果两个单词间有多余的空格，反转后的字符串需要将单词间的空格减少到仅有一个。
    //进阶：如果字符串在你使用的编程语言中是一种可变数据类型，请尝试使用 O(1) 额外空间复杂度的 原地 解法。

    public static void main(String[] args) {
        reverseWords("  hello world  ");
    }

    public static String reverseWords(String s) {
        //Java中字符串位不可变数据，所以借助一个数组来实现其他语言解题中的O(1)解法
        //1. 删除多余空格
        //2. 反转整个字符串
        //3. 反转单个单词

        //char[] charArray = s.toCharArray();
        List<Character> characters = new ArrayList<>();
        for (int i = 0; i < s.length(); i++) {
            if (s.charAt(i) == 32) {
                if (i == 0) {
                    continue;
                }
                if (characters.size() == 0) {
                    continue;
                }
                if (i == s.length() - 1) {
                    continue;
                }
                if (s.charAt(i + 1) == 32) {
                    continue;
                }

            }
            characters.add(s.charAt(i));
        }


        for (int i = 0, j = characters.size() - 1; i < j; i++, j--) {
            char temp = characters.get(i);
            characters.set(i, characters.get(j));
            characters.set(j, temp);
        }

        int left = 0;
        int right = 0;
        for (int i = 0; i < characters.size(); i++) {
            if (characters.get(i) == 32) {
                right = i;
                //倒转
                reverseString(characters, left, --right);
                left = i + 1;
                continue;
            }
            if (i == characters.size() - 1) {
                right = i;
                reverseString(characters, left, right);
            }
        }
        String result="";
        for (int i = 0; i <characters.size(); i++) {
            result+=characters.get(i);
        }
        return result;
    }

    public static void reverseString(List<Character> s, int begin, int end) {
        //解题思路：双指针
        for (int i = begin, j = end; i < j; i++, j--) {
            char temp = s.get(i);
            s.set(i, s.get(j));
            s.set(j, temp);
        }
    }
```

# KMP算法

## 概述

> 什么是KMP？

Knuth，Morris和Pratt，所以取了三位学者名字的首字母。所以叫做KMP

> KMP有什么用

KMP主要应用在字符串匹配上。

KMP的主要思想是**当出现字符串不匹配时，可以知道一部分之前已经匹配的文本内容，可以利用这些信息避免从头再去做匹配了。**

> 什么是前缀表

写过KMP的同学，一定都写过next数组，那么这个next数组究竟是个啥呢？

next数组就是一个前缀表（prefix table）。

前缀表有什么作用呢？

**前缀表是用来回退的，它记录了模式串与主串(文本串)不匹配的时候，模式串应该从哪里开始重新匹配。**

举例说明

```
要在文本串：aabaabaafa 中查找是否出现过一个模式串：aabaaf。
```

