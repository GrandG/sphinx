# Python的时间处理

## 时间戳(timestamp)
- 别名: Unix时间戳(Unix timestamp), Unix时间(Unix time), POSIX时间(POSIX time   )
- 时间戳是指距离格林威治时间1970年01月01日00时00分00秒(北京时间1970年01月01日08时00分00秒)起至现在的总秒数.
- 同一时间任何地方的时间戳是一样的.
-  = -bit overflow）而无法继续使用

## time VS datetime
- python有两个处理时间的模块: ```time```, ```datetime```
- ```time```是用C写的, 是对操作系统的调用; ```datetime```是用python写的 
- ```datetime```主要包含以下几个类:
    - ```timedelta```, 计算时间跨度
    - ```tzinfo```, 时区相关
    - ```time```, 只关注时间
    - ```date```, 只关注日期
    - ```datetime```, 同时关注时间和日期

## datetime
- 对于一个```datetime.datetime```类的实例, 它拥有以下属性和方法:
```python
datetime.year
datetime.month
datetime.day
datetime.hour
datetime.minute
datetime.second
datetime.microsecond
datetime.tzinfo

datetime.date() # 返回 date 对象
datetime.time() # 返回 time 对象
datetime.replace(name=value) # 前面所述各项属性是 read-only 的，需要此方法才可更改
datetime.timetuple() # 返回time.struct_time 对象
dattime.strftime(format) # 按照 format 进行格式化输出
```
- 同时```datetime.datetime```类还提供一下方法:
```python
datetime.today()a  # 当前时间，localtime
datetime.now([tz]) # 当前时间默认 localtime
datetime.utcnow()  # UTC 时间
datetime.fromtimestamp(timestamp[, tz]) # 由 Unix Timestamp 构建对象
datetime.strptime(date_string, format)  # 给定时间格式解析字符串
```

## python时间操作
- 获取当前时间戳
```python
from time import time
time.()
# 1532222744.5047288
```
- 把时间戳转为datetime对象
```python
from datetime import datetime
from time import time
# datetime.datetime(2018, 7, 22, 9, 44, 48, 289185)
```

- 本地时间与格林尼治时间
```python
import time
time.localtime()  # 本地时区时间
# time.struct_time(tm_year=2018, tm_mon=7, tm_mday=22, tm_hour=9, tm_min=48, tm_sec=7, tm_wday=6, tm_yday=203, tm_isdst=0)
time.gmtime()     # 格林尼治时间
# time.struct_time(tm_year=2018, tm_mon=7, tm_mday=22, tm_hour=1, tm_min=48, tm_sec=20, tm_wday=6, tm_yday=203, tm_isdst=0)
```

- 时间字符格式化
```python
import time

time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())
# '2018 07 22 10:00:59'
```