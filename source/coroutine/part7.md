# Let's build an Operating system using coroutine

## 目标
- 建立一个multitasking operating system
- 不用threading
- 不用subprocess
- 用generator/coroutine

## 个人总结
1. Target与Schudual完全没有关系, 编写target函数的时候, 完全不用考虑Schedual
2. Target函数可能会调用System call
3. Schedualer与System Call有紧密的联系
4. System Call相当于从Schedualer分离出来的方法
