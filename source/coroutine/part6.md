# A crush course in Operating System

## 多任务(multitasking)
- CPU一次只执行一条指令, 所以CPU自己不能多任务.
- 应用程序(application)也不会多任务.
- 操作系统(OS)才会多任务.

问题:
- 当CPU运行application的时候不会运行操作系统, 那操作系统怎么切换任务?
    - 主要通过两种机制:
        - Interrupt. 跟硬件相关的signal
        - Traps. 跟软件相关的signal.
    - 两种情况下, CPU都会suspend正在运行的程序, 并开始运行OS的代码.
    - 底层的System Call实际上也是trap
    - 实际上yield的作用就跟trap一样
    - 所以利用coroutine就可以实现multitasking