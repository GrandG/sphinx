# 异步IO

IO读写速度相对于CPU运行速度很慢, 所以当程序要进行IO操作时, 线程会因为等待IO响应而挂起, 从而引起堵塞. 解决方法之一是开启多线程, 但是多线程不能无限开. 线程越多, 切换线程的资源消耗越大, 知道消耗完所有系统资源. 所以最好的方法是采用异步IO, 当程序执行耗时的IO操作时, 只发出IO指令, 并不等待IO结果, 直接去执行其他代码, 等到IO执行完后, 再通知程序执行.

## 进程 vs 线程
- 进程的状态:
    - 就绪态, 资源准备完毕, 等cpu调用
    - 运行态, cpu正在执行
    - 阻塞态, 等待资源中
- 时间片(timesplice, quantum, processor slice)
    - 在多任务系统中, 把CPU的运行时间分成一份份的时间片, 每个线程分配一个时间片, 如果时间片用完线程还没有执行完, 就把该进程保存好, 执行另一个进程的时间片; 如果不到时间片结束就执行完毕, 直接切换任务.
    - 时间片很短(在Linux上是5ms-800ms)
    - 一个系统中, 每个进程被分配到的时间片是不同的, 一般来说, IO消耗型操作分配到的时间片, 比CPU消耗型操作分配到的多.
    - CPU分配时间片的单位是**线程**
- linux实际上是不区分进程和线程的
- 进程和线程是CPU工作时间段的描述
    - 一个程序A的执行过程包括: 
        1. 加载程序A的上下文, 包括内存等其他资源加载好
        2. CPU执行程序A
        3. 保存程序A的上下文
    - 这样就是一个进程
    - 再把2中执行程序A细分:
        1. 执行A中的步骤a
        2. 执行A中的步骤b
        3. 执行A中的步骤c
    - 这样每一步就是一个线程
    - 所以线程是共享上下文的
- **以前理解的一个误区**: 以为一个进程只在一个CPU运行. 其实系统对CPU有多核调优, 会用多个CPU处理同一个进程. **更新**, 其实以前的理解也没有错. 理论上说一个线程只会被一个CPU单独执行, 只是intel底层对cpu操作有优化, 把一个操作分配给多个cpu执行. 所以其实以前的理解也没有错.
- daemon threading
    - 与Daemon(Daemon Process)要区分开, 他们之间的联系仅仅是都有Demon这个字
    - python的Daemon thread来源于Java的Daemon
    - 特点是:
        1. 可以在后台执行, 意思是不能使用join
        2. 在主线程结束后, daemon thread自动结束
        3. 可以被杀死

- 为什么死循环占CPU高
    - 死循环进程一直处于就绪态

- 并行vs并发
    - 并行(parallel), 两个或多个线程在同一时刻运行
    - 并发(concurrent), 两个或多个线程在同一时间间隔运行

- 原子性操作. 下面的python语句是原子性操作, 即在执行过程中不会被切换的操作:
    ```python
    L.append(x)
    L1.extend(L2)
    x = L[i]
    x = L.pop()
    L1[i:j] = L2
    L.sort()
    x = y
    x.field = y
    D[x] = y
    D1.update(D2)
    D.keys()
    ```
- 查看bytecode
    - ```python
        import dis
        dis.dis(lambda x: x += 1)
        ```
## Queue
- from queue import Queue
- Queue与list, deque等不同的是: Queue为空时, 调用get()方法会阻塞掉, 其他的为空时会返回None或报错.
- 阻塞指的是把线程挂起, 所以死循环读取queue也不会占用很高的CPU

## Actor模型
- 并发线程通信有两种策略:
    - 共享数据. 涉及到竞争条件(race condition)的问题, 即锁.
    - 消息传递. Actor模型就是这种
    - 例子:
```python
from threading import Thread, Event
from queue import Queue


class ActorExit(Exception):
    pass


class Actor:
    def __init__(self):
        self._queue = Queue()

    def send(self, msg):
        self._queue.put(msg)

    def recv(self):
        msg = self._queue.get()

        if msg is ActorExit:
            raise ActorExit

        return msg

    def close(self):
        self.send(ActorExit)

    def start(self):
        self._event = Event()
        t = Thread(target=self._bootstrap, daemon=True)
        t.start()

    def join(self):
        self._event.wait()

    def _bootstrap(self):
        try:
            self.run()
        except ActorExit:
            pass
        finally:
            self._event.set()

    def run(self):
        while True:
            msg = self.recv()
            print(msg)
```

## 生成器(generator)
- 函数加了yield就变成生成器, 普通函数加```()```后就会执行, 生成器加```()```后不会执行, 要调用next(generator)或generator,send(something)才会执行.
- yield
    - ```v = yield ```. 这句的意思是, 赋值语句从右往左执行. 右边的yield把它右边的表达式"返回"(不是真正的return, 因为generator中的return会raise StopIteration. 除了这一点其他一样)给调用方, 然后generator挂起, 若调用方用来send(variable)方法, 则再次进入generator, yield把send的参数variable赋给等号左边的变量
    - **注意**, 在首次实例化generator时, 不能使用send, 要先调用一次generator.next()或send(None)之后才能使用. 因为实例化后还不没用进入generator运行到yield, 所以会报错.
    - ```yield from iterable```
        1. d对于简单的iterable, ```yield from iterable```等于```for item in iterable: yield item```
        2. ```yield from generator```就是一个delegation(代理). 假设一个outer用了yield from, yield from后面的生成器是inner, 则outer.send(spmething)完全等于inner.send(something), 同时把inner yield的内容返回给outer.
        3. [这个解释](https://stackoverflow.com/questions/9708902/in-practice-what-are-the-main-uses-for-the-new-yield-from-syntax-in-python-3)最好
        4. next()等于send(None)
- 生成器的迭代过程中, 遇到return会raise StopIteration. 即可以用return退出生成器.
## 协程(Coroutine)
- 协程vs多线程
    - 协程只有一个线程, 但可以实现并发. 优点是, 多线程的线程越多, 线程切换的开销就越大, 协程只有一个线程所以不存在线程切换; 使用协程不用考虑锁的问题
    - 协程加多进程就可以充分利用多核, 从而避开GIL.
- 协程通过generator实现



## asyncio

## async/await

## aiohttp
