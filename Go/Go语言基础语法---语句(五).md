# 条件语句

## if

使用方式
```
if 布尔表达式{
    逻辑处理
}

    if a < 20 {
       /* 如果条件为 true 则执行以下语句 */
       fmt.Printf("a 小于 20\n" )
   }
```

## switch

```
switch {
      case grade == "A" :
         fmt.Printf("优秀!\n" )    
      case grade == "B", grade == "C" :
         fmt.Printf("良好\n" )      
      case grade == "D" :
         fmt.Printf("及格\n" )      
      case grade == "F":
         fmt.Printf("不及格\n" )
      default:
         fmt.Printf("差\n" );
   }
```

## select

select 随机执行一个可运行的 case。如果没有 case 可运行，它将阻塞，直到有 case 可运行。一个默认的子句应该总是可运行的。


```
   select {
      case i1 = <-c1:
         fmt.Printf("received ", i1, " from c1\n")
      case c2 <- i2:
         fmt.Printf("sent ", i2, " to c2\n")
      case i3, ok := (<-c3):  // same as: i3, ok := <-c3
         if ok {
            fmt.Printf("received ", i3, " from c3\n")
         } else {
            fmt.Printf("c3 is closed\n")
         }
      default:
         fmt.Printf("no communication\n")
   }
```

# 循环语句

## for

三种使用方式

1. `for 数值初始化;循环判断器;数值变换{逻辑处理}`与Java中的fori一致
   ```
    for i := 0; i <= 10; i++ {
                sum += i
    }
   ```
2. `for 循环判断器{逻辑语句(其中进行数值变换)}`在使用前赋值.也就是将第一种方式拆分成三块了
   ```
        sum := 1
        for ; sum <= 10; {
                sum += sum
        }
   ```   
3. `for { }`
   ```
        sum := 0
        for {
            sum++ // 无限循环下去
        }
   ```

break;语句中断当前for循环或者跳出switch循环

continue;语句标识跳出当前这轮循环,进行下一轮循环