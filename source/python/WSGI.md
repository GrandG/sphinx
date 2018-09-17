# WSGI

[PEP3333](https://www.python.org/dev/peps/pep-3333/)

### 前言
[pep3333](https://www.python.org/dev/peps/pep-3333/)是对[pep333](https://www.python.org/dev/peps/pep-0333/)的update, 主要为了兼容python3

### 摘要
这份文档的目的是提出Web Server和Framework的Application之间的标准接口(Interface). 从而提高Web Application对于Web Server的可移植性.

### 目的
Python有很多的Web框架. 然后这么多的Web框架会带来一个缺点: 在选择一个Web框架的时候, 同时也会限制可以选择的Web Server.

对比而言, 尽管JAVA也有同样多的Web框架, JAVA的```servlet```API让用任何Web框架写的Application可以运行在任何实现了```servlet```的Web Server上成为可能.

对于Python来说, Web Server的这种API的可用性和通用性, 可以把选择Web框架和选择Web Server解耦.

因此, 这个PEP旨在提出一种通用且简单的接口(interface)用于Web Server和Web框架: ```the Python Web Server Gateway Interface(WSGI)```

为了WSGI的推广, 在application端和server端都要使用简单, 这是该接口设计的基本原则. WSGI存在的目的是使当前已存在的Web框架和Web Server互相连接, 而不是创建一个新的Web框架


### 详情预览
这个WSGI有两面: 一面是```server```或```gateway```; 另一面是```application```或```framework```. ```server```端调用(invoke)一个由```application```端提供的```callable对象```. 关于如何提供这个```object```的细节, 由```server```或者```gateway```决定. 一般来说```server```或```gateway```要求```application```的开发者写一个脚本来创建```server```或```gateway```的实例, 并且使用```application对象```来作为它的参数. 其他情况下, 则是```server```或```gateway```通过配置文件或者其他机制来获取```application对象```.

除了"纯的"```server/gateway```端和```application/framework```端, 还有在两端都执行的```MiddleWare```组件. 这个组件, 在```application```端扮演```server```的角色, 在```server```端扮演```application```的角色, 可以用来提供扩展的API, 内容转换, navigation, 和其他又用的函数.

在这个spec中, 我们使用术语```callable```来代表```function, method, class或者是实现了__call__方法的instance```. ```server```, ```gateway```或包含了```callable```的```application```决定如何调用```callable```. 

#### A Note on Sring Types
总体来说, HTTP是与```bytes```打交道, 这意味着这份spec大部分是关于如何处理```bytes```

然后, 这些```bytes```的内容经常有着文字的(textual)含义. 而在Python中, String是处理文字(text)最方便的方法.

但是在Python的很多实现和版本中, ```String```是```Unicode```, 而不是```bytes```. 这就需要小心地平衡可用的API和在```bytes```和```text```之间正确的转换.

因此WSGI定义了两种```string```:
- "Native" strings. 使用```str```类型实现. 用于request/response的header和metadata
- "Bytestrings". 在python3中使用```bytes```类型实现. 在request/response的body中使用. (eg. POST/PUT的输入参数, HTML的内容)

但是, 不要混淆了. 尽管python的```str```实际上是Unicode, 但是native string的内容还是要encode转换成```bytes```

一句话. 当你在这篇文档中看到```string```, 它代表native string, 是```str```的对象. 当看到```Bytestring```, 应该理解为python3中的```bytes```对象, python2中的```str```对象. 

#### Application/Framework端
这个```application```对象是一个接受两个参数的```callable对象```. 这里```对象```不应该误解为类的实例, 而应该理解为```function, method, class, 实现了__class__的instance```. ```application对象```必须要能被多次调用, 因为```server```/```gateway```将多次生成```request```.

这里有两个```application对象```的例子, 一个是```function```, 一个是```class```

```python
HELLO_WORLD = b"Hello world!\n"

def simple_app(environ, start_response):
    """Simplest possible application object"""
    status = '200 OK'
    response_headers = [('Content-type', 'text/plain')]
    start_response(status, response_headers)
    return [HELLO_WORLD]
```

```python
class AppClass:
    """Produce the same output, but using a class

    (Note: 'AppClass' is the "application" here, so calling it
    returns an instance of 'AppClass', which is then the iterable
    return value of the "application callable" as required by
    the spec.

    If we wanted to use *instances* of 'AppClass' as application
    objects instead, we would have to implement a '__call__'
    method, which would be invoked to execute the application,
    and we would need to create an instance for use by the
    server or gateway.
    """

    def __init__(self, environ, start_response):
        self.environ = environ
        self.start = start_response

    def __iter__(self):
        status = '200 OK'
        response_headers = [('Content-type', 'text/plain')]
        self.start(status, response_headers)
        yield HELLO_WORLD
```

#### Server/Gateway端
```server```或```gateway```每收到一个```HTTP Client```的```request```就调用一次```application对象```. 为了方便说明, 这里有一个简单的CGI```gateway```, 它是一个接收```application对象```参数的```function```. 注意到这个简单的例子处理error的能力有限, 因为默认了一个未捕捉到的```exception```将会被Web Server丢到```sys.stderr```和```logged``` 

```python
import os, sys

enc, esc = sys.getfilesystemencoding(), 'surrogateescape'

def unicode_to_wsgi(u):
    # Convert an environment variable to a WSGI "bytes-as-unicode" string
    return u.encode(enc, esc).decode('iso-8859-1')

def wsgi_to_bytes(s):
    return s.encode('iso-8859-1')

def run_with_cgi(application):
    environ = {k: unicode_to_wsgi(v) for k,v in os.environ.items()}
    environ['wsgi.input']        = sys.stdin.buffer
    environ['wsgi.errors']       = sys.stderr
    environ['wsgi.version']      = (1, 0)
    environ['wsgi.multithread']  = False
    environ['wsgi.multiprocess'] = True
    environ['wsgi.run_once']     = True

    if environ.get('HTTPS', 'off') in ('on', '1'):
        environ['wsgi.url_scheme'] = 'https'
    else:
        environ['wsgi.url_scheme'] = 'http'

    headers_set = []
    headers_sent = []

    def write(data):
        out = sys.stdout.buffer

        if not headers_set:
             raise AssertionError("write() before start_response()")

        elif not headers_sent:
             # Before the first output, send the stored headers
             status, response_headers = headers_sent[:] = headers_set
             out.write(wsgi_to_bytes('Status: %s\r\n' % status))
             for header in response_headers:
                 out.write(wsgi_to_bytes('%s: %s\r\n' % header))
             out.write(wsgi_to_bytes('\r\n'))

        out.write(data)
        out.flush()

    def start_response(status, response_headers, exc_info=None):
        if exc_info:
            try:
                if headers_sent:
                    # Re-raise original exception if headers sent
                    raise exc_info[1].with_traceback(exc_info[2])
            finally:
                exc_info = None     # avoid dangling circular ref
        elif headers_set:
            raise AssertionError("Headers already set!")

        headers_set[:] = [status, response_headers]

        # Note: error checking on the headers should happen here,
        # *after* the headers are set.  That way, if an error
        # occurs, start_response can only be re-called with
        # exc_info set.

        return write

    result = application(environ, start_response)
    try:
        for data in result:
            if data:    # don't send headers until body appears
                write(data)
        if not headers_sent:
            write('')   # send headers now if body was empty
    finally:
        if hasattr(result, 'close'):
            result.close()
```

#### Middleware: 在两端同时存在的组件
必须要知道, 一个对象可能对```server```端扮演```application```的角色, 对```application```端扮演```server```的角色. 这种```Middleware组件```可以:
- 根据url的不同把```request```路由(route)到不同的```application```对象.
- 允许多个```application```或```framework```在相同的进程中一起运行
- Load balancing and remote processing, by forwarding requests and responses over a network
- 执行内容的后期处理

Middleware的存在对```server```和```application```来说是透明的, 而且不需要额外的支持. 用户想要在```application```中使用```Middleware```, 只需要对```server```提供```middleware组件```, 这个时候把它当作```application```, 并且把```middlerware```配置成调用```application```, 这个时候把它当作```server```. 当然这时候```middleware```调用的```application```, 有可能是另外一个包含了```application```的```middleware```, 这样就创建了所谓的```middleware stack```.

大多数情况下, ```middleware```只需要服从WSGI中对于```server```和```application```的限制和要求. 但是, 在某些情况下, 对```middleware```的要求比"纯的"的```server```和```application```更严格. 

### 详情细节
```application对象```必须接受两个位置参数. 为了方便说明, 我们把这两个参数叫做```environ```和```start_response```, 但实际上他们不一定要这么命名. ```server```或```gateway```必须使用这两个位置参数来调用```application对象```. (例子: ```result = application(environ, start_response)``` ) 

```environ```参数是一个dict对象, 包含CGI-style的```environment variables```. 这个对象必须是python的内建dict对象(不能是他的子类, UserDict这些), 而且```application```可以根据需要修改这个```environ```参数.  这个dict对象必须包含WSGI要求的变量(会在下面谈到), 并且可能需要包含针对```server```(server-specific)的变量.

```start_response```参数是一个接受两个必要的位置参数和一个可选参数的```callable对象```. 为了方便说明, 这三个参数分别叫做```status```, ```response_headers```和```exc_info```, 同样, 这些参数可以另外自己命名. ```application```对象必须使用这些位置参数来调用```start_response```对象. (例子: ```start_response(status, response_headers)```)

```status```参数是一个状态```string```, 格式是```"999 Message here"```. ```response_headers```是一个元素是```(header_name, header_value)```元组的list, 描述HTTP的```response header```. 可选的```exc_info```参数将在下面谈到. 它只在```application```捕获一个```error```并且打算把这个```error```展示给browser的时候会用到.

```start_response```对象必须返回```write(body_data)```的接收一个位置参数的```callable```: 一个写作```HTTP response body```的一部分的```bytestring```. (注意: 这个```write()```只是用来支持某些已存在的```framework```, 新出的```application```或```framework```应该尽量避免使用这个```callable```)

当```application```被```server```调用, 它必须返回一个```yield``` zero或者是更多的```bytestrings```的```iterable```

The server or gateway should treat the yielded bytestrings as binary byte sequences: in particular, it should ensure that line endings are not altered. The application is responsible for ensuring that the bytestring(s) to be written are in a format suitable for the client. (The server or gateway may apply HTTP transfer encodings, or perform other transformations for the purpose of implementing HTTP features such as byte-range transmission. See Other HTTP Features, below, for more details.)

如果调用```len(iterable)```成功, ```server```必须能够依赖于这个结果的正确性. 也就是说, 如果```application```返回```iterable```实现了```__len__()```方法, 它必须要能返回正确的结果.

如果这个```application```返回的```iterable```实现了```close()```方法, ```server```或```gateway```必须调用这个方法来结束当前```request```, 不管是因为正常完成```request```, 还是由于再迭代(iterate)过程中由于```application error```而提前被终结或者是由于浏览器提前终止连接.

返回```generator```或其他传统的```iterator```的```application```不应该假定这个```iterator```一定会被consume, 因为它可能会被```server```提前close.

(注意: ```application```必须要在```iterable```产出(yield)第一个body bytestrings之前调用```start_response()```, 这样```server```可以在有任何body content之前发送header. 但是, 这个调用可能会在```iterator```的第一次迭代时执行, ```server```不能假设```start_response()```一定在```iterator```迭代之前执行)

最后, ```server```或```gateway``` ```一定不能```直接使用```application```返回的iterable的任何属性(attributes), 除非它是```server```或```gateway```的特定类型(type)的实例, 例如``` wsgi.file_wrapper```返回的```file wrapper```. In the general case, only attributes specified here, or accessed via e.g. the PEP 234 iteration APIs are acceptable.

#### ```environ```变量
```environ```字典要求包含[Common Gateway Interface规范](https://tools.ietf.org/html/draft-coar-cgi-v11-03)定义的CGI环境变量. 下面的变量必须要有, 除非他们的值是空字符串, 这种情况下可以忽略该变量.

|变量|解释|
|---|----|
|REQUEST_METHOD|HTTP的请求方法, 例如'GET', 'POST'这些. 这个值永远不会为空, 因此该变量一定要有|
|SCRIPT_NAME|```applocation对象```请求的url的路径的初始部分. 这个如果```application```响应```server```的root, 可能为空|
|PATH_INFO|请求的url的路径的剩余部分. 可能为空|
|QUERY_STRING|请求url```?```后面的部分. 可能为空|
|CONTENT_TYPE|HTTP请求```Content-Type```字段的内容. 可能为空|
|CONTENT_LENGTH|HTTP请求```CONTENT_LENGTH```字段的内容. 可能为空|

略

#### Input and Error Streams
略

#### ```start_response()``` Callable
传给```application对象```的第二个参数是一个```callable对象```: ```start_response(status, response_headers, exc_info=None)```(像所有的WSGI参数一样, 应该通过位置传递而不应该通过keyword传递). ```start_response对象```用于开始HTTP response, 而且必须返回```write(body_data)```callable对象.

```status```参数是HTTP的```status```string, 例如```200 OK```或```404 Not Found```这些. 就是, 由```Status-Code```和```Reason-Phrase```组成的string, 中间由一个空格分开.

### Implementation/Application信息

### 