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