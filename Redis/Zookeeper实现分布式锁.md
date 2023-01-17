# 2. Zookeeper实现分布式锁

# 2.1 分布式锁的使用场景
案例：需要生成订单号。使用UUID、时间错+业务id（唯一，不允许重复）
幂等：不重复，唯一
## 2.1.1 生成订单号
```java
public class OrderNumGenerate{
    private int count;
    
    public String getNumber(){
        SimpleDataFoemat simpt=new SimpleDataFormat("yyyy-MM-dd hh-mm-ss");
        return simpt.format(new Date())+"-"+ ++count;
    }
}

```
## 2.1.2 问题
### 线程安全问题

生成订单号，使用多线程的方法会出现线程安全问题。也就是在同一时间生成的时间戳等，可能会导致生成的订单号并不唯一。可能会出现很多的相同的

**所以多线程共享同一个全局变量，可能会受到其它线程的干扰，这就是线程安全的问题**



## 2.2 Zookeeper

### 2.2.1 什么是Zookeeper

是一个分布式协调工具，可以实现很多功能，比如注册中心，分布式锁，负载均衡命名服务，分布式通知/协调，发布订阅（MQ），集群环境的选举策略（哨兵机制）
### 2.2.2 zk的存储结构

![dfa70353567bf7975138f2256f8ac8d5.png](en-resource://database/648:1)
## 2.3 Zookeeper实现分布式锁

## 2.3.1 概念
1. 使用zk创建临时节点
2. 谁能创建节点成功，谁就可以拿到锁，就能生成订单号。
3. 释放锁，临时节点。（和会话连接保持一样的状态，只要会话结束，就会删除这个临时节点）

总结： 在zk上创建临时节点，只要谁能创建节点成功，其它没有创建成功就等待。其它服务器使用事件监听，获取节点通知。只要节点被删除，就应该去获取锁资源


## 2.4 代码实现

### 导入依赖
```xml
          <dependency>

               <groupId><u>com</u>.101tec</groupId>

               <artifactId><u>zkclient</u></artifactId>

               <version>0.10</version>

          </dependency>
```
### 创建锁的接口
```java
public interface Lock {

    //获取到锁的资源

     public void getLock();

    // 释放锁

     public void unLock();

}

```

### 创建实现类
```java
//将重复代码写入子类中..
public abstract class ZookeeperAbstractLock implements Lock {
      // <u>zk</u>连接地址
      private static final String CONNECTSTRING = "127.0.0.1:2181";
      // 创建<u>zk</u>连接
      protected ZkClient zkClient = new ZkClient(CONNECTSTRING);
      protected static final String PATH = "/lock";
      public void getLock() {
            if (tryLock()) {
                  System.out.println("##获取lock锁的资源####");
            } else {
                  // 等待
                  waitLock();
                  // 重新获取锁资源
                  getLock();
                  //也就是等待到信号量通知可以获取锁了，然后继续获取锁。这里并没有导致死循环，因为只要获取到锁，就会输出，从而不会继续执行else的代码
            }
      }
      // 是否获取锁，获取锁成功true，失败false
      abstract boolean tryLock();
      // 等待
      abstract void waitLock();
      public void unLock() {
            if (zkClient != null) {

                  zkClient.close();
                  System.out.println("释放锁资源...");
            }
      }
}

```

### 创建子类，来实现tryLock()和waitLock()方法
```java
public class ZookeeperDistrbuteLock extends ZookeeperAbstractLock {
      private CountDownLatch countDownLatch = null;
      @Override
      boolean tryLock() {
            try {
            //这里进行尝试创建锁，也就是使用同一个path创建锁，成功这里就返回true。继续指向上一个类的方法。否则返回false  
                  zkClient.createEphemeral(PATH);
                  return true;
            } catch (Exception e) {
//                e.printStackTrace();
                  return false;
            }

      }
      @Override
      void waitLock() {
                  //创建一个事件监听的方法
            IZkDataListener izkDataListener = new IZkDataListener() {
                        //当监听的节点被删除的时候走这里
                  public void handleDataDeleted(String path) throws Exception {
                       // 监听到节点被删除了，就唤醒被等待的线程
                       if (countDownLatch != null) {
                             countDownLatch.countDown();
                       }
                  }
                  //当监听的方法被修改走这里
                  public void handleDataChange(String path, Object data) throws Exception {
                  }
            };
            // 注册事件
            zkClient.subscribeDataChanges(PATH, izkDataListener);
            if (zkClient.exists(PATH)) {
            //也就是已经有人在用这个锁，就创建信号量
                  countDownLatch = new CountDownLatch(1);
                  try {
                       countDownLatch.await();
                  } catch (Exception e) {
                       e.printStackTrace();
                 }
            }
            // 删除监听
            zkClient.unsubscribeDataChanges(PATH, izkDataListener);
      }
}
```

### 测试
```java
public class OrderService implements Runnable {
      private OrderNumGenerator orderNumGenerator = new OrderNumGenerator();
      // 使用lock锁
      // private java.util.concurrent.locks.Lock lock = new ReentrantLock();
      private Lock lock = new ZookeeperDistrbuteLock();
      public void run() {
            getNumber();
      }
      public void getNumber() {
            try {
                  lock.getLock();
                  String number = orderNumGenerator.getNumber();
                  System.out.println(Thread.currentThread().getName() + ",生成订单ID:" + number);
            } catch (Exception e) {
                  e.printStackTrace();
            } finally {
                  lock.unLock();
            }
      }
      public static void main(String[] args) {
            System.out.println("####生成唯一订单号###");
//          OrderService orderService = new OrderService();
            for (int i = 0; i < 100; i++) {
                  new Thread( new OrderService()).start();
            }
      }
}
```


# 总结

## 为什么需要使用分布式锁
使用最多的一个例子就是，在并发的情况下，创建业务id。使用时间戳或者怎么样，可能会创建重复的业务id。所以需要使用分布式锁来锁住正在创建的业务id。以防止创建相同的id
## 什么是Zookeeper
Zookeeper是分布式的一套协调工具，它支持了很多的分布式解决方案。如注册中心，分布式锁，负载均衡命名服务，分布式通知/协调，发布订阅（MQ）等等。都可以得到解决

## 使用Zookeeper实现分布式锁的原理

### 创建锁
使用相同点路径创建节点。由于相同路径的节点只能存在一个。所以别的线程去创建已经存在的节点的时候就会失败。这个时候就让线程进入等待，知道该线程代码执行完毕，才释放这个节点，这个时候使用事件监听 的方法。只要监听到节点的删除，就唤醒别的线程来创建这个节点。这里线程的唤醒与等待，使用了信号量的概念。

### 释放锁
由于创建的是临时节点，所以只要断开客户端的链接，就会使这个节点被删除

释放锁，临时节点。（和会话连接保持一样的状态，只要会话结束，就会删除这个临时节点）。