# Python异常(Exception)

## 错误的分类
- 语法错误
- 运行时报错(也就是异常)

## EAFP VS LBYL
- It is easier to ask forgivness than perrmission. VS Look before you leap
- python异常处理的理念是EAFP. 好处是:
    - 提高代码易读性
    - 避免用if语句检查, 通常情况下用if语句检查都是违反DRY(Don't repeat yourself)的体现.
    - Look和Leap之间可能不是原子性操作, 即Look之后依然有可能Leap失败.   