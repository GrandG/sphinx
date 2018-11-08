## Testing

### APIRequestFactory

Django```RequestFactory```的扩展

### 一. 创建test request

```APIRequestFactory```支持与Django```RequestFactory```一样的API. 这意味着标准的```.get()```, ```.post()```, ```.put()```, ```.patch()```, ```.delete()```, ```.option()```, ```.head()```方法可以使用.

```python
from rest_framework.test import APIRequestFactory

# Using the standard RequestFactory API to create a form POST request
factory = APIRequestFactory()
request = factory.post('/notes/', {'title': 'new idea'})
```

#### 使用```format```参数

对于要创建```request body```的方法, 像```post```, ```put```, ```patch```这些, 可以增加```format```参数, 从未指定除了```multipart form data```以外的```content type```. 例如:

```python
factory = APIRequestFactory()
request = factory.post('/notes/', {'title': 'new idea'}, format='json')
```

默认可选择的```format```是```multipart```和```json```, 为了与Django的```RequestFactory```兼容, 默认的```format```是```multipart```.

为了支持更多的```format```, 或者是改变默认的```format```, 看下面的```configuration section```

#### 显式地encoding ```request body```

如果需要显式地encode ```request body```, 你可以设置```content_type``` flag. 例如:

```python
request = factory.post(
    '/notes/',
    json.dumps({'title': 'new idea'}),
    content_type='application/json')
```

#### PUT and PATCH with form data

Django的```RequestFactory```和DRF的```APIRequestFactory```的一点差异是: ```multipart form data```会在```post()```以外的方法也会被encode

使用```APIRequestFactory```, 使用```PUT```请求:
```python
factory = APIRequestFactory()
request = factory.put('/notes/547/', {'title': 'remember to email dave'})
```

使用```RequestFactory```, 需要手动encode

```python
from django.test.client import encode_multipart, RequestFactory

factory = RequestFactory()
data = {'title': 'remember to email dave'}
content = encode_multipart('BoUnDaRyStRiNg', data)
content_type = 'multipart/form-data; boundary=BoUnDaRyStRiNg'
request = factory.put('/notes/547/', content, content_type=content_type)
```

### 二. 强制```authentication```

当直接使用```request factory```测试view, 直接authenticated request是比较方便的方法. 

使用```force_authenticate()```方法

```python
from rest_framework.test import force_authenticate

factory = APIRequestFactory()
user = User.objects.get(username='olivia')
view = AccountDetail.as_view()

# Make an authenticated request to the view...
request = factory.get('/accounts/django-superstars/')
force_authenticate(request, user=user)
response = view(request)
```

这个method的签名是```force_authenticate(request, user=None, token=None)```, 当调用的时候, ```user```或```token```两个参数或其中一个需要被设置.

### 三. APIClient

Django```Client```类的扩展

#### Making requests

```APIClient```类支持Django```Client```类相同的接口. 这意味着标准的```.get()```, ```.post()```, ```.put()```, ```.patch()```, ```.delete()```, ```.option()```, ```.head()```方法可以使用. 例如:

```python
from rest_framework.test import APIClient

client = APIClient()
client.post('/notes/', {'title': 'new idea'}, format='json')
```

为了支持更多的request format, 看下面的```configuration section```

#### Authenticating

---------

```python manage.py test --keepdb```报错
```
Got an error creating the test database: (1064, "You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'CREATE DATABASE IF NOT EXISTS `test_tdcmdb` CHARACTER SET utf8mb4;\n             ' at line 2")
``` 

解决:

```\venv\Lib\site-packages\django\db\backends\mysql\creation.py```
27行
```python
'''
    SET @_tmp_sql_notes := @@sql_notes, sql_notes = 0;
    CREATE DATABASE IF NOT EXISTS %(dbname)s %(suffix)s;
    SET sql_notes = @_tmp_sql_notes;
'''% parameters)
```

改为
```python
CREATE DATABASE IF NOT EXISTS %(dbname)s %(suffix)s;
```

(只保留第二行)

[相同的遭遇](http://program.dengshilong.org/2018/06/19/Django%E5%8D%95%E5%85%83%E6%B5%8B%E8%AF%95keepdb%E5%8F%82%E6%95%B0/)

---

初始化数据库

[文档](https://docs.djangoproject.com/en/2.1/howto/initial-data/)
