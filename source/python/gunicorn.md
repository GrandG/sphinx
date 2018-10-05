# gunicorn

[文档](http://docs.gunicorn.org/en/stable/run.html)

## 安装

```python
pip install gunicorn
```

## 运行Gunicorn

运行基本命令:

```python
gunicorn [OPTIONS] APP_MODULE
```

```APP_MODULE```: 格式是: ```$(MODULE_NAME):$(VARIABLE_NAME)```. 例子: ```gunicorn example:app```. 
其中, ```MODULE_NAME```可以用```.```分割, ```VARIABLE_NAME```是在该模块中的```WSGI callable```.

例子:

example.py
```python
def app(environ, start_response):
    """Simplest possible application object"""
    data = b'Hello, World!\n'
    status = '200 OK'
    response_headers = [
        ('Content-type', 'text/plain'),
        ('Content-Length', str(len(data)))
    ]
    start_response(status, response_headers)
    return iter([data])
```

```gunicorn --workers=2 --bind=0.0.0.0:8000 example:app```

访问```ip:8000```即可看到```hello world```

### Django

```gunicorn myproject.wsgi```

```gunicorn --env DJANGO_SETTINGS_MODULE=myproject.settings myproject.wsgi```

## 配置参数

有三种配置gunicorn运行参数的方法:
1. gunicorn从框架指定的配置文件中读取
2. gunicorn从```--config```参数指定的文件中读取配置, 2方法会覆盖1方法的参数
3. gunicorn从命令行参数中读取配置参数. 3方法会覆盖2方法的参数.

### 从框架配置文件读取

### 从```--config```中指定的配置文件读取

配置文件也是py文件.

例子:
```python
import multiprocessing

bind = "0.0.0.0:8000"
workers = multiprocessing.cpu_count() * 2 + 1
```

运行时:
```gunicorn --config=config.py example:app```

### 从命令行读取

运行```gunicorn -h```查看所有参数

```gunicorn --workers=2 --bind=0.0.0.0:8000 example:app```

## ```Setting```详解

- ```--daemon```: 似乎不能直接从命令行设, 设在配置文件中才可以. 默认是```False```

[守护进程](https://zh.wikipedia.org/wiki/%E5%AE%88%E6%8A%A4%E8%BF%9B%E7%A8%8B)

守护进程程序通常通过如下方法使自己成为守护进程：对一个子进程執行fork，然后使其父进程立即终止，使得这个子进程能在init下运行。这种方法通常被称为“脱壳”。

### 前台进程 vs 后台进程 vs 守护进程

前台进程: 直接运行```gunicorn -w=1 -b=0.0.0.0:8000 example:app```就是前台运行程序. 特点是会占用shell, 当前的shell不能进行任何操作.

后台程序: 叫做```job```. 在后面加```&```. ```gunicorn -w=1 -b=0.0.0.0:8000 example:app```. 这时候程序会在后台运行, 不会占用shell. 但会发现进程的父进程是bash. 且用户退出登录后, 进程会变成僵尸进程. 需要手动kill

守护进程. 也是在后台运行. 但会发现父进程的pid=1. 且退出用户后, 进程继续运行, 知道系统重启或关闭.

守护进程与后台程序的主要区别是: 守护进程完全脱离了终端的控制(父进程是pid=1), 而后台进程仍依赖于终端(父进程是终端). 所以守护进程退出终端后仍在运行; 后台程序退出终端就停止运行.

### ```nohup``` vs ```&```

- 使用&后台运行程序：

结果会输出到终端

使用```Ctrl + C```发送```SIGINT```信号，程序免疫

关闭session发送```SIGHUP```信号，程序关闭

 

- 使用nohup运行程序：

结果默认会输出到```nohup.out```

使用```Ctrl + C```发送SIGINT信号，程序关闭

关闭session发送```SIGHUP```信号，程序免疫

 

- 平日线上经常使用```nohup和&```配合来启动程序：

同时免疫```SIGINT```和```SIGHUP```信号

### ```nohup```与daemon的区别

[stackover解释](https://stackoverflow.com/questions/958249/whats-the-difference-between-nohup-and-a-daemon)

一句话总结: 这是实现与守护进程同样的效果