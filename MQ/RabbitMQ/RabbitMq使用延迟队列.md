# 使用的原理


!!!重点
> 其实最主要的原理就是使用死信队列（可设置延迟时间的队列）进行转发，在延迟时间过了之后转发的目标队列。从而实现延迟


使用rabbitmq的死信队列，死信队列是可以配置消息存放的时间的，所以只要将消息先放入对应的死信队列中，然后在配置的时间过完之后，死信队列将信息放入对应的消费队列中即可完成对应的延迟消费


# 配置

修改rabbitmq的配置信息
```java

@Configuration
public class RabbitMqConfig {

    //配置交换机的名字
    public static final String EXCHANGE = "exchange";

    //【配置队列的名字】
    public static final String QUEUE_NAME_TTL = "ttl-queue";


    @Bean
    DirectExchange exchange() {
        return new DirectExchange(EXCHANGE);
    }

    //用于延时消费的队列
    @Bean
    public Queue ttlQueue() {
        Queue queue = new Queue(QUEUE_NAME_TTL, true, false, false);
        return queue;
    }

    @Bean
    public Binding ttlQueueBinding() {
        return BindingBuilder.bind(ttlQueue()).to(exchange()).with(QUEUE_NAME_TTL);
    }

    //TODO
    //配置死信队列，延迟队列的规则原理就是使用死信队列
    @Bean
    public Queue deadLetterQueue() {
        Map<String, Object> args = new HashMap<>();
        //出现dead letter之后将dead letter重新发送到指定exchange
        args.put("x-dead-letter-exchange", EXCHANGE);
        //出现dead letter之后将dead letter重新按照指定的routing-key发送
        args.put("x-dead-letter-routing-key", QUEUE_NAME_TTL);
        return new Queue("deadLetterQueue", true, false, false, args);
    }

}


```

> 重点在与配置死信队列，其中增加两个参数`x-dead-letter-exchange`和`x-dead-letter-routing-key`，指定完事之后放入的交换机和队列名

创建生产者，这里的生产者目的队列其实是死信队列。死信队列做转换到需要的队列
```java
    public void ttlProducerSend(String uuid, String content, long times) {
        MessagePostProcessor processor = new MessagePostProcessor() {
            @Override
            public Message postProcessMessage(Message message) throws AmqpException {
                message.getMessageProperties().setExpiration(String.valueOf(times));
                return message;
            }
        };
        //注意，这个地方先发送到死信队列中，之后死信队列产生延迟之后再将其放入需要的队列中进行消费
        //注意，死信队列是没有交换机的
        rabbitTemplate.convertAndSend("deadLetterQueue", (Object) content, processor);
    }
```


如上即可


坑

```
1. java操作rabbitmq，默认不配置的时候，是不会重启重新创建队列的。所以你对队列的配置修改，在重启之后是不会生效的，这个时候就需要先给队列删除掉。可以使用rabbitmq的控制台删除对应的队列。


```