## Exceptions(异常)

[文档](http://www.django-rest-framework.org/api-guide/exceptions/)

### 在DRF的视图中处理异常(Exception handling in REST framework views)

DRF视图可以处理多种视图, 并且通过返回合适的响应(response)来处理异常

可以处理的异常有:
- ```APIException```的子类, 在DRF里raise
- Django的```Http404 ```异常
- Django的```PermissionDenied```异常

以上的所有情况, DRF都会返回带合适的```status code```和```content-type```的响应. 响应(response)的正文(body)会包含关于error性质的所有detail

> include any additional details regarding the nature of the error

大多数的```error resposne```会在响应(response)的正文包含key ```detail```
例子: ```{"detail": "Method 'DELETE' not allowed."}```

```Validation error```处理起来稍有不同. 它会在响应(response)中使用字段名(field name)作为key. 如果```validate error```不是具体某个字段, 那么会使用```non_field_errors```作为key, 或者在```setting```中给```NON_FIELD_ERRORS_KEY```设的值. 

### 自定义异常处理(Custom exception handling)

通过创建```handle function```, 可以把在视图(views)中raise的异常传到```resposne object```中, 这样就可以执行自定义的异常处理(exception handler)

这个函数必须携带一对参数:
- ```exc```, 需要处理的异常
- ```context```, 一个dict, 包含需要额外的上下文, 例如: 当前处理的视图
```context```参数在```default exception handler```里没有被用到, 但如果想要返回更详细的信息, 可以通过这个参数实现. 例如, 得到要处理的```view```: ```context['view']```

这个函数必须返回
- ```Response```对象
- 或者是```None```, 如果异常无法处理
如果返回```None```, 则异常会被重新抛出, 并且Django重新返回标准的500```server error```


```exception handler```要在```setting```中被定义:
```python
REST_FRAMEWORK = {
    'EXCEPTION_HANDLER': 'my_project.my_app.utils.custom_exception_handler'
}
```
否则将使用默认的handler:

```python
REST_FRAMEWORK = {
    'EXCEPTION_HANDLER': 'rest_framework.views.exception_handler'
}
```

-------

### API介绍

### APIException

签名: ```APIException()```

在```APIView```类或```@api_view```中raise的所有```exception```的基类.

要自定义```exception```, 继承该基类, 并设置```status_code```, ```default_detail```和```default_code```属性.

有一些有用的属性和方法可以用来检查API exception的状态. 
- ```detail```. 返回异常的文字描述
- ```get_codes()```, 返回错误的```code```
- ```get_full_details()```, 返回文字描述和错误码

在大多数情况下, error detail是简单的item
```python
>>> print(exc.detail)
You do not have permission to perform this action.
>>> print(exc.get_codes())
permission_denied
>>> print(exc.get_full_details())
{'message':'You do not have permission to perform this action.','code':'permission_denied'}
```

validate error则是例外, 其detail是list或dict
```python
>>> print(exc.detail)
{"name":"This field is required.","age":"A valid integer is required."}
>>> print(exc.get_codes())
{"name":"required","age":"invalid"}
>>> print(exc.get_full_details())
{"name":{"message":"This field is required.","code":"required"},"age":{"message":"A valid integer is required.","code":"invalid"}}
```

### ParseError

签名: ```ParseError(detail=None, code=None)```

当请求(request)包含异常的数据是会raise.
默认会返回```status code```: ```400 Bad Request```

### AuthenticationFailed

签名: ```AuthenticationFailed(detail=None, code=None)```

当请求包含不正确的authentication时会raise
默认可以返回```status code```: ```401 Unauthenticated``` 或 ```403 Forbidden```

### NotAuthenticated

签名: ```NotAuthenticated(detail=None, code=None)```

当未验证(authentication)的请求不通过权限检查时会raise

```401 Unauthenticated``` 或 ```403 Forbidden```

### PermissionDenied

签名: ```PermissionDenied(detail=None, code=None)```

当已验证(authentication)的请求不通过权限检查时会raise

### NotFound

签名: ```NotFound(detail=None, code=None)```

当资源不存在时raise, 等同于Django的```Http404```

默认status code是: ```404 Not Found```

## MethodNotAllowed

签名: ```MethodNotAllowed(method, detail=None, code=None)```

当请求方法与视图允许的方法不同一时raise

默认status code: ```405 Method Not Allowed```

## NotAcceptable

签名: ```NotAcceptable(detail=None, code=None)```

当request带```Accept``` header

```406 Not Acceptable```

## UnsupportedMediaType

签名: ```UnsupportedMediaType(media_type, detail=None, code=None)```

## Throttled

签名: ```Throttled(wait=None, detail=None, code=None)```

## ValidationError

签名: ```ValidationError(detail, code=None)```

```ValidationError```与其他```APIException```稍微不同:
- ```detail```参数是必须的, 不是可选的
- ```detail```参数可能是error detail的list或者dict

使用```serializer.is_valid(raise_exception=True)```就意味着需要自定义```exception handler```. 因为格式问题. 如果不用```raise_exception=True```, ```ValidationError```只会返回True和False, 不会raise exception.

---

## 通用错误视图(Generic Error View)

