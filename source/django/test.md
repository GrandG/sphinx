## Writin and running test
** 这一部分分为两个部分: 解释django如何写测试; 解释如何运行测试 **
### How to write

Django使用python的unittest库.<br \>
以下是一个使用django.test.TestCase的例子, django的TestCase实际上继承者unnitest.TestCase

```Python
from django.test import TestCase
from myapp.models import Animal

class AnimalTestCase(TestCase):
    def setUp(self):
        Animal.objects.create(name="lion", sound="roar")
        Animal.objects.create(name="cat", sound="meow")

    def test_animals_can_speak(self):
        """Animals that can speak are correctly identified"""
        lion = Animal.objects.get(name="lion")
        cat = Animal.objects.get(name="cat")
        self.assertEqual(lion.speak(), 'The lion says "roar"')
        self.assertEqual(cat.speak(), 'The cat says "meow"')
```

    当你运行该测试(下面会讲如何运行), django的机制会找到所有以test开头的文件, 自动为这些test case建立test suite, 并运行这些test suite.

开始的时候可以把测试文件写在自动生成的test.py文件中, 后面test suite变大之后可以建立一个tests pacage专门存放test文件<br \>
** 警告: 如果你的测试依赖于数据库交互, 那么创建的Test Class必须继承django.test.TestCase, 而不能继承与unittest.TestCase. 继承unittest.TestCase可以避免运行测试时与数据库交互的成本, 但是如果你写的测试要与数据库交互会广泛依赖于test runner执行的顺序(不太理解) **

>Warning

>If your tests rely on database access such as creating or querying models, be sure to create your test classes as subclasses >of django.test.TestCase rather than unittest.TestCase.

>Using unittest.TestCase avoids the cost of running each test in a transaction and flushing the database, but if your tests >interact with the database their behavior will vary based on the order that the test runner executes them. This can lead to >unit tests that pass when run in isolation but fail when run in a suite.


### How to run

```python manage.py test``` 会运行在当前工作目录下, 所有以test开头的py文件, 也可以用.分割单独运行某个module下的测试文件, 注意最后的py文件省略.py后缀

### The Test Database(看不太懂)

需要数据库的测试(即model tests), 不会使用真实的数据库, 而是为测试创建**空白(blank)**的数据库.
<br \>
无论测试是成功还是失败, 当所有的测试都被执行时, 测试数据库将被销毁.
<br \>
可以通过向测试命令test后加 --keepdb参数防止测试数据库被破坏. 这将在运行之间保留数据库, 如果数据库不存在, 他将首先被创建.

### Order in which tests are executed

## Testing tools

### The test client
The test client(测试客户端)就像一个虚拟的浏览器, 允许你通过编码的方式测试你的View并与app交互.
你可以用test client来:
- 模拟对URL惊醒GET/POST请求, 并观察response-从低层次的HTTP(result header或status codes)到网页内容的所以.
- 看重定向链(如果有的话), 并在每个步骤中检查URL和状态码
- 测试一个特定的request会被特定的template渲染, 用包含特定值的template context.

    ** 注意the test client不是要不是要体到selenium或其他的in-browser框架. Django的test client有不同的关注点:**

- 用Django的test client来确定特定的模板在用正确的context data渲染.
- 使用in-browser的框架(Selenium)来测试渲染的HTML和网页的动作(即Javascript). Django同时提供特殊的支持for这些框架, 看章节[ LiveServerTestCase](https://docs.djangoproject.com/en/2.0/topics/testing/tools/#django.test.LiveServerTestCase)了解更多细节.

### 例子
```Python
>>> from django.test import Client
>>> c = Client()
>>> response = c.post('/login/', {'username': 'john', 'password': 'smith'})
>>> response.status_code
200
>>> response = c.get('/customer/details/')
>>> response.content
b'<!DOCTYPE html...'
```

注意到:

- The test client不需要Web server在运行. 这使得他可以很快地运行.
- 接受网站信息时, 注意到只要求声明URL的路径, 不需要完整的域名. 例如: ```>>> c.get('/login/')```是正确的; ```>>> c.get('https://www.example.com/login/')```是错误的
- The test client不能接受不是又你的Django powered的网址, 要使用别的网站, 使用Python的标准库urllib.
- Although the above example would work in the Python interactive interpreter, some of the test client’s functionality, notably the template-related functionality, is only available while tests are running.
The reason for this is that Django’s test runner performs a bit of black magic in order to determine which template was loaded by a given view. This black magic (essentially a patching of Django’s template system in memory) only happens during test running.
- 默认情况下, Django将会关闭由你的站点执行的CSRF检查. 可以通过在构建Test client时传递enforce_csrf_checks 来开启.
```Python
>>> from django.test import Client
>>> csrf_client = Client(enforce_csrf_checks=True)
```

## Advanced testing tools