# Shallow Copy VS Deep Copy

本文参考[这个](https://realpython.com/copying-python-objects/)

- 对于immutable(不可变)对象来说, shallow和deep copy没有区别
- 对于mutable(可变)对象来说, 有区别. shallow copy相当于只复制一层object, deep copy会复制所有的对象. 例如, 一个列表, 用shallow copy只会复制这个列表本身, 但列表的元素还是应用; 而deep copy会把列表的元素也复制一份.
- ```copy.copy```和```list```, ```dict```, ```set```, ```list[:]```方法是shallow copy; ```copy.deepcopy```方法是deep copy
- 注意, 可以发现```tuple(tuple)```和```tuple[:]```会返回相同的引用, 不会创建新的copy.