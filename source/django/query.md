# Quuery(查询)

## creating objects(创建对象)
Django使用一种符合直觉的方法处理数据库: model class代表数据库表, class的实例代表具体某一行记录.

创建一条数据库记录, 可以:
```python
>>> from blog.models import Blog
>>> b = Blog(name='Beatles Blog', tagline='All the latest Beatles news.')
>>> b.save()
```
在这个语句中, Django会在数据库执行```INSERT```语句
Django在```save()```方法之前不会触及到数据库

要用一条语句创建, 使用```create()```方法

----------

## save changes to objects(保存更新的对象)
```python
>>> b5.name = 'New name'
>>> b5.save()
```
在这个语句中, Django会在数据库执行```UPDATE```语句
Django在```save()```方法之前不会触及到数据库

### Saving ForeignKey and ManyToManyField fields
保存```ForeignKey```字段
```python
>>> from blog.models import Blog, Entry
>>> entry = Entry.objects.get(pk=1)
>>> cheese_blog = Blog.objects.get(name="Cheddar Talk")
>>> entry.blog = cheese_blog
>>> entry.save()
```

保存``` ManyToManyField```有点不一样: 用```add()```来添加记录
```python
>>> from blog.models import Author
>>> joe = Author.objects.create(name="Joe")
>>> entry.authors.add(joe)        # 一篇文章有多个作者, entry有M2M字段author
```
要一次性添加多个:
```python
>>> john = Author.objects.create(name="John")
>>> paul = Author.objects.create(name="Paul")
>>> george = Author.objects.create(name="George")
>>> ringo = Author.objects.create(name="Ringo")
>>> entry.authors.add(john, paul, george, ringo)
```

--------

## retrieving objects(查询对象)
为了从数据库中查找对象(query object), 要在model class中通过```Manager```构建```QuerySet```.

一个```QuerySet```是数据库中对象的集合(a collection of objects). 它可以在后面加0, 1或多个```filter```. 
在SQL语句中, ```QuerySet```相当于```SELECT```语句; ```filter```相当于```WHERE```或者```LIMIT```.

你可以通过模型的```Manager```获得```QuerySet```. 每个模型至少有一个```Manager```, 默认叫```objects```, 可以直接用model class使用:
```python
>> Blog.objects
<django.db.models.manager.Manager object at ...>
>>> b = Blog(name='Foo', tagline='Bar')
>>> b.objects
Traceback:
    ...
AttributeError: "Manager isn't accessible via Blog instances."
```

> 注意
> ```Managers```只能通过models class来使用, 不同通过model instance使用. 因为它是执行```table-level```的操作, 而不是```records-level```的操作.

### retrieve all objects

retrieve objects最简单的方法是: retrieve all of them:
```python
all_entries = Entry.objects.all()
```

### retrieving specific objects with filters

两个最常用的refine QuerySet的方法是:
- ```filter(**kwargs)```
返回符合给定的```lookup parameters```(即**kwargs)对象的QuerySet
- ```exclude(**kwargs)```
返回不符合给定的```lookup parameters```(即**kwargs)对象的QuerySet

参数的```lookup parameters```应该符合下面说的``` Field lookups ```的格式

例子, 找到在2006年发表的文章的QuerySet:
```Entry.objects.filter(pub_date__year=2006)```
这和下面的是等效的:
```Entry.objects.all().filter(pub_date__year=2006)```

### chaining filter(链式filter)
QuerySet经过filter后还是QuerySet, 所以filter可以链式增加:
```python
>>> Entry.objects.filter(
...     headline__startswith='What'
... ).exclude(
...     pub_date__gte=datetime.date.today()
... ).filter(
...     pub_date__gte=datetime.date(2005, 1, 30)
... )
```

### Filtered QuerySets are unique
每次你refine一个QuerySet, 你都会得到一个全新的QuerySet, 这个QuerySet与之前的QuerySet没有任何联系. 
例子:
```python
>>> q1 = Entry.objects.filter(headline__startswith="What")
>>> q2 = q1.exclude(pub_date__gte=datetime.date.today())
>>> q3 = q1.filter(pub_date__gte=datetime.date.today())
```
q2和q3是在q1的基础上得到的, 但q2, q3与q1无任何关联(类似deep copy)

### QuerySets are lazy
QuerySet are lazy: 创建QuerySet这个行为与数据库没有任何关系. 只有QuerySet被evaluate的时候, Django才会去执行query, 否则不会执行query动作.
```
>>> q = Entry.objects.filter(headline__startswith="What")
>>> q = q.filter(pub_date__lte=datetime.date.today())
>>> q = q.exclude(body_text__icontains="food")
>>> print(q)
```
这里看起来有三次查询, 实际上只有一次: 当``print(q)```执行的时候

### retrieving a single object with get()
```filter()```总是会返回QuerySet, 即使是只有一个object的QuerySet
如果你确信有且只有一个object符合你的query, 可以用```Manager```的```get()```方法, 直接返回object本身.
```>>> one_entry = Entry.objects.get(pk=1)```
```get()```使用的lookup parameters和```filter()```的一样, 同样的, 下面的``` Field lookups```会提到.

使用```get()```, 如果找不到符合的object, 会报```DoesNotExist ```异常. 这个异常是执行的model class的类属性.
同样的, 如果用```get()```返回不止一个object, 会报``` MultipleObjectsReturned```异常. 这个异常同样是执行的model class的类属性.

### other QuerySet methods
大多数时候你会用```get()```, ```all()```, ```filter()```, ```exclude()```. 但这远远不是所有的方法. 查看[QuerySet API reference](https://docs.djangoproject.com/zh-hans/2.0/ref/models/querysets/#when-querysets-are-evaluated)来获取QuerySet的所有方法.

--------

## limiting QuerySets
使用python的```array slicing```来limit特定数量结果的QuerySet. 这等价于SQL的```LIMIT```和```OFFSET```语句.

例子, 返回头5个objects(LIMIT 5):
```Entry.objects.all()[:5]```

返回第6到第10个objects(OFFSET 5 LIMIT 5):
```Entry.objects.all()[5:10]```

不支持负数的索引
```Entry.objects.all()[-1] # wrong!```

通常情况下, 切片一个QuerySet会返回一个新的QuerySet, 这意味着不会evaluate the query. 例外的情况是: 如果你在切片中使用了```step```参数. 例如, 下面的query真的会执行query:
```Entry.objects.all()[:10:2]```

用单个index, 可以获得具体的objects而不是QuerySet.

-----

## Field lookups
```Field lookups```相当于SQL的```WHERE```子句. 他们在QuerySet的方法```get()```, ```filter()```, ```exclude()```的参数中使用.

基本的lookups keyword的格式是```field__lookuptype=value```. 例子:
```>>> Entry.objects.filter(pub_date__lte='2006-01-01')```
翻译成SQL相当于:
```SELECT * FROM blog_entry WHERE pub_date <= '2006-01-01';```

在格式```field__lookuptype=value.```中, ```field```必须是模型的字段. 但是有一个例外, 在```ForeignKey```中, 你可以用带```_id```后缀的model field用在```field```中. 例如:
```>>> Entry.objects.filter(blog_id__lte=4)```

查看[ field lookup reference](https://docs.djangoproject.com/zh-hans/2.0/ref/models/querysets/#field-lookups)获得完整的lookup types.

-------

## Lookups that span relationships
Django提供一种强大且符合直觉的方法来根据关系查询, 在脚本的背后自动地为你处理```JOIN```

例子:
```Entry.objects.filter(blog__name='Beatles Blog')```

反方向查询也可以, 使用```reverse_name```即可:
```Blog.objects.filter(entry__headline__contains='Lennon')```

如果通过多个表进行查询, 其中某个中间表不符合查询条件, Django会把它视为empty, 但不会报错. 总的来说, 这个过程不会报异常. 例如:
```Blog.objects.filter(entry__authors__name='Lennon')```
如果某篇文章没有作者, 返回的结果就跟这篇文章的作者没有名字的结果是一样的. 多数情况下, 这是你想要的结果. 唯一的例外是你使用了```isnull```:
```Blog.objects.filter(entry__authors__name__isnull=True)```
这句话将返回作者名字是空的的结果, 还有文章没有作者的结果. 为了只返回作者名字为空的结果, 应该改为:
```python
Blog.objects.filter(entry__authors__isnull=False, entry__authors__name__isnull=True)
```

### Spanning multi-valued relationships
当使用```ManyToManyField```和反方向的``` ForeignKey```(特点: 都是一对多)字段进行过滤的时候, 可能有两种方式的过滤(以Blog和Entry为例, 一个Blog有多篇Entry):
情况1: 找出Blog中Entry的标题的标题是"Lennon", 同时发表年份是2008年
情况2: 找出Blog中Entry的标题是"lennon"和Entry的发表年份是2008年(这里的两个Entry不是同一个Entry)

Django对于这两种情况的解决方法是:
对于第一种情况, 把过滤条件同时写在一个```filter()```里面; 
```python 
Blog.objects.filter(entry__headline__contains='Lennon', entry__pub_date__year=2008)
```
对于第二种情况, 使用两个```filter()```
```python
Blog.objects.filter(entry__headline__contains='Lennon').filter(entry__pub_date__year=2008)
```
> 注意
> ```exclute()```的用法与上述的```filter()```的用法不同
```python
Blog.objects.exclude(
    entry__headline__contains='Lennon',
    entry__pub_date__year=2008,
)
```
> 这句话是exclude blogs that contain both entries with "Lennon" in the headline and entries published in 2008
(抓住both...and语法来分析)
要实现exclude含有文章既是标题是Lennon同时发表日期是2008的文章,
要这么写:
```python
Blog.objects.exclude(
    entry__in=Entry.objects.filter(
        headline__contains='Lennon',
        pub_date__year=2008,
    ),
)
```
> 总结, ```filter()```中的过滤条件是针对一个object, ```exclude()```中的条件是针对不同的objects.
---
## Filters can reference fields on the mode
在目前为止的例子中, 我们在filter中构建了model的一个字段与**一个常数**的比较. 那么怎么做到在filter中构建model记录的一个字段与另外一个字段比较呢?

Django提供```F expressions```来实现这种比较.```F()```的实例可以在query中作为model字段的引用.

例子. 找出评论数比pingback数多的文章:
```python
>>> from django.db.models import F
>>> Entry.objects.filter(n_comments__gt=F('n_pingbacks'))
```
Django支持对```F()```中使用加, 减, 乘, 除, 求余, 指数运算:
```python
>>> Entry.objects.filter(n_comments__gt=F('n_pingbacks') * 2)
```

```python
>>> Entry.objects.filter(rating__lt=F('n_comments') + F('n_pingbacks'))
```

可以在```F()```中使用双下划线来实现```JOIN```:
```python
Entry.objects.filter(authors__name=F('blog__name'))
```
对于日期/时间字段, 可以加上/减去````timedelta```对象:
```python
>>> from datetime import timedelta
>>> Entry.objects.filter(mod_date__gt=F('pub_date') + timedelta(days=3))
```

```F()```对象支持位运算: ```.bitand()```, ```.bitor()```, ```.bitrightshift()```, ```.bitleftshift()```. 
```F('somefield').bitand(16)```

----

## The pk lookup shortcut
为了简化使用, Django提供了```pk```lookup shortcut, 它代表primary key.

以下的写法是等价的:
```python
>>> Blog.objects.get(id__exact=14) # Explicit form
>>> Blog.objects.get(id=14) # __exact is implied
>>> Blog.objects.get(pk=14) # pk implies id__exact
```

----
## Caching and QuerySets
每个QuerySet都包含一个cache来最小化数据库查询.

在一个新创建的QuerySet中, cache是空的. QuerySet第一次被evaluated--即发生了数据库查询--Django会在cache中保存查询结果, 并返回显式请求的结果(例如, 如果QuerySet被迭代, 返回下一个元素). Subsequence evaluations of QuerySet将会重用cache的结果.

记住这些这些cache行为, 因为如果没有正确使用QuerySet, 他可能会咬你. 如下所示:
```python
>>> print([e.headline for e in Entry.objects.all()])
>>> print([e.pub_date for e in Entry.objects.all()])
```
这里创建了两个QuerySet, 并分别evaluate.
这意味将会执行两次相同的数据库查询, double了数据库的负载.
而且有可能两个QuerySet包含不同的数据, 因为两个查询之间并不是原子操作, 中间可能执行了add或delete操作.

为了解决这些问题, 应该这样写:
```python
>>> queryset = Entry.objects.all()
>>> print([p.headline for p in queryset]) # Evaluate the query set.
>>> print([p.pub_date for p in queryset]) # Re-use the cache from the evaluation.
```
### When QuerySets are not cached
QuerySet不总是cache他们的结果
使用数组切片和索引, 不会cache结果
例子:
```python
>>> queryset = Entry.objects.all()
>>> print(queryset[5]) # Queries the database
>>> print(queryset[5]) # Queries the database again
```
以下是导致整个QuerySet被evaluated, 从而产生cache的行为:
```python
>>> [entry for entry in queryset]
>>> bool(queryset)
>>> entry in queryset
>>> list(queryset)
```

>注意
>```print()```QuerySet不会产生cache, 因为调用```repr()```只会显示QuerySet的部分值

---

## Complex lookups with Q objects
关键字查询--```filter()```, ```get()```这些查询函数的参数--是用```AND```连接的. 如果你想要执行更复杂的查询(例如```OR```), 可以使用```Q```对象

```Q```对象是用来封装一些关键字参数的对象. 这些关键字参数就是上面体到过的```Field lookups```

例如, 这个```Q```对象封装了```LIKE```查询
```python
from django.db.models import Q
Q(question__startswith='What')
```

```Q```对象可以使用```&```或```|```操作符. 当两个```Q```对象使用操作符连接起来, 会产出(yield)一个```Q```对象.
例如:
```python
Q(question__startswith='Who') | Q(question__startswith='What')
```
它等价于以下的SQL语句:
```
WHERE question LIKE 'Who%' OR question LIKE 'What%'
```

而且, ```Q```对象可以使用```~```来表示```非```:
```python
(question__startswith='Who') | ~Q(pub_date__year=2005)
```
所有的接受关键字参数的lookup函数(```filer()```, ```exclude()```, ```get()```)都可以接受```Q```对象作为参数. 如果提供了多个```Q```像, 各个```Q```对象之间使用```AND```连接起来:
```python
Poll.objects.get(
    Q(question__startswith='Who'),
    Q(pub_date=date(2005, 5, 2)) | Q(pub_date=date(2005, 5, 6))
)
```
大致相当于:
```
SELECT * from polls WHERE question LIKE 'Who%'
    AND (pub_date = '2005-05-02' OR pub_date = '2005-05-06')
```
lookup function可以混搭使用```Q```对象和lookup field. 但是必须```Q```对象在前面, 其他lookup field在后面:
```python
Poll.objects.get(
    Q(pub_date=date(2005, 5, 2)) | Q(pub_date=date(2005, 5, 6)),
    question__startswith='Who',
)
```
是正确的

```python
# INVALID QUERY
Poll.objects.get(
    question__startswith='Who',
    Q(pub_date=date(2005, 5, 2)) | Q(pub_date=date(2005, 5, 6))
)
```
是错误的.

-----

## Comparing objects
比较model instance, 使用python的比较符```==```. 实际上, 他们比较的是两个实例的primary key.
以下两句话是等效的:
```python
>>> some_entry == other_entry
>>> some_entry.id == other_entry.id
```

如果model的primary key不是```id```, 那也没关系. 比较会自动使用primary key. 例如, 如果模型的primary key是name字段, 那下面的两句话是等效的:
```python
>>> some_obj == other_obj
>>> some_obj.name == other_obj.name
```
----

## Deleting objects