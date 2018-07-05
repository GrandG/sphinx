# 格式化
- 两种格式化方法: ```format()```函数; ```str.format()```函数
- ```format()```函数和```str.format()```方法把各个类型的对象的格式化方法委托给```___format__(format_spec)```方法. 即实现了```__format__(format_spec)```方法的对象, 可以用```format_spec```参数格式化显示.
- ```format_spec```使用的表示法叫[格式规范微语言](https://docs.python.org/3/library/string.html#formatspec)

```python
>>> brl = 1/2.43 # BRL到USD的货币兑换比价
>>> brl
0.4115226337448559
>>> format(brl, '0.4f') # ➊
'0.4115'
>>> '1 BRL = {rate:0.2f} USD'.format(rate=brl) # ➋
'1 BRL = 0.41 USD'
```

## format()函数
- 第一个参数是目标字符串```str```, 第二个参数是```format_spec```是格式说明符


## str.format()方法
- 在```{}```中```:```后可以加```format_spec```参数

