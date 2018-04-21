# Authetication

- Authnentication是把接受的request关联credential的机制
- 然后permission和throttle机制再根据credential来决定该request是否被允许
- 也就是说, authentication本身不会allow或disallow一个request
- authentication总是在view的最前面运行, 甚至在permission和throttle执行之前

## 设置authentication方案
- authentication可以在两个地方被设置
    1. 在setting设置
    ```python 
    REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework.authentication.BasicAuthentication',
        'rest_framework.authentication.SessionAuthentication',

    }
    ```
    2. 在视图设置```permission_classes ```
    ```python
        from rest_framework.authentication import SessionAuthentication, BasicAuthentication
        from rest_framework.permissions import IsAuthenticated
        from rest_framework.response import Response
        from rest_framework.views import APIView


        class ExampleView(APIView):
            authentication_classes = (SessionAuthentication, BasicAuthentication)
            permission_classes = (IsAuthenticated,)

            def get(self, request, format=None):
                content = {
                    'user': unicode(request.user),  # `django.contrib.auth.User` instance.
                    'auth': unicode(request.auth),  # None
                }
                return Response(content)
    ```

## unauthentication
- HTTP 401 Unauthorized
- HTTP 403 Permission Denied

## 具体的authentication方案
- BasicAuthentication, 建议只测试用

- TokenAuthentication
    - 具体操作看文档
    - 缺点是, 依然要在数据库存储token信息, 看不出和session base的区别
    - 框架没有提供token过期的设置, 这样很危险

- SessionAuthentication
    - 没怎么看, 感觉很水

## 第三方方案
- djangorestframework-jwt
### JWT(Json Web Token)
- 包含三个部分:
    - Header(头部)
    - Payload(载荷)
    - Signature(签名)
- Token的组成: ```BASE64(Header).BASE64(Payload).HASH256(BASE64(Header).Base64(Payload), secret_key)```
- 可以看出, Header和payload都是经过编码后就直接作为token, 因此容易被反编码得到数据, 因此, **token不能存敏感信息**. 
- 使用JWT的好处是一定程度上可以防止CSRF攻击
    - CSRF攻击是指, 当在一个正规网站完成转账操作后, 没有正确退出, 而把cookie保留了下来; 这时候访问一个恶意网站, 该网站包含一些隐藏的表单, 当误点提交按钮或者网站直接用js提交表单, 就会把隐藏表单连同cookie一起提交, 实现用户不知情的情况下的转账操作
    - 因此通常会在cookie和表单上设置一串相同的字符串, 提交的时候要把该字符串一起提交, 也就是csrf_token
    - jwt是验证后在响应头里返回的token, 因此恶意网站无法获取; 如果jwt要记录到cookie里面, 就必须设置http-only为True, 使得无法通过js获取cookie内容.