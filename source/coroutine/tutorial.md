# 前言

- g.send(None)和next(g)的效果是一样的
- yield后面的表达式是g.send(something), next(g)的返回值
- g.send(somehting)的内容, 将会被```= yield```等号左边的变量获取
- generator和coroutine看似相同, 实际差别很大, 不能混淆.

## 注意
- 假设调用方有语句: ```result=send(val)```, 被调用方(即coroutine)有语句```val=yield some_expression```. 分析其调用过程:
    1. 调用方使用```send(None)```. 则coroutine运行到yield停止, 把some_expression返回给调用方的result.
    2. 调用方继续往下执行, 计算出val的值, 调用```send(val)```. 这时val的值传给了coroutine的val, coroutine往下执行.
总结:
    - send等号左边的变量, 等于yield右边的表达式; send的参数, 发给yield等号左边的变量.

## Iterable(可迭代对象) vs Iterator(迭代器)
- Iterable和Iterator的关系: Python从Iterable中获取Iterator.
    - 把Iterable变成Iterator的方法: ```iter(iterable)```
    - 在Iterator上不断调用```next()```方法, 来获取下一个值.
    - 没有值了会抛出StopIteration异常
    - ```for```语句可以直接迭代iterable, 并且自动处理StopIteration.
- 什么是Iterable:
    - 对象实现了```__iter__```方法
    - 或者对象实现了```__getitem__```方法, **且其参数是从0开始的int**.
- 什么是Iterator
    - 对象实现```__iter__```方法
    - 而且对象实现```__next__```方法(与Iterable不同之处)
- 在Iterator中, ```__iter__```方法应该返回self; 在Iterable中, ```__iter__```方法应该返回iterator实例
- Iterable一定不能自身是Iterator. 即Iterable必须实现__iter__方法, 但不能实现__next__方法

## Iterator vs Generator
- Iterator用于从集合中取出元素; Generator用于凭空生成元素.
- 但在python社区中, 常常把Iterator和Generator视为同一概念.
- 判断一个对象是否是可迭代对象的最准确的方法:
    - ```iter(object)```
    - 用
    ```python
    from collections import abc # Abstract Base Class
    isinstance(object, abc.Iterable)
    ```
    不准确: 当对象实现了```__iter```方法时, 可以检查出来; 当对象只实现```_getitem```方法, 该函数会返回False, 但对象依然是可迭代的.(冷知识, 一般用不到, 因为直接try...except TypeError就行了)

## yield from
- ```yield from``` 后面接可迭代对象(iterable)
- ```Syntax for delegating to a subgenerator```(委托给子生成器的语法)
- ```dir()``` vs ```__dict__```
    - 不是所有对象都有```__dict__```. 有的对象用了```__slots__```类属型就没有了```__dict__```属性(如list), 但还是可以用```dir()```查看他的属性.
    - 只有直接绑定到instance的属性, 才会反映在instance的```__dict__```上. 如类的方法, 类变量不会反映在instance的```__dict__```, 只有实例变量和直接用实例绑定的方法(```obj.func = lambda x: x```)才会反映在instance的```__dict__```上.
    - ```dir()```则会显示所用可用的属性, 包括继承自object的属性.

