# Python 锁

## GIL, global interpreter lock
- 有GIL为什么还需要线程锁
    - 线程锁的作用是, 保证操作的原子性. 一些python语句如```x += 1```翻译成bytecode, 其实有三个语句: 读x的值; x加1; 把x+1赋给x. 而线程切换是在bytecode之间切换的, 所以会导致错误. 锁的作用是把三个bytecode语句作为一个不可分割的原子操作. GIL的作用是包装在同一时刻只有一个线程在执行.

- GIL的获取(acquire)和释放(release)
    - 对于IO密集型操作, 当程序在获取IO时间, 就会释放GIL, 让其他线程有机会获取GIL. 因为IO操作比CPU慢很多. 所以python多线程对于IO密集型操作是有意义的
    - 对于CPU密集型操作
        - 在python2中, 是每隔100个ticks, 释放一次GIL. ticks指的是一条bytecode执行的时间.
        - 在python3中, 是每隔5ms释放一次

- **注意**, 锁不能在线程内实例化

- 为了避免出现死锁, 尽量一个线程一次获取一把锁. 如果做不到则需要更高级的死锁避免机制:

## RLock和Semaphore
- RLock(可重入锁), 与Lock相同的是: 保证一次只有一个线程可以调用获取锁的方法; 不同的地方是, 当该方法调用一个用了相同锁的方法时, 不需要再次获取锁. 例子:
```python
import threading

class SharedCounter:
    '''
    A counter object that can be shared by multiple threads.
    '''
    _lock = threading.RLock()
    def __init__(self, initial_value = 0):
        self._value = initial_value

    def incr(self,delta=1):
        '''
        Increment the counter with locking
        '''
        with SharedCounter._lock:
            self._value += delta

    def decr(self,delta=1):
        '''
        Decrement the counter with locking
        '''
        with SharedCounter._lock:
             self.incr(-delta)
```
- Semaphore(信号量), 不用来线程同步, 而是用来限制程序