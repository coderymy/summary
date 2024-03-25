`Optional` 是 Java 8 引入的一个类，用于解决 null 值引发的空指针异常问题。`Optional` 主要提供了一种方式来处理可能为null的对象，避免直接使用null引发的空指针异常。以下是 `Optional` 的一些常见用法：

1. **创建 Optional 对象：**

   ```
   javaCopy codeOptional<String> optional1 = Optional.of("Hello"); // 非空值
   Optional<String> optional2 = Optional.ofNullable(null); // 允许空值
   Optional<String> optional3 = Optional.empty(); // 创建一个空的 Optional
   ```

2. **判断值是否存在：**

   ```
   javaCopy codeOptional<String> optional = /*...*/;
   
   boolean isPresent = optional.isPresent(); // 检查值是否存在
   ```

3. **获取值（如果存在）：**

   ```
   javaCopy codeOptional<String> optional = /*...*/;
   
   String value = optional.get(); // 如果值存在，返回值；否则抛出 NoSuchElementException
   ```

4. **如果值存在则执行某操作：**

   ```
   javaCopy codeOptional<String> optional = /*...*/;
   
   optional.ifPresent(val -> System.out.println("Value is present: " + val));
   ```

5. **获取值或默认值：**

   ```
   javaCopy codeOptional<String> optional = /*...*/;
   
   String value = optional.orElse("Default Value"); // 如果值存在，返回值；否则返回默认值
   ```

6. **获取值或执行某操作：**

   ```
   javaCopy codeOptional<String> optional = /*...*/;
   
   String value = optional.orElseGet(() -> "Default Value"); // 如果值存在，返回值；否则执行 Supplier 提供的操作返回默认值
   ```

7. **获取值或抛出异常：**

   ```
   javaCopy codeOptional<String> optional = /*...*/;
   
   String value = optional.orElseThrow(() -> new IllegalStateException("Value is not present")); // 如果值存在，返回值；否则抛出异常
   ```

8. **过滤值：**

   ```
   javaCopy codeOptional<String> optional = /*...*/;
   
   Optional<String> filteredOptional = optional.filter(val -> val.length() > 5); // 如果值存在且满足条件，返回新的 Optional；否则返回空的 Optional
   ```

9. **转换值：**

   ```
   javaCopy codeOptional<String> optional = /*...*/;
   
   Optional<Integer> lengthOptional = optional.map(String::length); // 如果值存在，对其执行操作并返回新的 Optional；否则返回空的 Optional
   ```

10. **扁平化处理嵌套的 Optional：**

    ```
    javaCopy codeOptional<Optional<String>> nestedOptional = /*...*/;
    
    Optional<String> flatMapResult = nestedOptional.flatMap(Function.identity()); // 将嵌套的 Optional 扁平化为单层 Optional
    ```

这些方法可以帮助你更安全、更优雅地处理可能为 null 的值，从而避免空指针异常。在编写现代 Java 代码时，推荐尽可能使用 `Optional` 来处理可能为 null 的情况。