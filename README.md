amqp-jruby-bug-example
======================

This project helps demonstrate a multi-threading bug with AMQP gem and JRuby occurring within EventMachine.

# How to use

1. Change the RabbitMQ server `bin/produce.rb` and `bin/test_amqp.rb` to point to your RabbitMQ server.
2. Setup a new topic **Exchange**: `amqp.command.test` and a **Queue** bound to this using the routing key `#` named: `test.commands`.
3. Use `bin/producer.rb` to generate messages into your queue. Provide two ARGS after to determine how much. The first is the batch size and the second is how many times to send the batch. So `bin/producer.rb 100000 10` would produce 1,000,000 small messages in the queue.
4. Use `bin/test_amqp.rb` to test the AMQP gem against your selected Ruby or JRuby version. The first ARG decides how many concurrent threads to run at once. So `bin/test_amqp.rb 20` would test using 20 concurrent threads. The script will output the active threads, count of messages processed, and the current message per second rate. Example:

```
Threads: 20
Count: 541
Msg/s: 54
```
5. Use `bin/test_em.rb` to test against EventMachine alone without AMQP. The same concurrency ARG above works also.

Custom tweaking:

With each test script are settings to tweak:

```
# The minimum latency for a single operation on a message.
    :task_latency_min => 10,
# The max latency for a single operation on a message. Latency is random between min and max.    
    :task_latency_max => 15,
# For the EM test you can specific the auto generation per second.
    :events_per_sec => 1000000,
```    

#Testing

## Using:
* amq-client (0.9.10)
* amq-protocol (1.0.1)
* amqp (0.9.8)
* eventmachine (1.0.0 java) => JRuby
* eventmachine (1.0.0) => Ruby


### Ruby 1.9.3-p327

test_amqp.rb => `works`
test_em.rb => `works`

### JRuby 1.7.1

test_amqp.rb => `fails` => error below
test_em.rb => `works`

#### Error under JRuby:

```
EventableSocketChannel.java:206:in `writeOutboundData': java.lang.NullPointerException
	from EmReactor.java:276:in `isWritable'
	from EmReactor.java:201:in `processIO'
	from EmReactor.java:111:in `run'
	from NativeMethodAccessorImpl.java:-2:in `invoke0'
	from NativeMethodAccessorImpl.java:39:in `invoke'
	from DelegatingMethodAccessorImpl.java:25:in `invoke'
	from Method.java:597:in `invoke'
	from JavaMethod.java:440:in `invokeDirectWithExceptionHandling'
	from JavaMethod.java:621:in `tryProxyInvocation'
	from JavaMethod.java:301:in `invokeDirect'
	from InstanceMethodInvoker.java:52:in `call'
	from CachingCallSite.java:306:in `cacheAndCall'
	from CachingCallSite.java:136:in `call'
	from CallNoArgNode.java:64:in `interpret'
	from NewlineNode.java:105:in `interpret'
	from ASTInterpreter.java:75:in `INTERPRET_METHOD'
	from InterpretedMethod.java:139:in `call'
	from DefaultMethod.java:172:in `call'
	from CachingCallSite.java:306:in `cacheAndCall'
	from CachingCallSite.java:136:in `call'
	from VCallNode.java:88:in `interpret'
	from NewlineNode.java:105:in `interpret'
	from BlockNode.java:71:in `interpret'
	from EnsureNode.java:96:in `interpret'
	from BeginNode.java:83:in `interpret'
	from NewlineNode.java:105:in `interpret'
	from BlockNode.java:71:in `interpret'
	from IfNode.java:118:in `interpret'
	from NewlineNode.java:105:in `interpret'
	from BlockNode.java:71:in `interpret'
	from ASTInterpreter.java:75:in `INTERPRET_METHOD'
	from InterpretedMethod.java:161:in `call'
	from DefaultMethod.java:180:in `call'
	from CachingCallSite.java:316:in `cacheAndCall'
	from CachingCallSite.java:145:in `callBlock'
	from CachingCallSite.java:154:in `callIter'
	from CallNoArgBlockNode.java:64:in `interpret'
	from NewlineNode.java:105:in `interpret'
	from BlockNode.java:71:in `interpret'
	from ASTInterpreter.java:75:in `INTERPRET_METHOD'
	from InterpretedMethod.java:204:in `call'
	from DefaultMethod.java:196:in `call'
	from CachingCallSite.java:336:in `cacheAndCall'
	from CachingCallSite.java:179:in `callBlock'
	from CachingCallSite.java:188:in `callIter'
	from bin/test_amqp.rb:20:in `__file__'
	from bin/test_amqp.rb:-1:in `load'
	from Ruby.java:810:in `runScript'
	from Ruby.java:803:in `runScript'
	from Ruby.java:674:in `runNormally'
	from Ruby.java:523:in `runFromMain'
	from Main.java:390:in `doRunFromMain'
	from Main.java:279:in `internalRun'
	from Main.java:221:in `run'
	from Main.java:201:in `main'
```