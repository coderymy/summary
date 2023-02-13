# 问题

1、简述Synchronized、Lock的区别

> Synchronized关键字加载方法头上，会对整个方法上锁，也就是并发访问该方法只能有一个线程可以访问到。方法访问结束即释放锁。不需要开发者主动参与
>
> Lock关键字，需要手动上锁和解锁，可能会出现死锁的情况。但是使用起来锁的粒度较小较灵活

2、为什么说arrayList、hashMap是线程不安全的

因为多个线程可以同时操作这一块数组空间，所以就会出现一个线程在访问数据的同时，另外一个线程在对数据进行修改。

3、volatile关键字的工作原理

存在的目的就是为了在多线程的情况下，一个变量的变更能被别的正在访问该变量的线程察觉到。

工作原理：加上之后，任何一个线程对该变量的修改，都会通知到主线程，主线程会通知子线程作废该变量的数据。

其实不适用volatile，也可以对变量增加锁，来保证对变量的访问/修改只有一个线程可以进行

4、线程池中的工作队列和拒绝策略

拒绝策略：

AbortPolicy:丢弃任务并抛出RejectedExecutionException异常。 （默认），针对的是关键业务。如果丢弃会出现问题的情况

DiscardPolicy：丢弃任务，但是不抛出异常。针对可执行可不执行或者有补偿措施的任务，比如（只是举个例子表达程度）日志记录往IO文件里面写入，真实丢了就丢了不能因为这个导致线上系统报警吧。

DiscardOldestPolicy：丢弃队列最前面的任务，然后重新提交被拒绝的任务。喜新厌旧

CallerRunsPolicy：由调用线程（提交任务的线程）处理该任务

工作队列：

1. 有界阻塞队列：Array实现，多余的任务会创建存入队列，超过队列长度创建线程执行直到设置的最大线程数位置。再多余就会**拒绝**
2. 无界阻塞队列：Linked实现，无界，一直增长直到资源耗尽
3. 直接提交队列：没有大小，执行一个插入任务操作进行阻塞，到一个线程能执行。
4. 优先任务队列：具有优先级的无限阻塞队列



+ 直接提交队列（SynchronousQueue）：没有容量，执行一个插入操作就需要执行一个删除操作，否则就会阻塞等待；1
+ 有界任务队列（ArrayBlockingQueue）：突出的特点就是上面的**提交优先级**。任务多余corePoolSize就会存入队列中，如果超过队列就会创建线程直到达到maximumPoolSize；有限大
+ 无界任务队列（LinkedBlockingQueue）：没有maximumPoolSize的概念，队列会保存所有除了核心线程管理的任务。（易出现任务一直增长直到资源耗尽的情况）；无限大
+ 优先任务队列（PriorityBlockingQueue）：正常队列是先进先出。这个队列可以自定义任务的优先级来执行；自定义执行顺序



5、start和run方法的区别

> run方法是不会创建线程，只是主线程去执行对应的方法而已
>
> start会创建线程去执行对应的方法

6、sleep和wait的区别

> sleep是会切换线程上下文，但是不会释放锁
>
> wait目的就是释放锁让其他的线程先执行，主要用作线程之间通讯使用

7、join方法，保证线程的顺序执行



8、synchronized的实现原理

> 在同步代码块的起始位置插入了`moniterenter`指令，结束的位置插入了`monitorexit`指令。执行`moniterenter`的时候尝试获取对象的锁。如果这个锁没有被锁定或者当前线程已经拥有了那个对象的锁，锁的计数器就加1，在执行`monitorexit`指令时会将锁的计数器减1，当减为0的时候就释放锁。

9、简述CAS和AQS



第一步，知道锁怎么用—Synchronized、Lock

第二步，解析锁的一些原理—CAS、AQS等

第三部，Java6怎么优化synchronized—锁膨胀

第四步，怎么解决线程不安全的问题和线程资源不同步的问题—volatile

第五步，锁的应用场景——多线程

第六步，线程池的实现原理和关键类库—ThreadPoolExecutor

[思维导图](https://www.processon.com/view/link/6232f24a0e3e7407da5309fb)



# 1. JUC

## 1.1 概述

JUC：java.util.concurrent并发编程包

进程：系统中正在运行的一个程序。

线程：程序执行的最小单元

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/psIpjS.jpg)

Wait：Object类的方法，会释放锁（当前线程有锁的情况下）

Sleep：Thread类的方法，不会释放锁，不会占用锁

两个方法都会被interrupted方法中断



并发：多个线程访问一个资源；春运抢票

并行：多个线程一起执行一个任务，每个线程执行一部分操作；边刷牙边烧水

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/并行和并发.drawio.png)

## 1.2 Synchronized和Lock

**Sychronized**

> 使用方式

针对上锁的操作方法，可以实现每次只允许一个线程访问

```java
public sychronized int saleTicket(){
  	.....
}
```

**Lock**

> 使用方式

```java
//创建可重入锁
private final ReenrantLock lock=new ReentrantLock();

public void lockSale(){
  //加锁
  lock.lock();
  ...
  //解锁
  lock.unlock();
}
```

> 概念和实现原理

可重入锁：在进入操作方法的第一步上锁，出操作方法的最后一步解锁

> Lock和Sychronized的区别

1、`Lock`需要手动上锁和释放锁，`Sychronized`不需要手动操作（异常自动释放锁），只需要加到对应的操作方法上即可

2、`Lock`比`Sychronized`功能强大。`Lock`可扩展性更强（知道是否获取到锁、可以让那个等待线程响应中断）

3、`Lock`性能要高于`Sychronized`

## 1.3 并发编程思路

1. 创建资源类，在类中创建属性和操作方法
2. 创建多个线程，调用资源类的操作方法

针对这个操作方法赋予锁

```java
/**
 * 1. 创建资源类，创建属性和操作方法
 * 2. 创建多个线程去调用资源类的操作方法
 */
public class SaleTicket {
    public static void main(String[] args) {

        Ticket ticket = new Ticket();
        //创建多个线程，每个线程都去调用资源类的操作方法
        new Thread(new Runnable() {
            @Override
            public void run() {
                for (int i = 0; i < 10000; i++) {
                    ticket.sale();
                }
            }
        }, "A").start();
       //lambda表达式写法
        new Thread(()->{
            @Override
            public void run() {
                for (int i = 0; i < 10000; i++) {
                    ticket.sale();
                }
            }
        }, "B").start();
        new Thread(new Runnable() {
            @Override
            public void run() {
                for (int i = 0; i < 10000; i++) {
                    ticket.sale();
                }
            }
        }, "C").start();
    }

}


class Ticket {
    private int ticketNum = 10000;
    /**
     * 使用Synchronized来加锁
     * 1. 操作方法上加上synchronized关键字
     * 2. 业务操作
     */
    public void synchronizedSale() {
        //public synchronized void synchronizedSale(){}一样的操作，都是对对象加锁
        synchronized (this) {
            if (ticketNum > 0) {
                System.out.println("线程：" + Thread.currentThread().getName() + "售出第" + (10000 - ticketNum) + "张票，还剩下" + --ticketNum + "张票");
            }
        }
    }
    /**
     * 使用Lock来加锁
     * 1. 创建可重入锁
     * 2. 加锁
     * 3. 业务操作
     * 4. 解锁
     */
    private final ReentrantLock lock = new ReentrantLock();

    public void lockSale() {
        lock.lock();
        try {
            if (ticketNum > 0) {
                System.out.println("线程：" + Thread.currentThread().getName() + "售出第" + (10000 - ticketNum) + "张票，还剩下" + --ticketNum + "张票");
            }
        } finally {
            lock.unlock();
        }
    }
}

```



## 1.4 线程间通信（线程交替进行）

1. 创建资源类，在类中创建属性和操作方法
2. 操作方法
   1. 判断是否有锁（this.wait()）
   2. 业务处理
   3. 通知另一个线程 notify()
3. 创建多个线程，调用资源类的操作方法

使用`synchnorized`实现线程交替执行

`this.wait()`线程等待

`this.notifyAll()`线程唤醒

```java
/**
 * 1. 创建资源类，创建属性和操作方法
 * 2. 判断、操作、通知
 * 3. 创建多个线程调用操作方法
 */
public class AlternateThread {
    public static void main(String[] args) {
        AlternateTicket ticket = new AlternateTicket();
        new Thread(() -> {
            for (int i = 0; i < 10; i++) {
                try {
                    ticket.incr();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }, "A").start();
        new Thread(() -> {
            for (int i = 0; i < 10; i++) {
                try {
                    ticket.decr();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }, "B").start();
    }
}
class AlternateTicket {
    private int num = 10;
    public synchronized void incr() throws InterruptedException {
        //判断
        if (num > 10) {
            this.wait();
        }
        //操作
        num++;
        System.out.println(Thread.currentThread().getName() + ":" + num);
        //通知
        this.notifyAll();
    }
    public synchronized void decr() throws InterruptedException {
        //判断
        if (num <= 10) {
            this.wait();
        }
        //操作
        num--;
        System.out.println(Thread.currentThread().getName() + ":" + num);
        //通知
        this.notifyAll();
    }
}

可以看到A和B交替执行且输出10、11
```

使用`lock`实现线程交替执行

+ 使用Lock.condition()对象进行线程等待和线程唤醒
+ `lock.await()`线程等待

+ `lock.signalAll()`唤醒所有线程

```java
/**
 * 1. 创建资源类，创建属性和操作方法
 * 2. 判断、操作、通知
 * 3. 创建多个线程调用操作方法
 */
public class LockThread {
    public static void main(String[] args) {
        AlternateLockTicket ticket = new AlternateLockTicket();
        new Thread(() -> {
            for (int i = 0; i < 10; i++) {
                try {
                    ticket.incr();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }, "A").start();
        new Thread(() -> {
            for (int i = 0; i < 10; i++) {
                try {
                    ticket.decr();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }, "B").start();
    }
}

class AlternateLockTicket{
    private int num=10;
    //创建锁对象
    private final Lock lock =new ReentrantLock();
    Condition condition=lock.newCondition();
    public void incr() throws InterruptedException {
        lock.lock();
        try{
            //判断
            if (num>10){
                condition.await();
            }
            //操作
            num++;
            System.out.println(Thread.currentThread().getName() + ":" + num);
            //通知
            condition.signalAll();
        }finally {
            lock.unlock();
        }
    }
    public void decr() throws InterruptedException {
        lock.lock();
        try{
            //判断
            if (num<=10){
                condition.await();
            }
            //操作
            num--;
            System.out.println(Thread.currentThread().getName() + ":" + num);
            //通知
            condition.signalAll();
        }finally {
            lock.unlock();
        }
    }
}

```





## 1.5 集合中的线程不安全

### 1.5.1 什么叫做集合的线程不安全

问题根由：读和写操作同步执行

多个线程同时对同一个线程不安全的集合进行读和写操作导致出现`ConcurrentModificationException`异常

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/At528D.png)

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/RMZU93.png)



### 1.5.2 如何解决ArrayList的线程不安全问题

不直接使用ArrayList而是使用一些代替类

+ **Vector**：`Vector`替代`ArrayList`

  不使用`ArrayList`，而是使用`Vector`。其实现的`add`方法是加了`synchronized`关键字

  ```
  List<String> list = new Vector<>();
  ```

+ **Collections工具类**：使用`Collections.synchronizedList(new ArrayList())`

  ```
  List<String> list= Collections.synchronizedList(new ArrayList<>());
  ```

+ **CopyOnWriteArrayList**：使用JUC中的`CopyOnWriteArrayList()`

  ```
  List<String> list=new CopyOnWriteArrayList<>();
  ```

  写时复制技术：并发读，写入并不直接写入list，而是写入一个copyList然后将copyList覆盖原本的list

  进行add操作的时候

  1. 将原本的list复制出来一份copyList
  2. 在复制中的copyList进行写
  3. 写完之后与原本的那个list进行覆盖

  ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/XzaoLF.jpg)



### 1.5.2 HashSet的线程不安全问题

问题原因与ArrayList一致

CopyOnWriteArraySet：与CopyOnWriteArrayList解决方案一致



### 1.5.3 HashMap线程不安全

与ArrayList的原因是一致的

解决：

ConcurrentHashMap：在进行元素添加的时候增加了`synchronized`关键字

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/4uRXwn.png)

## 1.6 Callable接口

创建线程的一种方式

优点：可以在线程结束之后获取到返回值

> Runnable接口和Callable接口区别

1. 后者有返回值
2. 如果出现异常会抛出

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/XWWaYA.jpg)



> 创建Callable[的线程实现]()

使用`FutureTask`未来任务（就是可以支持另一个线程执行完成之后应该怎么做，比如下单，我需要扣完库存、扣完款才能给这个人发货。这个时候需要等待“扣库存”和“扣款”结束之后“发货”）

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/ZCJhsY.png)

## 1.7 辅助类

**countdownLatch**计数器

直到所有线程运行一定次数才执行await里面的方法

1. 使用
2. 每个线程调用countDown使计数器-1
3. 调用await方法，使值减到0的时候执行其中的代码

**cyclicBarrier**循环栅栏

让所有线程都等待，直到所有线程都达到一个固定的点才执行barrierAction方法



相当于多段操作，每段操作使用await()方法阻塞等待在那。比如部队里士兵训练。当所有士兵都跑完步才开始去往食堂，当所有士兵都打完饭才开始吃饭，当所有士兵都吃完饭才去洗澡

需要注意的是，协调好ThreadSize、PartiesSize、TaskSize之间的关系，不然就会导致永远等待

**semaphore**信号灯

多个资源被相互竞争，只有一个线程释放占用的资源，才能会有一个线程能占用这个资源

汽车抢占车位



# 2. 多线程锁

需要先理解下面几个概念 Synchronized、CAS、AQS、volatile等

## 2.1 锁的分类

> 首先先声明一个事情。这些这锁那锁其实本身不存在这些锁，也就是说他们不是名词，应该说他们是动词。他们是用来解决各种问题而提出来的各种解决方案。

+ 自旋锁和适应性自旋锁（是否放弃已获取的CPU资源来等待阻塞）

+ 无锁、偏向锁、轻量级锁、重量级锁（按照锁的资源消耗来区分）

+ 公平锁、非公平锁（多个线程对同一资源竞争是否公平）

+ 可重入锁、非可重入锁（多个锁的嵌套是否允许获取一把钥匙打开所有锁）

+ 独享锁、共享锁（写锁和读锁）

+ 乐观锁、悲观锁（乐观（亡羊补牢）和悲观（殚精竭虑）的看待是否会被别人修改数据这回事）

### 2.1.1 乐观锁和悲观锁

**悲观锁**

每个线程对同一个资源进行操作的时候，都需要进行加锁，使用完资源之后释放锁。

优点：解决所有并发问题

缺点：不支持并发执行，效率很低

**乐观锁**

对同一个数据操作的时候，记录一个版本号。每次进行修改的时候更新这个版本号。然后所有线程进行更新操作的时候都需要判断该版本号和第一次获取的时候的版本号是否一致



![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/vjTUx4.png)



### 2.1.2 自旋锁和适应性自旋锁

> 两者关系

后者是前者的补充（优化）

> 自旋锁的由来

线程1和线程2竞争锁。线程1没有获得锁，但是如果这个时候切换CPU去执行线程2释放锁。可能切换还没完成线程2就释放了锁。又得切换回来。所以如果CPU是多核的，就不如直接**线程1先自己玩会并循环看着这个资源的释放（自旋）来获得锁**

适应性自旋锁就是：线程1告诉了线程3我等了一会就等到了资源的释放，你也等会。本来线程3想等10。结果听了这话觉得有门，就准备等20s。（反之也是一样，线程1告诉线程3我等了10s还没等到，那你觉得线程3应该怎么办？）这里的10s只是举例子，默认是指自旋10次

所以**自旋锁的本质其实是锁的优化**也是一种乐观锁的实现过程

> 自旋锁的优缺点

如果这种代码执行的很快（锁释放的很快），这就避免了切换CPU带来的资源消耗。这就是优点

优点带来了缺点，如果这块代码执行的很慢，或者很多的线程竞争这个资源，这个时候就会导致这个自旋的线程一直消耗CPU资源在这玩不干活。

> 自旋锁的使用

在JDK1.4.2到JDK1.6之间的版本，需要手动使用`-XX:+UseSpinning`来开启。如果是JDK1.6之后就是默认开启的（自适应自旋锁）

### 2.1.3 无锁、偏向锁、轻量级锁、重量级锁

> 区分原因

按照锁对资源消耗的级别区分：一般能用低级就不用高级

> 四锁的概念

无锁（直接放行）：没有对资源进行锁定，所有线程访问同一个资源。但是同时只有一个线程进行修改。循环修改的一种实现 CAS就是无锁

偏向锁（有吊牌）：这个关键代码只有一个线程会访问。那么这个访问的时候看到是这个线程，就自动给他锁而不用检查锁的状态（相当于管大门的认识了老王，就不需要登记就直接放行）

轻量级锁（需要登记）：有一个线程访问偏向锁，偏向锁发现这个线程不是我等的那个线程，所以就将该锁进化成轻量级锁。其他线程需要进行自旋等待来尝试获取锁（多个线程的多次CAS）（门卫本来以为只有老王会来，结果来了老杨，就让后面来的都进行登记并且玩会手机等着老杨出来才能进入）

重量级锁（厕所关门）：就是遇到没有钥匙就得阻塞该线程，CPU切换到别的线程执行（门卫跟老杨说，今天只能老王进来，你明天再来吧）

> 四锁的关系

这个过程可以称为锁的升级，也可以称为锁的膨胀

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/四级别锁.drawio.png)

只能正向升级，不能降级。

`偏向锁`相对于`无锁`增加了**Mark Word**来标示锁

`轻量级锁`相对于`偏向锁`增加了**自旋锁（适应性自旋锁）**操作来竞争锁

`重量级锁`相对于`轻量级锁`增加了阻塞等待或者说悲观锁来实现

> 四锁的实现

**锁的实现**

锁存放在对象头的`Mark word`中（对象存放在堆中，对象包含对象头、实例数据、对齐填充），对象头包括`Mark word`，类指针，arrayLength（数组的时候有数组长度）。

![](/Users/kaochong/Documents/锁.drawio.png)

markword的最后两位：

| 锁类型   | 锁标示 | 对象头中存储的内容（依次增加）                   |
| -------- | ------ | ------------------------------------------------ |
| 无锁     | 01     | 1. hashCode<br>2. 分代年龄<br>3. 是否是偏向锁(0) |
| 偏向锁   | 01     | 4. 偏向线程<br>5. 偏向时间戳<br>6. 是偏向锁（1） |
| 轻量级锁 | 00     | 指向栈中Monitor的指针                            |
| 重量级锁 | 10     | 指向重量级锁的指针                               |

**无锁**：通过不断的尝试修改进行对同一个资源的修改

**偏向锁**：通过记录偏向锁的线程id，来允许对应线程直接访问资源。而如果出现一个其他线程访问。两种情况

+ 仍然是偏向锁：将该次访问的线程id记录下来。之后该偏向锁归该线程id所有（老王儿子来了）
+ 不是偏向锁：升级成轻量级锁（门卫看管严了）

具体偏向锁升级成轻量级锁可以看[大佬：java 偏向锁怎么升级为轻量级锁](https://www.cnblogs.com/baxinhua/p/9391981.html)

这里有一个暂停原始线程的一个过程

对象头中存储的一些信息这里偏向锁用到的有这几个

+ 锁标志位
+ 是否是偏向锁
+ 偏向锁的线程ID

如果`锁标志位`是01，就去判断`是否是偏向锁`的值来决定是不是偏向锁。如果是，就去比较当前获取锁的ID是否是`偏向锁的线程ID`如果是就直接放行允许获取锁。

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/eB9Get.jpg)

**轻量级锁**：多个线程访问同一个资源，使用自旋的方式进行等待。如果自旋超过一定的次数。对于其他线程来说，就会将该锁升级成重量级锁

**重量级锁**：阻塞等待，平常意义上的锁。CPU切换去干别的事情



### 2.1.4 公平锁和非公平锁

> 原理举例

**公平锁**：多个线程对锁的竞争是差不多公平的

A执行了20次，B执行了19次，C执行了19次

特点：各个线程都会有执行的可能，但是效率相对于较低

实现逻辑：其中有个方法将多个线程放入队列中进行排队执行

**非公平锁**：

多个线程对锁竞争是不公平的

A执行20次，B执行0次，C执行1次

特点：锁的竞争很不公平，但是执行的效率较高

实现逻辑：直接进行业务执行，哪个线程能竞争到锁随意

`new ReentrantLock()`的构造方法中可以传入`boolean`参数，`false`（默认）表示非公平锁

> 公平锁优缺点

优点：不会出现有的线程被饿死的情况

缺点：效率相对于而言低一些。需要不停的唤醒阻塞线程

> 公平锁实现

通过维护一个线程的队列。每次获取锁必须是排队的第一个，释放锁之后就自动去队列末尾继续排队等待



### 2.1.5 可重入锁和非可重入锁

> 概念和实例

递归锁：一个线程在外层获取到锁之后进入内层会自动获取锁（锁的对象是同一个）。

```java
public void static main(String[] args){
  synchronized (this){
     //xxxxx
    synchronized(this){
      //xxxxx
    }
  }
}
```

锁的内部如果还有锁，该线程都可以访问。也就是多重锁，只要线程竞争到了锁资源，就可以访问到最内部也不用再重新竞争锁

`synchronized`是隐式的可重入锁

`ReentrantLock`是显式（需要手动上锁和解锁）的可重入锁

`	NonReentrantLock`不可重入锁。



ReentrantLock和NonReentrantLock都继承AQS，其中维护了一个status来记录重入次数。

> 优点

优点：一定程度降低死锁的情况

## 2.2 **锁的范围（对象实例和类对象）**

普通方法上加上`synchronized`锁住的是**单独对象**的这个方法

静态方法（static）加上`synchronized`锁住的是**所有对象**的这个方法

## 2.5 死锁

多个进程在争夺资源时候，造成一种相互等待的现象

## synchronized

> 实现原理

反编译的结果发现`monitorenter`和`monitorexit`将一块代码块包裹起来

在方法内部的synchronized：

+ `monitorenter`，针对监视器锁monitor（具体需要看synchronized的位置）

  如果monitor的进入数为0，则该线程可以进入，进入之后将其加1

  如果这个线程重新进入，则可以进入并再进行+1

  如果有别的线程占用monitor，则该线程阻塞，直到monitor变成0才可以进入

+ `monitorexit`，执行monitorexit必须是monitor的持久者，每次执行将monitor的进入数-1，直到减成0退出锁定状态。

在方法上的synchronized：

没有上述两个指令，只是在方法定义上有`ACC_SYNCHRONIZED`关键字，当方法调用时，会查看该线程是否获取了monitor，如果有就执行，没有就阻塞

## CAS

> 什么是CAS

CAS全称Compare And Swap（比较和交换），乐观锁的一种实现，无锁算法。无锁的情况下实现多线程之间的变量同步。



> 为什么要有这种东西？

我也好恨啊，为什么有这么多晦涩难懂的东西，学的烦死了烦死了

为了无锁的访问共享资源而不出现问题。	

那么为什么要无锁呢？为了免除加锁使用操作系统的mutex这种操作，避免内核态和用户态的频繁切换带来了效率的损耗

> CAS算法原理

涉及三个操作数

+ 需要读写的内存值V
+ 用来进行比较的A
+ 需要写入的新值B

```
讲个故事：小红有三个追求者小甲、小乙、小丙

小红发了个朋友圈，“今天看上了一款丝袜叫做巴黎世家”

小甲、小乙、小丙第二天都拿着买好的礼物去登门拜访。结果小甲先到就带走了小红共进晚餐。然后小乙、小丙拿着巴黎世家去找小红，小红说我现在已经不喜欢这个了，我喜欢前男友面膜，于是乎小乙、小丙买到了前男友面膜又去找小红。小乙先到了共进晚餐。小丙拿着前男友面膜去找小红，小红说我现在不想要了我想要迪奥999

这里的小红是一个共享资源
小甲、小乙、小丙是三个线程
小红想要的：巴黎世家、前男友面膜、迪奥999是需要读写的内存值V

小甲、小乙、小丙他们拿的礼物是用来进行比较的A

需要写入的新值B是小红的下一个想法
```



第一步：进入一个CAS循环

第二步：判断A是否等于V。等于则B替换V。不等于则将V赋值给A

第三步：再进入一个CAS循环

```java
1. V=10，线程1想要去对V进行自增1，所以线程1的A=10
2. 线程2已经进行了自增，此时V=11
3. 线程1发现，A!=V。所以将V赋值给A，则A=11
4. 线程1再进行判断交换
  
//含义就是下面的代码（啥也不是的代码）这个代码是原子的
public JNI Integer cas(int A,int B){
  if(A=v){
    v1=v;
    v=B;
    return v1;
  }else{
    A=V;
    return false;
  }
}
```

当且仅当V=A时（比较），将B替换V（替换）。**这个操作在Java的底层借助于一个CPU指令完成的。属于原子操作**，所以不会出现比较了还没更新另一个更新的情况。在更新的过程中可能会出现长时间的自旋来等待结果

> CAS的三大问题

1、ABA问题：就是内存中的值从A->B->A这个时候另一个线程就以为这个A是没有发生变化的，就可能会造成业务性的错误。解决办法就是增加版本号的概念 1A->2B->3A

2、循环时间长开销大：多个线程进行修改，可能会导致线程之间反复更新一直不成功

3、只能保证一个共享变量的原子操作：Java本身支持的只针对一个变量的修改可以进行CAS操作。不支持多个变量或者多个对象等的修改。（JDK1.5AtomicReference类可以保证对象之间原子性从而将多个变量放到对象中）

> CAS的原子性

依赖于底层的操作系统实现。也就是每种操作系统都有一个原语对应着CAS的操作。比如X86架构的cmpxchg。

> CAS的实现`AtomicInteger`

可以做到并发的情况下进行自增线程之间进行信息同步

```java
    public final int incrementAndGet() {
        return unsafe.getAndAddInt(this, valueOffset, 1) + 1;
    }    
public final int getAndAddInt(Object var1, long var2, int var4) {
        int var5;
        do {
            var5 = this.getIntVolatile(var1, var2);
        } while(!this.compareAndSwapInt(var1, var2, var5, var5 + var4));

        return var5;
    }

    public final native boolean compareAndSwapInt(Object var1, long var2, int var4, int var5);

do-while就是自旋
compareAndSwapInt就是CAS的原子操作
native就是本地方法C++实现

```

## AQS

`java.util.concurrent.locks.AbstractQueuedSynchronizer`

> 问题：为啥要有AQS

1、（业务不通用）虽然有了底层的CAS算法，但是开发者直接使用unsafe.compareAndSwap()并不能很切合的与业务结合。我们需要开发针对各种参数的实现方法compareAndSwapInt、compareAndSwapLong等

2、（锁定的太局限）CAS底层只针对一个值进行了管理。如果我们想要锁定的是一个对象或者说一堆值呢

AQS就是为了解决上述问题而出现的

> 问题：AQS是什么

AQS就是一个CAS算法的业务上层的真实实现的类库，为了解决CAS只能面向一个值锁定的通用性问题

> AQS的实现原理

AQS有两个关键的成员变量

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/Q82qSG.png)

1. FIFO的双向链表队列。用于在阻塞的时候进行排队等待
2. 一个state，用于标示是否持有锁，及持有锁的次数。释放锁state就是0 其他线程就可以抢这个锁。这个锁是乐观锁的CAS实现的



锁肯定有这种方法，获取锁

在AQS中的实现是`acquire`（尝试获取锁，如果获取不到就等待直到获取到锁）和`tryAcquire`（尝试获取锁，获取到获取不到都返回）

```java
//获取锁
public final void acquire(int arg) {
          //尝试获取锁，如果获取不到就执行下面的代码（这里其实就是第一个判断条件不满足时就会执行下面的判断条件，是一种简单的判断写法）
    if (!tryAcquire(arg) &&
				//上面tryAcquire返回false就导致!false=true。所以就会执行acquireQueued(addWaiter(Node.EXCLUSIVE), arg)这个方法。下面这个方法就是将当前线程封装加入到等待队列
        acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
        selfInterrupt();
}

final boolean acquireQueued(final Node node, int arg) {
    boolean failed = true;
    try {
        boolean interrupted = false;
        for (;;) {
            final Node p = node.predecessor();
            if (p == head && tryAcquire(arg)) {
                setHead(node);
                p.next = null; // help GC
                failed = false;
                return interrupted;
            }
            if (shouldParkAfterFailedAcquire(p, node) &&
                parkAndCheckInterrupt())
                interrupted = true;
        }
    } finally {
        if (failed)
            cancelAcquire(node);
    }
}

private Node addWaiter(Node mode) {
    Node node = new Node(Thread.currentThread(), mode);
    // 将当前节点插入尾节点的方法：获取尾节点的指针，将当前节点的前指针指向尾节点的。原本尾节点的后指针指向当前节点
    Node pred = tail;
    if (pred != null) {
        node.prev = pred;
        if (compareAndSetTail(pred, node)) {
            pred.next = node;
            return node;
        }
    }
  //如果尾节点不存在，就进行完整的入队操作
    enq(node);
    return node;
}
```

+ 队列中只有head节点在自旋获取锁，其他的节点都被挂起
+ 在正在操作共享资源的线程被释放的同时唤醒所有挂起的线程并执行头节点



## Reentrantlock

Reentrantlock实现的Lock接口中的方法

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/WX20220317-113936@2x.png)

condition是用来针对获取了锁的线程，想要实现一种业务逻辑（等待一些其他的触发条件来触发继续执行）。相当于已经获取了锁的一种线程等待功能



## volatile

> 多线程下变量的不可见性

```java
//        private static volatile int count = 0;
    private static int count = 0;

    public static void main(String[] args) throws InterruptedException {
        new Thread(() -> {
            try {
                Thread.sleep(1000);
                count++;
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println("附加线程count=" + count);
        }).start();
        while (true) {
            if (count > 0) {
                System.out.println("变更后主线程中count=" + count);
                break;
            }
        }
    }
```

参考上面代码。在先让线程A执行，再执行其他线程对变量进行修改，就会导致A获取的变量参数不会随着修改而改变。如果增加volatile之后发现，A获取的参数会随着其他线程的修改而被通知到。

总结：线程1获取了变量的值。线程2对变量进行了修改，此时线程1再次获取仍然使用的是原本获取的值。

> 不可见性的原因

![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/线程变量不可见性原因.drawio.png)



总结：共享变量存储在主内存中，每个线程都有自己的工作内存。主内存的数据修改不会主动同步到试用这个数据的线程独有的工作线程中。

> 解决不可见性

**1、加锁访问共享变量**

```java
    private static int count = 0;

    public static void main(String[] args) throws InterruptedException {
        Thread t = new Thread(() -> {
            try {
                Thread.sleep(1000);
                count++;
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println("附加线程count=" + count);
        });
        t.start();
        while (true) {
            synchronized (t) {
                if (count > 0) {
                    System.out.println("变更后主线程中count=" + count);
                    break;
                }
            }
        }
    }
```

锁住的是对成员变量获取的那个线程（不是修改的线程）

原因：一个线程进入synchronized代码块后执行过程

1. 获取锁对象
2. 清空工作线程
3. **拷贝共享变量到工作内存（也就是重新获取，而不是直接使用工作内存中的数据）**所以每次进行while循环都会重新获取一次。
4. 执行代码
5. 将修改后的值刷新的主内存
6. 释放锁

**2、对共享变量增加volatile关键字修饰**

```java
    private static volatile int count = 0;
//    private static int count = 0;

    public static void main(String[] args) throws InterruptedException {
        Thread t = new Thread(() -> {
            try {
                Thread.sleep(1000);
                count++;
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println("附加线程count=" + count);
        });
        t.start();
        while (true) {
            if (count > 0) {
                System.out.println("变更后主线程中count=" + count);
                break;
            }
        }
    }
```

原因：

**<font color="red">volatile修饰的变量发生修改并通知到主内存之后，“主内存”会通知所有使用该变量的线程作废该变量在其工作内存中的值</font>**

主线程中的值失效之后，就必须得去主内存中重新获取值





> Volatile的特性

**1、volatile不能保证原子性操作**

原子性：一次操作中的所有行为，要么全部成功要么全部失败，且该线程期间状态一致。

```java
    private volatile static Integer count = 0;

    public static void main(String[] args) throws InterruptedException {
        for (int i = 0; i < 100; i++) {
            new Thread(() -> {

                for (int j = 0; j < 10000; j++) {
                    count++;
                }
            }, String.valueOf(i)).start();
        }
        Thread.sleep(10000);
        System.out.println(count);
    }

export:978024
```

为什么：因为被volatile修饰的count进行自加并不是原子操作，需要先从主内存读取数据到工作内存，然后自增，然后将数据写回主内存。在这个过程中，如果有两个线程同时将数据从100自增到101，然后写入主内存，就会出现问题。结果只增加了一次。即使增加了volatile，也只是保证共享变量在所有线程的可见，而不能保证顺序执行

解决办法：加锁来解决原子性的问题



**2、禁止指令重排序**

什么是重排序：编译器、指令解释器、操作系统等，为了更好的执行代码提升性能，可能会对代码的指令进行优化排序。如JIT，缓冲区，指令重排序等。

重排序的问题：有些冲排序的情况会导致不按照代码的想法进行执行。比如CPU认为指令顺序调整之后对业务信息和逻辑没有影响。但是在高并发的情况下可能就会出现影响。这个时候如果CPU进行了代码优化，则可能会导致业务问题。（比如a=b;b=1;b=a调整了顺序就会出现结果不一致的问题）

解决重排序：在要修改的变量上增加volatile来避免指令重排序。





# 3. 线程池

存在的意义：

1、为了简化对线程的操作

2、为了减少开发人员创建线程过多而带来问题

3、为了减少在需要创建多个线程的时候，带来时间的开销



> 如何使用线程池

**使用Executors创建线程操作**

实际开发中不建议使用，因为各种方法的创建都有局限性，不能满足多变业务情况的需要。

1、创建线程池对象

```java
//根据传入的参数固定线程数，也就是给定的线程数越多处理线程越多。然后工作队列会按照线程数每次分配固定的任务数。缺点：线程处理不过来任务，任务就放到了队列中。会导致队列占用内存过大导致OOM
ExecutorService newFixedThreadPool = Executors.newFixedThreadPool(100);
//没有核心线程，最大线程为2^31-1。且队列为非阻塞队列。也就是任务再多也没有上限，不会出现线程等待的情况。缺点：易出现CPU满（不安全，线程的创建被业务关联，容易造成CPU卡死，比如我100万个任务，可能就创建超过50w的线程，线程是被CPU调度执行的，和内存没关系。）
        ExecutorService newCachedThreadPool = Executors.newCachedThreadPool();
//线程池中只有一个线程，依次处理。缺点：线程处理不过来任务，任务就放到了队列中。会导致队列占用内存过大导致OOM	
        ExecutorService newSingleThreadExecutor = Executors.newSingleThreadExecutor();
```

2、使用线程池提交线程任务

```java
newFixedThreadPool.execute(new MyTask(i));
```



**自定义的线程管理对象**

直接调用`ThreadPoolExecutor`创建线程池管理对象。根据业务的特性设置其corePoolSize、maximumPoolSize等参数，所以这个时候就需要深入理解`ThreadPoolExecutor`。



## 3.1ThreadPoolExecutor

上面的newFixedThreadPool、newCachedThreadPool、newSingleThreadExecutor其底层都是调用的`ThreadPoolExecutor`构造方法

```java
    public ThreadPoolExecutor(int corePoolSize,
                              int maximumPoolSize,
                              long keepAliveTime,
                              TimeUnit unit,
                              BlockingQueue<Runnable> workQueue,
                              ThreadFactory threadFactory,
                              RejectedExecutionHandler handler) {
        if (corePoolSize < 0 ||
            maximumPoolSize <= 0 ||
            maximumPoolSize < corePoolSize ||
            keepAliveTime < 0)
            throw new IllegalArgumentException();
        if (workQueue == null || threadFactory == null || handler == null)
            throw new NullPointerException();
        this.acc = System.getSecurityManager() == null ?
                null :
                AccessController.getContext();
        this.corePoolSize = corePoolSize;
        this.maximumPoolSize = maximumPoolSize;
        this.workQueue = workQueue;
        this.keepAliveTime = unit.toNanos(keepAliveTime);
        this.threadFactory = threadFactory;
        this.handler = handler;
    }
```

+ corePoolSize，核心线程数。可以理解成初始化线程数量
+ maximumPoolSize，最大允许创建的线程数。在核心线程数之外，如果不满足业务需要，就会继续创建线程。直到线程总数达到该值为止。
+ keepAliveTime，线程空闲多久释放
+ unit，keepAliveTime的单位
+ workQueue，工作队列，也就是任务超过了每个线程执行一个的时候进行阻塞等待时的队列
+ threadFactory，线程工厂，创建线程的地方
+ handler，如果任务超过阻塞队列允许承受的最大范围，选择的四种拒绝策略

概述任务的执行（100个任务，corePoolSize=10、maximumPoolSize=50、keepAliveTime=10s、workQueue.size()=10）：

1、将任务分配给10个核心线程进行执行（0-10）

2、将剩下90个任务放到workqueue中，发现只能放十个（10-21）

3、没记录一个任务就创建一个线程，直到新创建的线程+核心线程数=maximumPoolSize=50为止。这个时候是（21-70）

4、发现还有没办法分配的任务，直接抛出异常，异常处理方式就俺咋后配置的handler拒绝策略来执行

### 3.1.1提交优先级和执行优先级

队列为ArrayBlockingQueue时（基本原理，不同的队列可能根据参数导致结果不太一样）

提交优先级：

1、核心线程

2、工作队列

3、非核心线程

执行优先级

1、核心线程

2、非核心线程

3、工作队列

100个糖小明往嘴巴里塞了第1-10（**core线程**）颗，往妈妈口袋里塞了第11-20（**工作队列**）颗。然后发现塞不下了，就喊了妹妹小红（**新建的线程**）过来一起吃，小红就往嘴里也塞了第21-30颗。然后剩下就不要了。

这个时候糖被拿出来的顺序是1-10->11-20->21-30

但是糖被吃掉的顺序是1-10->21-30->11-20

### 3.1.2 拒绝策略

AbortPolicy:丢弃任务并抛出RejectedExecutionException异常。 （默认），针对的是关键业务。如果丢弃会出现问题的情况

DiscardPolicy：丢弃任务，但是不抛出异常。针对可执行可不执行或者有补偿措施的任务，比如（只是举个例子表达程度）日志记录往IO文件里面写入，真实丢了就丢了不能因为这个导致线上系统报警吧。

DiscardOldestPolicy：丢弃队列最前面的任务，然后重新提交被拒绝的任务。喜新厌旧

CallerRunsPolicy：由调用线程（提交任务的线程）处理该任务

### 3.1.3 工作队列workQueue

+ 直接提交队列（SynchronousQueue）：没有容量，执行一个插入操作就需要执行一个删除操作，否则就会阻塞等待；1
+ 有界任务队列（ArrayBlockingQueue）：突出的特点就是上面的**提交优先级**。任务多余corePoolSize就会存入队列中，如果超过队列就会创建线程直到达到maximumPoolSize；有限大
+ 无界任务队列（LinkedBlockingQueue）：没有maximumPoolSize的概念，队列会保存所有除了核心线程管理的任务。（易出现任务一直增长直到资源耗尽的情况）；无限大
+ 优先任务队列（PriorityBlockingQueue）：正常队列是先进先出。这个队列可以自定义任务的优先级来执行；自定义执行顺序

## 3.2 开启/关闭线程池

### 3.2.1 execute和submit提交（开启线程池）任务的区别

runnable和callable的最大区别就在于callable可以获取到线程执行的结果

execute：（执行没有返回值）只能执行runnable类型的任务

submit：（执行有返回值）两种都可以，submit有返回值，返回的是一个 future，也就是线程执行完成之后可以调用future中的get方法来显示的告诉开发者线程执行的顺利。

### 3.2.2 关闭线程池

Shutdown：会等任务都执行完成之后再关闭线程池

shotdownNow：遍历线程池中的所有线程，循环调用线程的`interrupt`方法。使线程结束并关闭线程池。



# 4. 并发集合





# 问题

## Thread_wait和sleep的区别

1. 继承的类不同

   wait来自Object类

   sleep来自Thread类

2. 锁的释放

   wait会释放锁

   sleep不会释放锁

3. 使用范围不同

   wait必须在同步代码块中

   sleep可以在任何地方

4. 异常

   wait不需要捕获异常

   sleep需要捕获异常



## 锁优化_为什么要有锁的优化，为什么Java6要增加锁的复杂度

Java线程其实是对操作系统线程的一个**映射**，所以每当挂起或者唤醒一个线程都要**切换操作系统的内核态**。这种切换是重量级的，在很多时候**切换消耗的时间反倒低于本身线程执行需要的时间**。这样就会导致使用**synchronized**会对程序的性能产生很多的影响。



从Java6开始对Synchronized进行了很多优化。引入了`无锁`，`偏向锁`，`轻量级锁`，`重量级锁`。就是为了各种业务的场景来完成对应的优化



## Thread_AtomicInteger

原子性操作，底层使用CAS



学习自：

[大佬博客：CAS(乐观锁)以及ABA问题](https://blog.csdn.net/wwd0501/article/details/88663621)

[美团技术团队：不可不说的Java“锁”事](https://tech.meituan.com/2018/11/15/java-lock.html)

[大佬：java 偏向锁怎么升级为轻量级锁](https://www.cnblogs.com/baxinhua/p/9391981.html)

[大佬：JAVA锁的膨胀过程和优化(阿里)](https://www.cnblogs.com/aspirant/p/11705068.html)

[大佬：线程池的拒绝策略使用时机](https://blog.csdn.net/weixin_36296983/article/details/114762668)

[大佬：ThreadPoolExecutor](https://www.cnblogs.com/dafanjoy/p/9729358.html)

[bilibili寒食君](https://www.bilibili.com/video/BV1xT4y1A7kA?spm_id_from=333.999.0.0)

