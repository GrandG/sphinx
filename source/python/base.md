# 基础知识

## repr() vs str()
- 相同之处: 都把值转为字符串
- str()将返回一个用户易读的值
- repr()将返回一个解释器易读的值
- 对于大多数的变量, 这两者返回的结果是一样的
- 待续

## dict
- dict.update(dict), 类似于把dict apeend到dict里面
- dict.pop(key, default), 把key键值删除, 若不存在返回default
- dict.setdefault(key, default), 获取key的值, 若key不存在, 把default设为key的值, 同时返回.
    - 特别地, dict.setdefault(key, []).append(30), 这是可以的, 神奇~
- 遍历key, value的方法: ```for k, v in dict_a.items()```, ```iteritems```方法取消了.

## 参数要不可变
- 函数的参数要是不可变的参数
- ```def t(l=[])```这种做法是错的
- 用
    ```python
    def t(l=[]):
        print(id(t))
    ```
运行一下就知道了

## 错误```No module named '__main__.coroutine'; '__main__' is not a package```

## xml.sax
- sax是simple api for xml的意思, 用于解析xml
- 继承```xml.sax.handler.ContentHandler```
- ```startElement(self, name, attrs):```, 在遇到开始标签时执行
- ```characters(self, content)```, 在start和end之间执行
- ```endElement(self, name):```, 在遇到结束标签后执行
```python
import xml.sax
from xml.sax.handler import ContentHandler



class WorksHandler(ContentHandler):
    def __init__(self):
        self.current_data = ''
        self.name = ''
        self.author = ''

    
    def startElement(self, name, attrs):
        if name == 'works':
            print('**内容**')
            title = attrs.get('title')
            print("类型: {}".format(title))
            # print('========', name)
        self.current_data = name

    def characters(self, content):
        if self.current_data == 'names':
            self.name = content
        elif self.current_data == 'author':
            self.author = content

    def endElement(self, name):
        if self.current_data == 'names':
            print('名称: {}'.format(self.name))
        elif self.current_data == 'author':
            print('作者: {}'.format(self.author))
        self.current_data = ''


if __name__ == '__main__':
    parser = xml.sax.make_parser()
    parser.setFeature(xml.sax.handler.feature_namespaces,0)
    Handler = WorksHandler()
    parser.setContentHandler(Handler)
    parser.parse(r'D:\Workshop\practice\coroutine\works.xml')
```
用到的xml:
```xml
<collection shelf="New Arrivals">
<works title="电影">
  <names>敦刻尔克</names>
  <author>诺兰</author>
</works>
 <works title="书籍">
  <names>我的职业是小说家</names>
  <author>村上春树</author>
</works>
</collection>
```

## 迭代dict
```python
for k, v in dict.items():
    print(k, v)
```

## sys.stdout.write vs sys.stdout.flush
- ```print()```实际上就是在调用```sys.stdout.write()```
- ```sys.stdout.write()```写进去的东西会存起来, 等程序结束后再一起输出; 如果需要提前输出, 就用```sys.stdout.flush()```, 这样就可以把存起来的东西输出到标准输出上. 经我发现, 用```print()```也可以达到同样效果, 原因想一下就知道.    
- ```write('\x08')```可用于退格

## list comprehension的执行顺序
- list comprehension的执行顺序是从左到右
```python
a = [1, 2, 3]
[(i, j) for i in a for j in a]
```
执行结果是```[(1, 1), (1, 2), (1, 3)...]```

## 把函数作为对象
- python里函数都是**一等对象(first class object)**:
    - 函数在运行时被创建
    - 函数可以赋给变量
    - 函数可以作为参数传递
    - 函数可以作为返回值
- 高阶函数: 把接受函数作为参数, 或者把函数作为返回结果的函数
    - map, reduce, filter这些都是高阶函数
    - 因为引入了list comprehension和generator, 大部分map, filter的功能可以被替代.
    - map, filter在python3中返回生成器, 所以直接替代品是生成器表达式.
    - 注意: reduce在python2是内置函数; python3放在```functools```里面.
- map, reduce, filter介绍
    - map, filter用法类似, 第一个参数是函数, 第二个参数是iterable; map把函数应用在每个iterable元素上. filter过滤掉函数返回值是0的元素(即filter的函数一定要明确返回True或False)
    - reduce. 参数和上面的一样. 区别在于, 其使用的函数接受两个参数, 即把当前运行结果作为第一个参数, 把iterable的下一个元素作为第二个参数, 其返回的结果
- all, any. all(iterable), 当iterable中所有元素为True才返回True; any(iterable), iterable存在元素为True则返回True.
- 匿名函数. ```lambda```是语法糖, 意思是```lambd```能实现的用```def```必然能实现, 只是用```lambda```更好看. 匿名函数只能写纯表达式语句, 不能赋值, 不能使用while, for等语句.

## 可调用对象
- 可以使用**调用运算符**()的对象就是可调用对象.
- 可以用```callable()```判断对象是否是可调用对象.
- 用7种可调用对象:
    - ```def```或```lambda```定义的函数
    - 类
    - 类的方法
    - 生成器
    - 内置函数
    - 内置方法
    - 类的实例(如果类定义了```__call__```方法, 那么他的实例可作为函数调用)
- python中, 任何对象只要实现了```__call__```方法, 都可当作函数来使用.

## 面向对象惯用法
- 每个对象都有id, type和value. ```==```验证值是否相等, ```is```判断id是否相等, ```type()```可以查看对象类型.
- 一般比较关注的是值相等, 所以```==```用得比```is```多; ```is```的速度比```==```快; ```==```是语法糖, ```a==b```等同于```a.__eq__(b)```
- python唯一支持的参数传递模式是**共享传参(call by sharing)**: 即函数的形参获得的是实参中各个引用的副本; 即函数内部的形参是实参的别名. 这样的结果是: 当传递给函数的是不可变对象时, 不会有影响; 当传递给函数的是可变对象, 函数可能会修改可变对象. 同时这也是参数的默认值不能是可变对象的原因.
- **一个我之前没注意的点**: 注意当函数的参数是可变对象!!! 如果在函数中需要修改该可变对象, 则应该先把该可变对象copy一份, 再对该copy操作, **不要直接对可变对象操作**.
- ```del```删除的是名称, 而不是对象. 但是, 当对象被引用的次数为0时, 该对象就会被垃圾回收.
- 弱引用
    - 弱引用不会增加对象的引用数量.
    - 引用的目标称为referent(所指对象).
    - 弱引用不会阻止referent当作垃圾回收
- 每个面向对象语言都会提供至少一种显示对象的字符串表示形式的方法. python提供了两种: ```repr()```和```str()```.
    - ```repr()```以便于开发者理解的方式返回对象的字符串形式.
    - ```str()```以便于用户理解的方式返回对象的字符串形式.
    - 设置```__repr__```比设置```__str__```好, 因为在```str()```缺省的情况下, ```str()```, ```print```会调用```__repr__```方法.
    - ```print()```调用```__str__```; ```'{}'.format()```默认调用```__str__```, ```{!r}.format()```会调用对象的```__repr__```, ```{!s}.format()```调用对象的```__str__```方法; 控制台直接输入对象, 调用```__repr__```
    - ```repr(字符串)```输出会包含字符串的引号, ```str(字符串)```输出字符串本身
    - 获得实例的类的类名: ```type(obj).__name__```
- 数据结构
    - array
        - ```from array import array```
        - array和list差不多, 只是array限定元素的类型要一致
        - 比```list```节省内存下
        - 初始化方法```array(typecode, iterable)```
        - [typecode列表](https://docs.python.org/3/library/array.html)
    - set
        - ```set```可以看作数学上无序的, 不重复的集合. 因此可以进行交集(```s1 & s2```), 并集(```s1 | s2```)操作.
        - set与dict有点像, 区别在于set只存key, 不存value. 因此set的值本质上是可哈希(可散列, hashable)的
- ord() vs chr()
    - ```ord()```把字符串转为数字; ```chr()```把数字转为字符串
- ```eval()```, 把字符串当作有效的表达式进行运算
- ```@classmethod``` vs ```@staticmethod```
    - ```@classmethod```装饰器标识方法是类方法, 第一个参数必然是```cls```. classmethod常用于**构建备选构造方法**, 即以```__init__()```以外的形式构造实例
    - ```@staticmethod```把方法标记位静态方法. 把与类无交互的函数标记为类的method. 因此把静态方法移到类的外面依然可以运行.
- 私有属性和受保护的属性
    - 类以双下划线```__```开头的属性, 如```self.__a```, 会被视为私有属性. python会把该属性存入对象的```__dict__```属性中, 并改名为```_类型__属性名```的形式, 所以外部不能直接调用```self.__a```, 但是可以直接调用```self._类名__属性名```, 但是强烈不建议这么做.
    - Paste 的风格指南: "绝对不要使用两个前导下划线，这是很烦人的自私行为。如果担心名称冲突，应该明确使用一种名称改写方式（如_MyThing_blahblah）。这其实与使用双下划线一样，不过自己定的规则比双下划线易于理解。"
    - 鉴于以上的说法, 很多人用单下划线+属性名的方法定义私有变量. 但这只是约定的写法, python没有机制保证其私有, 需要程序员自己遵守.
- 使用```__slots__```类属性节约空间
    - 默认情况下, 实例中的```__dict__```字典会存储对象的所有属性. 而字典为了访问速度, 会消耗大量的内存.
    - 为了优化内存, 可以设置```__slots__```类型属性. 其作用是把实例的属性存储在元组中, 而不存在```__dict__```字典中
    - ```__slots__```类属型的定义方法是: 使用```__slots__```这个名字; 他的值设为字符串构成的可迭代对象. 每个字符串就是就是各个实例的属性.
        ```python
         __slots__ = ('__x', '__y')
        ```
    - 设置了```__slots__```后, 实例不能再有除了```__slots__```中所列名称之外的属性. **但这是他的副作用, 不是```__slots__```存在的真正原因.** ``` ```__slots__```是用于优化的, 不是用来约束程序员的.
    - 如果把```__dict__```加到```__slots__```中, 则相当于```__slots__```不起作用.
    - 如果需要实例被弱引用, 则要把```__weakref__```属性加入到```__slots__```中.
    - 继承的子类要重新定义```__slots__```, 因为```__slots__```属性不会被继承.
- 覆盖类属型
    - python有个独特的特性: 类属型可以为实例属性提供默认值. 例如, 一个类```Vector2d```设置了```typecode = 'b'```的类变量, 其实例```v1```的实例变量```v1.typecode```的值就是```b```. 如果重新给```v1.typecode```赋值, ```v1.typecode='f'```, 就会改变实例变量的值, 但不改变类变量```Vector2d.typecode```的值.
    -  想要改变类变量的值, 要对类变量重新赋值: ```Vector2d.typecode='f'```; 或者更pythonic的方法, 创建一个新的类, 新类中覆盖```typecode```属性, 这在Django的类视图中大量用到.
## 序列中的修改, 散列, 切片
- ```str1.find(str2)```找处str2在str1中的位置, 若找不到则返回-1.
- ```reprlib```模块
    - 把对象变成字符串, 可以用```reprlib.repr()```函数
    - 与```str()```和```repr()```函数相比的好处是, 可以控制显示的字符串的长度, 太长的字符串会以```...```的形式显示.
- ```__iter__```方法要返回一个迭代器.
- 协议(Protocol)与鸭子类型(Duck Typing)
    - 动态语言vs静态语言. 
        - 静态语言在编译阶段就为变量确定好类型; 动态语言只有在运行时才会确定变量的类型. 
        - 所以静态语言严格要求参数的类型, 例如一个函数要求参数的类型是```Animal```, 那么编程时只能传```Animal```或```Animal```的子类```Bird```, ```Dog```等.
        - 鸭子类型则指依靠**协议**(protocol). 即协议预先规定, ```Animal```是拥有```run```属性的类, 则可以新建一个类```Alien```, 不继承于```Animal```, 这要他拥有```run```方法, 一样可以作为参数传递. 
- 鸭子类型(duck type) vs 多态(polymorphism) vs 白鹅类型(goose type)
    - 鸭子类型, 对python来说, 实际指的是避免使用```isinstance()```来检查对象的类型(用```type(foo) is bar```是更糟糕的检查对象类型的方法, 因为其禁止了继承). 而应该多用```hasattr()```
    - 多态: 指用同一接口(interface), 处理不同类型的对象. 通常通过继承父类, 重写父类的方法实现.
    - 鸭子类型. 接口的对象, 只要该对象实现相应的协议, 该接口就能处理该对象.
    - 可以看出, 鸭子类型可以使得python不通过继承就能实现多态.
    - 例子, ```int()```函数把对象转为```int```. 我实现一个类:
    ```python
    class MyNum:
        def __int__(self):
            return 1
    ```
    该类的实例一样可以作为```int()```函数的参数使用, 并始终返回1.
    - 常见的协议:
        - sequence协议: 实现了```__len__```, ```__getitem__```方法(如果想要实现可变的序列, 还要实现```__setitem__```方法, 这样就可以给序列元素赋值)
        - iterable协议: 实现了```__iter__```和```__getitem```方法
        - iterator协议: 实现了```__iter__```和```__next__```方法
        - callable对象协议: 实现了```__call__```方法
        - hash协议. 实现了```__hash__```方法
    - 白鹅类型. 如果只是考虑烹饪方法, 那么一个东西, 只要行为表现得像个鸭子, 那就足够了(吃起来味道差不多). 如果是要考虑其面对病原体的抗体表现, 那么还是要分清楚这个东西的DNA更接近什么, 即要分清楚其祖先是谁, 即要分清楚他的类型是是什么.
    - 鸭子类型要求尽量不用```isinstance(obj, cls)```函数; 白鹅类型认为```isinstance(obj, cls)```可以用, 但不能滥用, 要求cls必须是ABC. 
- 查找属性的顺序. 查找对象属性```my_obj.x```的顺序是:
    1. 在my_boj的实例中有没有x属性
    2. 如果没有, 在对象的类中查找是否存在(```my_obj.__class__```)
    3. 如果没有顺着继承树查找是否有
    4. 如果没有, 调用```my_obj```所在类的```__getattr__```方法, 传入```self```和要查找的属性的字符串形式(即```x```)
    5. 根据这个顺序可以知道, 一般用```__getattr__```, 还要设置```__setattr__```把该查找的属性设为只读. 因为一旦该属性可以被赋值, 则直接在步骤1中就找到该属性了, 从而绕开了```__getattr__```.
- ```__getattr__``` vs ```__getattribute__```
    - 调用 ```__getattribute__``` 方法且抛出AttributeError 异常时，才会调用 ```__getattr__``` 方法
    - 为了在获取 obj 实例的属性时不导致无限递归， ```__getattribute__``` 方法的实现要使用 ```super().__getattribute__(obj, name)```
    - ```__getattr__```已经讲了. ```__getattribute__```的区别在于, 查找属性时一个查找的是```__getattribute__```方法, 即查找属性的第0步.
    - 注意, 只有```__setattr__```方法, 没有```__setattribute__```方法. 且超类会调用```__setattr__```方法, 所以重写```__setattr__```时要加上```super().__setattr__(name, value)```.
- 出色的zip函数
    - ```zip()```函数接受两个或两个以上的可迭代对象, 可以并行迭代各个可迭代元素, 返回各个并行可迭代对象的下一个元素
    - 要注意的是, 若```zip()```函数传入的可迭代对象长度不一样, 在最短的迭代完后, ```zip()```函数就会不加警告直接退出. 所以一般要先判断可迭代对象的长度是否相对.
    - ```from itertools import zip_longest```. ```zip_longest()```函数比```zip()```多了一个```fillvalue=None```可选参数. 他会把最长的iterable迭代完, 缺失的元素用```fillvalue```的值代替.
## 接口: 从协议到抽象基类
- 抽象基类(Abstract Base Class, ABC)
- python2.6才开始引入ABC, 一般不建议自己编写ABC.
- 函数签名(function signature), 即函数的参数. python3.5用```from inspect import signature```, 传入函数名, 返回函数签名.
- ABC(抽象基类).
    1. ABC不能被实例化, 只是作为基类被继承.
    2. ABC只定义了方法, 但没有具体的实现.
    3. ABC定义的abstractmethod, 要求继承的子类必须实现, 否则在实例化的时候会报错, 即formal intereface.
- python内置的ABC的UML和各个ABC的关系:
    - ![](D:/Workshop/sphinx/source/_static/python/1.png)
    - [ABC总结](https://docs.python.org/3/library/collections.abc.html#collections-abstract-base-classes)
- [python的异常(exception)层次结构图](https://docs.python.org/dev/library/exceptions.html#exception-hierarchy)
- object(对象)总是被认为是True的, 除非:
    1. 对象的```__bool__```方法返回False
    2. 对象的```__len__```方法返回0
    3. 注意, 如果```__bool__```返回了True, 那么即使```__len__```返回了0, ```bool(obj)```也会返回True
    4. list对象就是只实现了```__len__```, 没有实现```__bool__```, 但是```bool(list)```会根据list的长度返回True或False.
- 接口(Interface)
    - 在OOP中, Interface定义为: A set of **publicly accessible methods and attribute** on an object which can be used by other parts of the program to interact with that object. (概括一下, 接口就是公开的属性和方法的**子集**(这个词很重要, 表明了不是所有公开的方法的集合就是接口), 用于标识object的行为)
    - 在python中, 分为informal intereface和formal interface:
        - informal interface. 即protocol, 即鸭子类型的体现. 不要求接口一定实现, 靠文档和约定规定, python不会强制要求实现. 这是python最常用的, 说实话, 以前我以为在python里都是这样的, 所以不知道接口是什么, 直到遇到了ABC.
        - formal interface. 即是ABC(ABC就是正式接口, 正式接口就是ABC, python没有Interface关键字). ABC定义的abstractmethod, 继承的子类要求必须实现. 靠python强制约束.
        - 一个类可能会实现多个接口, 从而让实例扮演多个角色(角色指的就是类似file-like object, iterable, iteraotr这些).
        - 在python中, 可以只实现部分的接口. 在java不行.
- attribute vs property
    - property是特殊的attribute
- EAFP vs LBYL
    - EAFP. It is **e**asier to **a**sk **f**orgiveness than **p**ermission.
    - LBYL. **L**ook **b**efore **y**ou **l**eep.
    - [这个](https://zhuanlan.zhihu.com/p/36167239)讲得不错
- 多态. oop的多态其实是站在调用者的角度来说. 多态的含义是: 一个接口, 多种实现. 即调用方在不用修改接口的情况下, 可以用同样的接口处理不同数据类型的数据.
## 序列
- ![](D:/Workshop/sphinx/source/_static/python/3.jpg)
- python内置的数列类型:
    - 容器序列(container sequence), 能存放不同类型的数据: list, tuple, collections.deque
    - 扁平序列(flat sequence), 只能容纳一种类型: str, array.array, bytes, bytearray, memoryview
    - 可变序列: list, array.array, collections.deque, bytearray, memoryview
    - 不可变序列: tuple, str, bytes
    - set是无序的, 不是序列
- 如果生成器表达式(generator expression)是一个函数的唯一参数, 则可以不加括号
- 容器序列的元素存放的是对象的引用, 扁平序列的元素是对象的值.
- 使用场合: 
    1. 当序列要存1000万个浮点数, 果断用array
    2. 当要先进先出时, 用deque
- memoryview
- tuple(元组)
    - tuple常常被介绍为: 不可变的序列(immutable sequence). 其实除此之外, 他还有一个duty: 没有字段名的记录(record with no field name). 与它对应的就是nametuple
    - 这么说是因为: tuple元素的数量和位置信息是确定的(不可变序列). 例如, 元组的各个元素分别是一个向量在各个坐标轴上的分量. 这样元素的位置和数量也包含着信息, 改变他们就变成了另外的数据.
    - 也就是说, tuple的元素的意义通常是不一样的(也可以说维度是不同的), 这与list不同. list的元素的地位是相同的(维度是相同的).
- 要初始化一个包含列表的列表:
    - 正确的方式: [['_']*3 for i in range(3)]
    - 错误的方式: [['_'] * 3]*3. 这样每个元素都是相同对象的引用, 改变其中一个元素会引起所有元素的改变.
- 序列的增量赋值(Augmented Assignment)
    - 增量赋值(Augmented Assignment)操作指```+=```和```*=```
    - ```+=```的背后是调用```__iadd__```方法(in-place addition), 对对象进行就地操作, 如果对象没有实现这个方法, 就会调用```__add__```, 此时就变成```a = a + b```. 区别在于, 前者a的id值始终不变, 后者是把```a+b```得到的对象重新赋给a, a的id值改变了.
    - 一般来说, 内置的可变序列都实现了```__iadd__```, 不可变序列由于是不可变的, 不会实现```__iadd__```方法, 因此```+=```时会调用```__add__```
    - 因此, 对不可变序列使用增量赋值的效率很低, 每次都要把旧的对象复制到新的对象里, 但str序列是例外, python对str序列的增量赋值做了优化的.
    - 教训:
        - 增量赋值不是一个原子操作(这点以为着在多线程中要加锁)
        - 不要把可变对象作为元组的元素
- ```list.sort()``` VS ```sorted()```
    - ```list.sort()```会对list进行就地排序, 即不会复制一份对象, 该函数会返回None. 这是Python的惯例: 如果对函数进行就地操作, 就返回None, 让调用者知道传入的参数发生了变动, 而且没有新对象产生.
    - ```sorted()```可以接受所有的可迭代对象, 他会返回一个重新排序的对象, 对传入的参数不会修改, 即复制了一份对象.
    - 两个函数都有两个可选参数```reverse```, ```key```.
## 字典和集合
- dict数据结构在python中至关重要, 所以对他做了高度优化.
- hash table(哈希表)是dict性能出众的根本原因. set的实现也依赖于hash table.要么接受一个映射类型(mapping type)参数; 要么接受一个元素是键值对的可迭代对象.
- 大多数python的映射类型(mapping type)的构造方法都采用这样的逻辑: 
- Generic Mapping Type(泛映射类型)
    - ![](D:/Workshop/sphinx/source/_static/python/2.png)
    - 但是一般自定义的Mapping Type会选择继承自```dict```或```collections.UserDict```而不继承与ABC.
    - set不是Mapping, 他是Set. 因为其没有```value```方法
- 标准库中所有的Mapping Type都是利用dict来实现的. 他们都有一个特点: key必须是可哈希的(hashable).
- hashable对象: 对象的的hash值在其生命周期中不变. 实现```__hash__```和```__eq__```方法.
    - 原子不可变类型一定hashablel: str, bytes, numeric type
    - frozenset一定hashable
    - tuple, 只有当其元素都是hashable的情况下才是hashable.
    - 如果两个对象相等(```==```), 则他们的哈希值(```hash()```)相等, id则不一定相等(```id()```).
- 映射的弹性键查找(Mappings with flexible key lookup)
    有时候希望通过key查询时, 即使key不存在也能返回一个默认值. 有两种方法实现:
        - ```collections.defaultdict()```. ```defaultdict()```接受一个可调用对象作为参数, 当key不存在时, 就返回该可调用对象的返回结果, 并把该key/value存在该mapping中.
        - 自己定义dict子类, 实现```__missing__(key)```方法. mapping对象当```__getitem__```方法找不到key的时候, 都会调用```__missing__(key)```方法. 其他方法找不到key则不会调用```__missing__```, 如```get(key)```, ```__contains__```等.
- 字典的变种
    - ```collections.DefaultDict```, key有默认值
    - ```collections.OrderedDict```, 有顺序
    - ```collections.ChainMap```
        - 接受map对象参数.
        - ```keys()```方法, 返回所有map的key值的迭代器
        - ```values()```方法, 返回所有map的value值得迭代器
        - ```maps```属性, 返回原始的map对象组成的列表
        - ```new_child()```, 接受一个新的map对象组成chainmap. 注意, 这个函数只会创建新对象, 并不会在原来的chainmap对象上加.
    - ```collections.Counter```
    - ```collection.UserDict```. 就是把dict用纯python实现了一遍, 是用来给用户继承写子类的.
- 不可变的映射类型
    - ```from types import MappingProxyType```
    - ```MappingProxyType```不能直接修改元素, 但元素自身可以修改, 并通过```MappingProxyType```观察到.
    - 例:
    ```python
    from types import MappingProxyType

    d = {1: 'A'}
    d_proxy = MappingProxyType(d)

    d_proxy[1]   # 返回A
    d_proxy[2] = 'B'    # 错误, MappingProxyType不可变

    d[2] = 'B'
    d_proxy[2]   # MappingProxyType可以反映元素的修改
    ```
- 集合
    - 集合指set和frozenset
    - frozenset是set的不可变版本
    - 集合的本质是许多唯一对象的聚集, 因此可用于去重
    - 集合的元素要求是hashable的, set本身的不可哈希的; frozenset是set的hashable版本
    - 空的集合应该写作```set()```而不是```{}```
    - 可以实现集合的操作:
        - ```a|b```, 并集
        - ```a&b```, 交集
        ` ```a-b```, 差集
## 文本和字节序列
- 对于字符串```s```, ```s[0]==s[:1]```, 这与其他序列类型不一样.

## 装饰器与闭包
- 内省(xing)(introspection)
    - 定义: In computer programming, introspection is the ability to determine the type of an object at runtime. 
    - ```dir()```, 返回对象的属性, list形式
    - ```inspect.getmembers()```, 返回对象属性, list形式, 元素是tuple, 包含属性名和对象引用.
- 装饰器的两大特性:
    1. 把被装饰的函数替换成其他函数
    2. 装饰器在加载模块时执行, 即装饰器在加载被装饰函数时执行.
- 变量的作用域
    - 
    ```python
        def f(a):
            print(a)
            print(b)
        
        f(3)
     ```
     会报错.

    ```python
        b = 1
        def f(a):
            print(a)
            print(b)
        
        f(3)
     ```
    不会报错

    ```python
        b = 1
        def f(a):
            print(a)
            print(b)
            b = 1        
        f(3)
     ```
    会报错.
    结论: python不要求声明变量, 但在函数体内定义的变量默认是局部变量; 与之对比的是javascrip, 函数体的局部变量必须加```var```否则认为是全局变量.
- 闭包(closure)
    - 定义: a closure is a function with extended scope that encompasses nonglobal variables referencd in the body of the function but not defined there. 闭包是一个衍生了作用域的函数, 他包含了**在函数体中引用**, 但**不在函数体中定义**的**非全局变量**.
    - 那些在函数中被引用, 但不在函数中定义的变量, 称为自由变量(free variable)
    - nonlocal. 如果自由变量在函数中重新赋值, 就会变为本地变量(local). 特别是```+=```这些操作, 可能一不留神就把变量转化为local. 办法是在函数中为自由变量声明```nonlocal```
    - python作用域查找顺序LEBG: Local -> Enclosure -> Buildin -> Global
- 在装饰器函数的里函数加上```functools.wraps(func)```, 效果更佳
- ```functools```里两个有用的装饰器
    1. ```@functools.lru_cache(maxsize, typed)```. 
        1. 注意, ```maxsize```和```typed```这两个是可选参数, 如何都不传参也要保留括号;
        2. ```maxsize```参数指定存储多少个调用的结果; ```typed```参数如果设置为True, 把不同参数类型的结果分开保存, 即把参数1和1.0得到的结果分开存储. 不过一般不必要, 所以他的默认值是False; 
        3. 因为```lru_cache```使用dict存储结果, 而且key是根据函数传入的args, kwargs参数确定, 所以该函数的参数必定要是hashable的, 否则不能作为dict的key.
    2. ```@functools.singledispatch```
- [转义字符串](https://baike.baidu.com/item/%E8%BD%AC%E4%B9%89%E5%AD%97%E7%AC%A6)(Escape Sequence). 也叫字符实体(character entity). 由三部分组成: 1. ```&```符号; 2. 实体名字(entity)或者是```#```加实体(entity)编号; 3. 以```;```结尾

## 可迭代对象, 迭代器和生成器
- 可迭代对象: 实现了```__iter__```方法, 或者实现了```__getitem__```方法, 且索引是从0开始的整数的对象
- 迭代器: 实现了```__iter__```方法, 且实现了```__next__```方法的对象. 其中```__next__```是无参数的方法, 当没有下个元素, ```raise StopIteration```
- Iterable的```__iter__```返回一个Iterator; Iterator的```__iter__```返回self(即当前实例的引用)
- 调用生成器函数, 会返回一个生成器对象.(这句话很有意思, 不妨深入思考一下)
- 在生成器的定义体(statement of body)中, 如果遇到```return```, 会触发生成器的StopIteration异常. 函数return结果, 生成器yield或produce结果.
- 用```for```迭代生成器时, 会在循环体执行前隐式调用```next()```
- 严格来说, 生成器是迭代器, 因为生成器实现了迭代器接口协议; 但迭代器不一定的生成器, 因为生成器的本质是惰性计算, 迭代器不一定需要惰性计算. 但在python里面, 自己实现迭代器是没有意义的, 所以在python里, 通常把生成器和迭代器混为一体.
- 协程 vs 生成器. 协程与生成器的表现很相似, 但绝对不要把他们理解为相同的东西. 生成器的作用是生成(produce/yield)数据; 协程的作用是消耗(consume)数据.
- 协程(coroutine) vs 子程序(subroutine). 子程序指, 一个程序段(函数)执行完后, 再执行另一个程序段; 协程指, 一个程序段执行到```yield```处, 暂停该程序运行, 把控制权交还给调用方, 调用方在执行另一个协程, 从而并发执行程序
- 协程(coroutine) vs 线程(thread)
    - 协程可以说是用户级别的线程. 系统的线程由系统决定线程的切换, 而协程由用户控制在```yield```处切换. 线程的缺点是需要保存上下文(context), 切换线程的消耗CPU资源成本很高; 而协程的上下文由协程自身保存, 不会消耗CPU资源.
- 让协程返回(return)值
    - 协程不一定需要produce/yield值
    - 可以在最后让协程返回(return)一个总的结果, 这个结果保存在StopIteration的value属性里, 用try/except捕获.
- yield from
    - yield from是一个全新的语言结构
    - ```yield from x```对```x```做的第一件事是调用```iter(x)```, 获取他的Iterator, 所以```x```必须是iterable.
    - 为了说明, 引入一些专门术语:
        - 委派生成器(delegating generator). 指包含```yield from iterable```表达式的生成器函数.
        - 子生成器(subgenerator). 即```yielf from iterable```中从itertable获取的generator.
        - 调用方(caller). 指调用委派生成器的客户端代码. 这里用客户端(client)代替, 因为委派生成器也是子生成器的caller, 用client比较明确.
        - 注意, 子生成器可能是只实现了```__next__```方法的简单的iterator, 这种情况下```yield from```也是可以处理的, 但它的真正目的, 是处理实现了```__next__```, ```send```, ```close```, ```throw```方法的generator.
        - 子生成器yield的值, 都传给client
        - client使用```send()```传给委派生成器的值, 都直接传给了子生成器. 委派生成器不会知道传了什么值过来.
        - 综合以上两点, 委派生成器相当于一个双向通道.
        - ```yield from```表达式的值是子生成器终止时传给StopIteration的第一个参数, 即子生成器```return```的值
        - 还有两个关于异常的特性不是很理解. 在<流畅的python>16.8章.

## 上下文管理器和else块(Context Manager and else Block)
- with语句和上下文管理器
    - with的目的在于简化```try/finally```模式, 用于在一段代码执行后完毕后执行某项操作.
- for, while, try语句的else子句
    - else不仅能在if语句中使用, 还能在for, while, try中使用
    - 事实上, 在if以外的场景使用else有点问题. 它的意思实际上变成了"先做某件事, 然后做某件事", 这个时候用```then```会更加合适. 但python极其排斥引入新语句.
    - ```try/else```的意思是, 只有未发生异常, 才执行else块. 即与except
    - 上下文管理器协议(Context Manager Protocol)包含```__enter__```, ```__exit__```两个方法.
    - 与函数和模块不同, with块没有定义新的作用域. 意思是在with块之外依然可以使用with块内定义的变量
    - ```contextlib.contextmanager```装饰器, 把生成器变为一个Context Manger, 自动实现```__enter__```和```__exit__```. 写法是, 他会把```yield```之前的在with块开始时执行(即调用```__enter__```时执行), ```yield```后的内容在with块结束时(即执行```__exit__```时)执行.    

## 继承的优缺点
- Subclassing Build-In Type is Tricky(子类化内置类型会很麻烦). 
    - 直接继承内建类型(list, dict等), 内建类型的方法不会调用用户覆盖的特殊方法.
    - 应该调用```collections```模块里面的类, 如```UserDict```, ```UserList```, ```UserString```等. [collections模块](https://docs.python.org/3/library/collections.html)
- 多重继承和方法的解析顺序
    - python会按照特定顺序遍历继承顺序, 这个顺序就叫MRO(Method Resolution Order)
    - 类都有__mro__属性(实例没有), 该属性返回一个元组, 元组存储了mro顺序.
    - 可以直接通过类调用实例方法, 但要传一个实例参数. ```A.instance_method(self)```vs```a.isnstance_method()```
    - python3的mro用的是C3算法, 个人理解, 类型二叉树查找的后序查找

## asyncio总结
- asyncio还没看懂, 这里把看懂的地方总结一下.
- 首先, 期物对象(future), 指即将完成的对象. 任务(Task)与future差不多, Task是future的子类.
- 在asyncio中很多函数都可以同时接受coroutine(协程), future(期物), 任务(Task)对象. 当接受future, task对象, 将不作处理; 当接受coroutine对象, 会把coroutine打包成future或task
- asyncio定义的coroutine比之前的定义要严格:
    - 1. 需要有```@asyncio.coroutine```装饰器
    - 2. 定义体中必须用```yield from```, 而不用```yield```
    - 3. 注意, python3.5引入了```async```和```await```, ```async```用来代替```asyncio.coroutine```, ```await```代替````yield from```
- 之前说过, 使用```yield from```时, 委派生成器必须由客户端(client)通过```send()```和```next()```调用; 最终的子生成器必须是只含有```yield```的简单生成器或迭代器. 在asyncio中, 这句话依然成立, 只是client变成```get_event_loop```来隐式调用委派生成器; 最终的子生成器必然是asyncio包提供的阻塞函数, 例如```asyncio.sleep()```, 而不是自己写的生成器.

## Dynamic Attribute and Property(动态属性和特性)
- 在python中, 数据的属性和处理数据的方法统称为属性(Attribute), 方法实际上是可调用(callable)的属性.
- 特性(property). 指在不改变类接口的情况下, 用access method(getter, setter)代替public data attribute. 即用```getter()```, ```setter()```方法给属性赋值以及调用属性, 但调用access method是隐性的, 显性还是用属性赋值调用的形式.
- ```__new__```类方法
    - 在python中经常把```__init__```叫做构造方法, 其实严格来说, ```__new__```才是构造方法.
    - ```__new__```是一个类方法, 但它不需要```classmethod```装饰器
    - ```__new__```必须会返回一个实例对象(所以它才是类方法), 并把该实例作为第一个参数```self```传给```__init__```
    - ```__init__```应该叫做初始化方法, 它禁止返回任何值.
- property例子:
```python
class LineItem:
    def __init__(self, description,weight, price):
        self.weight = weight   # 凡是用到weight属性赋值, 都会调用weight.setter
        self.price = price
        self.description = description

    def subtotal(self):
        return self.weight * self.price

    @property
    def weight(self):
        return self.__weight

    @weight.setter
    def weight(self, value):
        if value < 0:
            raise ValueError('Attribute weight must > 0')
        else:
            self.__weight = value
```
- 注意到上面的例子中, 如果要对price属性验证, 就要对price属性进行相同的操作, 这样代码就有了重复. 凡是代码出现了某种模式(pattern), 就要想办法抽象. 抽象(abstract)特性的定义(property definition)有两种方式: 1. 使用特性工厂(property factory); 2. 使用描述符类(descriptor class)实现
- 特性(property)深入解析
    - ```property```虽然经常作为装饰器, 你可能以为他是个函数(返回函数的函数). No, property实际上是个类. 其实在python, 函数和类本质上是一样的, 都是callable object(可调用对象). 只要能返回新的callable object(可调用对象), 类和函数都可以作为装饰器(类的话是通过重写```__new__```, 接受一个函数作为参数, 返回一个新的callable object)
    - ```proerty```构造方法的完整签名如下, ```property(fget=None, fset=None, fdel=None, doc=None)```
    - ```vars(obj)```函数将会返回对象的```__dict__```属性.
    - 在一开始没有```@```用法时候, ```property```是这么用的:
    ```python
    class LineItem2:
        def __init__(self, description, weight, price):
            self.description = description
            self.weight = weight
            self.price = price

        def subtotal(self):
            return self.weight * self.price

        def set_weight(self, value):              # setter方法
            if value < 0:
                raise ValueError('Attriute weight must > 0')
            else:
                self.__weight = value

        def get_weight(self):                     # getter方法
            return self.__weight

        weight = property(get_weight, set_weight) # 特性总是类变量;
    ```
    - property(特性)实际上是**类变量**, 但是它manage通过instace来access的attribute. 即这个类变量access的方式(赋值/取值方式)与一般类变量不同:
        - 当直接通过类访问是, 会返回类变量对象本身, 而不会调用getter方法; 通过实例访问才会调用getter方法
        - 给```obj.attr```, 会先在```obj.__classs__```中查找有没有同名的描述符实例(descriptor), 如果有就调用描述符类的```__set__```或```__get__```方法, 再在obj中查找实例变量, 最后找```obj.__class__```的类变量
    - 承接上面的话题: 特性工厂函数(这个代码看起来很爽, 看不懂的话认真想一下):
    ```python
    def quantity(storage_name):
        def qty_getter(instance):
            return getattr(instance, '__'+storage_name)

        def qty_setter(instance, value):
            if value < 0:
                raise ValueError('value must > 0')
            else:
                return setattr(instance, '__'+storage_name, value)
        return property(qty_getter, qty_setter)

    class LineItemFactory:
        weight = quantity('weight')
        price = quantity('price')

        def __init__(self, description, weight, price):
            self.description = description
            self.weight = weight
            self.price = price

        def subtotal(self):
            return self.weight * self.price
    ```
    - ```property```还有一个参数```fdel```, 传递删值函数, 比较少用, 这里不记录了)(还有一个doc参数,这里也不多说了)
- 处理属性的的重要属性和函数
    - 这部分主要讲关于属性的special method, 书里总结得很好了, 就不炒书了. 在<流传的python>19.6章.

## 描述符(discriptor)
- 描述符是实现特定协议的**类**, 这个协议包括```__get__```, ```__set__```, ```__delete__```. 是对多个属性运用相同存储逻辑的方式. 例如Django的ORM, 把数据库中的字段与属性对应起来.
- 描述符的用法是, 创建一个描述符类, 把描述符类实例化为描述符实例, 作为托管类的类变量.
- 描述符协议:
    1. ```__set__(self, instance, value)```, ```self```是描述符实例, ```instance```是托管类实例, value是要设的值. 这里要注意的是, 值要存储在托管类实例中, 而不是存储在描述符实例. 因为描述符实例是作为类变量, 被所有托管类实例共享的, 所有不应该包含某个特定托管类实例的数据. 
    2 .重写```__set__```和```__get__```方法要注意, **如果用到```instance.attr```那么又会重新调用```__set__```或```__get__```方法, 导致无限递归. 应该用```instance.__dict__```来赋值和读值**.
    3. ```__get__(self, instance, owner)```. ```owner```是托管类的引用, ```instance```是托管类实例的引用. 即使```instance```是None(托管类直接访问属性), ```owner```也还会是托管类的引用.
- 如果```attr```是托管实例```obj```的描述符实例(即类变量). 那么当调用```obj.attr```就会调用描述符的```__get__(self, instance, ower)```方法; 当调用```obj.attr=xxx```就会调用```__set__(self, instance, value)```方法(调用```getattr()```, ```setattr()```也会的). 要绕过描述符, 直接读取或设置```obj```的实例变量, 要使用```__dict__```.
- 描述符协议不必全部实现, 可以只实现一部分接口. ```property```协议是实现了所有协议的类.
- 使用描述符实现特性工厂函数的相同功能:
    - 概念:
        - 描述符类(descriptor class): 实现了描述符协议(description protocol)的类. property就是描述符类
        - 托管类(managed class): 把描述符实例, 声明为类变量的类
        - 托管属性(managed attribute)和储存属性(storage attribute): 储存属性是实例属性; 托管属性是同名的类属性, 是描述符实例. 两者都是托管类实例才有的概念.
    - ```python
        class Quantity:
            def __init__(self, storage_name):
                self.storage_name = storage_name

            def __set__(self, instance, value):
                if value < 0:
                    raise ValueError('value must > 0')
                else:
                    instance.__dict__[self.storage_name] = value


        class LineItemDescriptor:
            weight = Quantity('weight')
            price = Quantity('price')

            def __init__(self, description,weight, price):
                self.description = description
                self.weight = weight
                self.price = price

            def subtotal(self):
                return self.weight * self.price
      ```
- Django的模型字段就是描述符

- 覆盖型描述符 VS 非覆盖性描述符
    - 覆盖型描述符(overriding descriptor), 又叫数据描述符(data descriptor)或强制描述符(enforce descriptor). 指实现了```__set__(self, instance, value)```协议的描述符. 这又可以分为两种情况:
        - 实现了```__set__(self, instance, value)```和```__get__(self, instance, owner)```. 这样对象在调用属性时, 会调用```__get__```, 给属性赋值会调用```__set__```方法. 即使对象存在同名的实例属性, 在调用该属性时, 还是会调用```__get__```方法. 即描述符覆盖掉实例属性
        - 只实现```__set__```方法. 这样赋值的时候一样. 但是调用的时候, 因为没有实现```__get__```方法, 当没有同名的实例变量, 会返回描述符对象本身; 如果存在同名实例变量, 就返回实例变量
    - 非覆盖型描述符(Nonoveriding Descriptor), 又叫非数据描述符(Nondata Descriptor)或遮盖型描述符(shadowable descriptor). 指没有实现```__set__(self, instance, value)```协议的描述符
        - 这种描述符一般都实现了```__get__```方法, 否则就不叫描述符了. 
        - 这种情况, 如果对象设置了同名的实例变量, 实例变量就会覆盖描述符, 使得描述符再也没有办法处理这个属性.
    - ```property```实现了```__set__```, ```__get__```和```__del__```, 属于数据描述符.
    - 因为描述符实例总是作为托管类的类变量, 因此不管是覆盖型还是非覆盖型描述符, 都可以通过给该类变量重新赋值来覆盖掉.
- 方法(method)是描述符
    - 在python中, 用户定义的函数(function)都实现了```__get__```方法, 但没有实现```__set__```方法. 所以当函数出现在类里面, 这个类就成了托管类, 这个函数(方法)就成了描述符.
    - 在python中, 调用```obj.method```, 会返回```bound method xxx```; 调用```cls.method```, 会返回```function xxx```. 这就是```__get__```作用的后果. 
    - 当调用```obj.attr```, ```__get__(self, instance, owner)```收到的参数是: ```self=descriptor instance, instance=obj, owner=obj.__class__```; 当调用```cls.attr```, 收到的参数是: ```self=descriptor instance, instance=None, owner=managed class```. 记住, 函数也是类的属性.
    - 所以, 类的方法(method)的```__get__```方法的逻辑是: 根据```instance```的值判断, 当```instance```是None, 返回方法本身的引用, 即```function```; 否则就返回```bound method```, 相当于```function```加上```instance```参数的偏函数
- 描述符用法建议:
    - 内置的```property```是覆盖型描述符. 
        - 它实现了```__get__```和```__set__```方法. 其中```__set__```方法默认是```raise AttributeError```, 即默认实现只读属性.
    - 只有```__set__```方法的描述符可用于验证属性
        - 只在```__set__```中写验证逻辑, 获取属性直接获取对象的实例属性
    - 只有```__get__```方法的描述符, 可用于高速缓存
        - 即当属性不在对象的```__dict__```时, 调用```__get__```方法计算属性的值, 并存储在```__dict__```, 这样对象下次可以直接在```__dict__```中获取值而不用重新计算. 