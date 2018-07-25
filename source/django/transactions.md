# Django事务(transaction)

[文档](https://docs.djangoproject.com/en/2.0/topics/db/transactions/), 以下是翻译

## Database transaction
Django给出了一些控制数据库事务的方法

### Managing database transaction

#### Django的默认事务行为
Django的默认行为是: 以autocommit模式运行. 每个query都会在数据库马上执行, 除非启动了一个事务. 

Django使用transaction或savepoints来保证需要多次query的ORM语句能够整体执行.

Django的TestCase类基于性能表现的原因, 把每个测试(test)都用事务(transaction)封装了.

----

#### Trying transaction on HTTP requests
在web中, 处理事务(transaction)的常用方法是: 把每个request都包装在事务中(transaction). 如果你想实现这种行为, 在```setting.py```配置文件中把```ATOMIC_REQUESTS ```置为```True```.

It works like this: 在调用一个视图函数(view function)之前, Django会启动一个事务(transaction). 如果该视图正常响应(response), Django提交(commit)事务(transaction). 如果视图报异常(exception), Django回滚(roll back)事务(transaction).

你可能在视图代码中使用savepoints来实现子事务(subtransaction), 通常使用```atomic()```上下文管理器(context manager). 然而, 在视图执行的最后, 要么**全部**要么**全不**执行修改.

> **警告**
> 尽管这个看起来非常简单的事务模型很吸引人, 但是当流量变大(traffic increase)之后, 它同样会使得效率变低. 为每一个视图开一个事务有点过头(overhead)了. 具体对性能的影响, 取决于application的query pattern和数据库处理锁(lock)的能力.

> **Per-request transactions and streaming responses**
> 当一个视图返回一个``` StreamingHttpResponse```, 读取响应的内容将会执行生成(generate)该内容的代码. 因为视图的响应在已经被返回, 这种代码将会在事务之外执行.
一般来说, 不建议在生成```streaming response```的时候写数据库, 因为在发送响应之后没有sensible的办法处理错误.

在实际中, 这个特性(在setting中设置```ATOMIC_REQUESTS=True```)相当于把所有视图函数包装在```atomic()```装饰器之下.

应该注意到, 只有视图的执行(execution of views)会包括在事务内. 中间件会在事务之外执行, 渲染模板响应(rendering template response)也是.

当设置了```ATOMIC_REQUESTS```后, 还是有可能组织视图在事务中运行的:
```non_atomic_requests(using=None)```
这个装饰器会无效化```ATOMIC_REQUESTS```对被装饰视图函数的影响.

```python

from django.db import transaction

@transaction.non_atomic_requests
def my_view(request):
    do_stuff()

@transaction.non_atomic_requests(using='other')
def my_other_view(request):
    do_stuff_on_the_other_database()
```

#### 显式地控制事务
Django提供一个单独的API来控制数据库事务:
```atomic(using=None, savepoint=True)```
原子性是数据库事务的定义特性. 原子性允许我们在数据库中创建一个原子执行的代码块. 如果代码块被成功执行, 修改就会被提交到数据库; 如果报异常, 修改将会会被回滚. 

原子块(atomic block)可以被嵌套. 在这种情况下, 当一个内部的块(block)被成功执行, 这时如果外部的块报错了, 内部的执行效果依然可以被回滚.

atomic(原子性)可以用装饰器来使用:
```python
from django.db import transaction

@transaction.atomic
def viewfunc(request):
    # This code executes inside a transaction.
    do_stuff()
```
也可以用上下文管理器(context manager)来使用:
```python
from django.db import transaction

def viewfunc(request):
    # This code executes in autocommit mode (Django's default).
    do_stuff()

    with transaction.atomic():
        # This code executes inside a transaction.
        do_more_stuff()
```

把atomic包装在```try/except```里, 可以处理integrity error(整体性错误):
```python
from django.db import IntegrityError, transaction

@transaction.atomic
def viewfunc(request):
    create_parent()

    try:
        with transaction.atomic():
            generate_relationships()
    except IntegrityError:
        handle_exception()

    add_children()
```
在这个例子中, 即使```generate_relationships()```执行失败导致integrity error, 你也可以执行```add_children()```, 而且```create_parent()```也会保留. 注意到, 在```handle_exception() ```调用之前, ```generate_relationships()```的所有操作都会被安全地回滚, 所以如果有需要exception handler也可以执行数据库操作.

> **避免在atomic里捕获异常**
> 当退出atomic block的时候, Django会看是正常退出还是带有异常, 由此来判断是commit还是roll back.如果你在atomic block里捕获处理了异常, 你可能会对Django隐藏了已经发生的问题. 这可能会导致意想不到的结果.
这通常是```DatabaseError```和它的子类, 例如```DatabaseError```引发的问题. 在这种errors发生之后, 事务会被破坏, Django会在```atomic block```的最后执行roll back. 如果你想要在回滚之前执行database queries, Django会报```TransactionManagementError```. 当一个与ORM相关的signal handler报异常的时候, 你可能会遇到相同的问题.

> **当回滚一个事务, 你可能需要手动地还原model状态**
> 当一个事务回滚的时候, model字段的值将不会被还原. 这可能会导致model状态不一致, 除非你手动地存储字段的original value.
例如, 一个```MyModel```有字段```active```, 一下代码片段会确保, 当更新```active```为True在事务中失败后, 最后的```if obj.active```检查能检查到正确的值.
```python
from django.db import DatabaseError, transaction

obj = MyModel(active=False)
obj.active = True
try:
    with transaction.atomic():
        obj.save()
except DatabaseError:
    obj.active = False

if obj.active:
    ...
```
为了保证原子性, atomic关闭了一些APIs. 在atomic block中尝试commit, roll back, 或者在数据库连接(database connection)中改变autocommit状态, 都会引起异常.

```atomic```使用```using```参数, 该参数应设为数据库名字. 如果该参数没有提供, Django将使用```"default"```数据库.

总结起来, Django这样处理事务:
- 当进入一个最外层的atomic block的时候, 打开一个事务;
- 当进入一个内层的atomic block的时候, 创建一个savepoint
- 当退出一个内层的atomic block的时候, 释放或者回滚到savepoint
- 当退出一个外层的atomic block的时候, commit或者roll back事务

你可以通过设置```savepoint=False```来关闭在进入内层块的时候创建savepoints. 当离开第一个带有savepoint的块的时候, 如果发生异常, Django将执行roll back. 原子性依然是靠外层的块保证. 这个opotion只有在发现savepoint用过头的时候才要使用. 他有上面提到过的打破error handler的缺点.

当autocommit关闭的时候你可能会使用atomic. 这时候外层外也会用到savepoint(实在不懂什么意思).
> **性能考虑**
> 打开事务会给你的database server带来performance cost. 为了最小化这个影响, 应该尽可能保持事务简短. 这尤其重要如果是在Django的request/response循环之外的长时间运行的过程使用```atomic()```.