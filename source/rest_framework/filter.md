# Filter

## 过滤最简单的方法是重写```get_queryset```方法
1. 根据当前请求的用户过滤
```python
from myapp.models import Purchase
from myapp.serializers import PurchaseSerializer
from rest_framework import generics

class PurchaseList(generics.ListAPIView):
    serializer_class = PurchaseSerializer

    def get_queryset(self):
        """
        This view should return a list of all the purchases
        for the currently authenticated user.
        """
        user = self.request.user
        return Purchase.objects.filter(purchaser=user)
```
2. 根据URL过滤

当前的url是:
```python
url('^purchases/(?P<username>.+)/$', PurchaseList.as_view()),
```
视图根据url的内容过滤
```python
class PurchaseList(generics.ListAPIView):
    serializer_class = PurchaseSerializer

    def get_queryset(self):
        """
        This view should return a list of all the purchases for
        the user as determined by the username portion of the URL.
        """
        username = self.kwargs['username']
        return Purchase.objects.filter(purchaser__username=username)
```
3. 根据查询参数过滤

当前请求的url是:
```http://example.com/api/purchases?username=denvercoder9```

视图根据请求参数过滤:

```python
class PurchaseList(generics.ListAPIView):
    serializer_class = PurchaseSerializer

    def get_queryset(self):
        """
        Optionally restricts the returned purchases to a given user,
        by filtering against a `username` query parameter in the URL.
        """
        queryset = Purchase.objects.all()
        username = self.request.query_params.get('username', None)
        if username is not None:
            queryset = queryset.filter(purchaser__username=username)
        return queryset
 ```

## Generic Filter(通用过滤)

效果: ```http://example.com/api/products/4675/?category=clothing&max_price=10.00```
设置步骤:

1. ```pip install django-filter```
2. 设置filter_backend, 有两种方法:
    1. 在```setting.py```设置:
        ```python
        REST_FRAMEWORK = {
            'DEFAULT_FILTER_BACKENDS': ('django_filters.rest_framework.DjangoFilterBackend',)
        }
        ```
    2. 在```view```或```viewset```中设置类变量:
        ```python
        import django_filters.rest_framework
        from django.contrib.auth.models import User
        from myapp.serializers import UserSerializer
        from rest_framework import generics

        class UserListView(generics.ListAPIView):
            queryset = User.objects.all()
            serializer_class = UserSerializer
            filter_backends = (django_filters.rest_framework.DjangoFilterBackend,)
        ```
3. 在```setting.py```的```INSTALL_APP```里加上```django_filters```.(坑, 官方文档没有说这个, 导致找了很久)
4. 在```view```或```viewset```里设```filter_fields```类属性, 表示用作过滤的字段. 
    ```python
    filter_fields = ('category', 'in_stock')
    ```
这样写可以联合查询, 如:
```http://example.com/api/products?category=clothing&in_stock=True```

## SearchFilter(过滤器)
步骤:
1.  设置类属性:
    ```python   
    filter_backends = (filters.SearchFilter,)
    search_fields = ('username', 'email')
    ```

    - 注意: ```search_fields```应该是model的text type fields. 例如: ```Charfield```, ```TextField```这些 
2. 请求的url改为```http://example.com/api/users?search=russell```

## OrderingFilter(排序过滤器)
步骤:
1. 设置类属性:
    ```python
    filter_backends = (filters.OrderingFilter,)
    ordering_fields = ('username', 'email')
    ordering = ('username',)
    ```
    - ```ordering_fields```可以设为```"__all__"```, 这样可以对所有字段排序
    - ```ordering```是设置默认排序