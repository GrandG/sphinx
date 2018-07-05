# python Coroutine的历史

本文参考[这个](https://snarky.ca/how-the-heck-does-async-await-work-in-python-3-5/)

## Coroutine的定义
- Wikipedia对coroutine的解释是:
 >   Coroutines are computer program components that generalize subroutines for nonpreemptive multitasking, by allowing multiple entry points for suspending and resuming execution at certain locations.
 - 好的, 这一段解释很难理解, 把他解释一下可以等同于:
 > coroutines are functions whose execution you can pause". And if you are saying to yourself, "that sounds like generators
 - 你会发现: 这跟generator一样啊? Well, you would be right.

 ## python历史
- python2.2. 第一次引入generator的概念. 是为了创建一个不会浪费内存的iterator.
- python2.5. 引入```yield```语句.
- python2.5 PEP342, 引入```send()```的用法, 调用方可以在yield之后发送data给generator. 从此python实现了coroutine.
- python3.2. 引入```concurrent.future```模块. ```concurrent futures```是```asyncio```包的基础.
- python3.3. 
    1. 引入```yield from```. 
    2. 生成器可以返回一个值. 以前生成器中给return提供值会引起SyntaxError.
- python3.4. 加入asynio模块
- python3.5. 引入```def async```和```await```. 用```await```代替```yield from```, ```def async```代替```asyncio.coroutine```
    - 引入这个后python的coroutine有两个形式:
        - generator base coroutine: 用```@asyncio.coroutine```, ```yield```或```yield from```, 不能出现await.
        - native generator: 用```async def```和```await```不能出现```yield```和```yield from```

## thread vs coroutine
- 线程(thread)是操作系统上的一种机制, 允许程序载操作系统的层面上实现并发(concurrent); 协程(coroutine)是应用程序提供的一种机制, 允许在应用程序的层面上实现并发(cocurrent).

## Asynchronous Programming
- 指的是: 预先不知道程序的执行顺序.(Asynchronous programming is basically programming where execution order is not known ahead of time)