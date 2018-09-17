# InnoDB锁

[文档](https://dev.mysql.com/doc/refman/8.0/en/innodb-locking.html)
[别人的翻译](https://segmentfault.com/a/1190000014071758)


### Share and Exclusive Locks(共享锁, 排他锁)

- 共享锁允许持锁事务读取一行
- 排它锁允许持锁事务更新或者删除一行

如果事务 T1 持有行 r 的 s 锁，那么另一个事务 T2 请求 r 的锁时，会做如下处理：

- T2 请求 s 锁立即被允许，结果 T1 T2 都持有 r 行的 s 锁
- T2 请求 x 锁不能被立即允许

如果 T1 持有 r 的 x 锁，那么 T2 请求 r 的 x、s 锁都不能被立即允许，T2 必须等待T1释放 x 锁才行。

### Intention Locks(意向锁)

### Record Locks(记录锁)

### Gap Locks(间隙锁)

### Next-Key Locks

### AUTO-INC Locks(自增锁)

### Predicate Locks for Spatial Indexes(空间索引断言锁)

### MVCC(multi-version concurrency control) VS LBCC(lock-based concurrency control)

### 执行计划(execution plan)
[文档](https://dev.mysql.com/doc/refman/5.5/en/execution-plan-information.html)


### 注意
1. 排他锁 vs 间隙锁 
T1: ```select * from table where id=1 for update``` 
T2: ```select * from table where id=1 for update```
当T1和T2并发, 如果```id=1```存在, 则后执行的事务被阻塞(加了排他锁); 如果```id=1```不存在, 则不会阻塞(加了间隙排他锁)
> 同样值得注意的是，不同的事务可能会在一个间隙中持有冲突的锁，例如，事务A可以持有一个间隙上共享的间隙锁（gap s lock）同时事务B持有
该间隙的排他的间隙锁（gap x lock），冲突的间隙锁被允许的原因是如果一条记录从索引中被清除了，那么这条记录上的间隙锁必须被合并。


