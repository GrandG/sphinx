# Pagination分页

分页只有在使用```generic.views```或```generic.viewsets```才可以自动使用.

如果用```APIView```, 需要手动调用分页API. 参考```mixins.ListModelMixin```和```generics.GenericAPIView```.

## 设置分页样式
设置全局分页样式:
```python
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.LimitOffsetPagination',
    'PAGE_SIZE': 100
}
```
```DEFAULT_PAGINATION_CLASS```和```PAGE_SIZE```默认是```None```

设置单个视图的分页样式:
- 设置```pagination_class```类属性.
- 不过一般情况下API应该使用同一的分页样式., 但可能会需要自定义```page size```

## 修改分页样式
如果你想要修改某一类的分页样式, 可以重写该pagination class, 把其类属性改成你想要的.
```python
class LargeResultsSetPagination(PageNumberPagination):
    page_size = 1000
    page_size_query_param = 'page_size'
    max_page_size = 10000

class StandardResultsSetPagination(PageNumberPagination):
    page_size = 100
    page_size_query_param = 'page_size'
    max_page_size = 1000
```

可以通过设置```pagination_class```类属性来应用新的分页样式
```python
class BillingRecordsView(generics.ListAPIView):
    queryset = Billing.objects.all()
    serializer_class = BillingRecordsSerializer
    pagination_class = LargeResultsSetPagination
```
或者在全局应用, 使用```DEFAULT_PAGINATION_CLASS```
```python
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'apps.core.pagination.StandardResultsSetPagination'
}
```

## API介绍
### PageNumberPagination
这个分页样式接受一个页码数字作为**请求查询参数**
Requeset
```
GET https://api.example.org/accounts/?page=4
```

Response
```
HTTP 200 OK
{
    "count": 1023
    "next": "https://api.example.org/accounts/?page=5",
    "previous": "https://api.example.org/accounts/?page=3",
    "results": [
       …
    ]
}
```

设置:
```python
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 100
}
```
配置:
```PageNumberPagination```包含一系列属性可被重写来修改分页样式
为了设置这些属性, 你应该重写```PageNumberPagination ```类, 重写以下参数:
- ```django_paginator_class```: 默认是```django.core.paginator.Paginator```, 大多数情况不用改
- ```page_size```: 一个数字, 指示page size. 当设置之后会覆盖掉setting中的```PAGE_SIZE```的值. 默认的值与```PAGE_SIZE```相同 
- ```page_query_param```: 一个字符串, 指示使用的查询参数的名称, 默认值是```page```
- ```page_size_query_param```: 如果设置了, 用户可以使用这个字符串参数来设置page size. 默认值是None, 意味着用户不能自定义page size
- ```max_page_size```: 只有在```page_size_query_param```设置了的情况下才起作用. 指示允许设置的page size的最大值.
- ```last_page_strings```: 默认值是```('last',)```. 一个list或tuple, 用来请求从后面开始的页. 
- ```template```: 默认是```"rest_framework/pagination/numbers.html"```

----

## LimitOffsetPagination
这种分页样式与数据库多表查询的语法一致. ```limit```指示显示的数量, 与```page size```的意义一样; ```offset```指示从第几条开始显示
Request:
```GET https://api.example.org/accounts/?limit=100&offset=400```
Response:
```http
HTTP 200 OK
{
    "count": 1023
    "next": "https://api.example.org/accounts/?limit=100&offset=500",
    "previous": "https://api.example.org/accounts/?limit=100&offset=300",
    "results": [
       …
    ]
}
```
配置参数: 
```default_limit```: 一个数字, 如果```limit```参数没有就用这个参数. 默认值与```PAGE_SIZE```相同. 
```limit_query_param```: 用来命名```limit```的query parameter. 默认值是```limit```.
```offset_query_param```: 用来命名```offset```的query paremeter. 默认值是```offset```.
```max_limit```: 指示最大可以设的```limit```值. 默认是```None```
```template```: 应该用不到

---

## CursorPagination

这种分页只用于前进(forward)和后退(backward), 不能用于指定跳到某一页(适合app)

这种分页要求有一个唯一, 不重复, 不变的字段, 根据该字段排序, 一般最合适的是时间

记录的相对顺序不变

优点:

1. 提供持续的分页视图. 确保不会出现重复的内容
2. 但数据量很大时, 性能很好

细节和界限

使用cursor pagination要满足一下条件:
1. 要有一个不变的字段. 比如timestamp或者其他只会设置一次, 且不变的的字段
2. 应该要唯一, 或者接近唯一. Millisecond精度的timestamp就是一个很好的例子. 
3. 不要是个浮点数
4. 这个字段应该要设为index

不过不满足以上条件, 多数情况下还是可以work. 但会失去一些重要的好处.

使用

全局使用

```python
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.CursorPagination',
    'PAGE_SIZE': 100
}
```

局部使用

把```pagination_class```类属性设为```CursorPagination```

配置

```CursorPagination```可以自定义一些属性

- ```page_size```: 每页条数

- ```cursor_query_param```: 默认时```cursor```

- ```ordering```:  string, 或者 list of strings. ```cursor based```分页的依据. 默认是```-created```