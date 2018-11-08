## Centos7安装Nginx
1. 用root用户登陆
2. ```yum install epel-release```
3. ```yum install nginx```
4. ```systemctl start nginx```
5. 防火墙开放http和https
```
firewall-cmd --permanent --zone=public --add-server=http
firewall-cmd --permanent --zone=public --add-server=https
firewall-cmd --reload
```
6. 这时候访问```http://nginx所在主机的ip```, 就可以看到nginx的欢迎页面
7. 一般会设置系统重启后, 主动启动nginx: ```systemctl enable nginx```

-----

## Server Root and Configuration
### 1. Default Server Root
default server root是```/usr/share/nginx/html```, 所有在这个文件夹里面的文件都会被served on web server.

### 2. Server Block Configuration
其他的server block(Apache中叫做Virtual Host), 可以在```/etc/nginx/conf.d```文件夹中新建```.conf```文件, 该文件会在Nginx启动后自动loaded

### 3. Nginx Global Configuration
nginx的主要配置在```/etc/nginx/nginx.conf```文件中, 可以在该文件中设置user, worker process数

## Beginner's guide

[原文在这里](http://nginx.org/en/docs/beginners_guide.html#conf_structure)

----

**Nginx有一个master process和多个worker processes. Master process的主要作用是read和evaluate configuration, 和maintain worker processes; worker process才是真正地processing request**

----

### starting, stopping, reloading configuration
- ```nginx```, ```system start nginx```, 开启nginx
- 一旦开启nginx, 可以通过-s参数控制行为, 语法是: ```nginx -s signal```, 其中signal可以是:
    * ```stop```, fast shutdown
    * ```quit```, graceful shudown, 等到处理完最后一个request, 才停止
    * ```reload```, reloading the configuration, 配置完conf文件后不会自动加载, 要运行reload, 并且master process通过语法审查,才会加载
    * ```reopen```, reopen the log files
    * **这些命令都应该由启动nginx的user来执行**

### configuration file's structure

- **nginx**由**modules**组成, **module**由configuration file中的directives控制.
- **directives**可以分为: **simple directives**和**block directives**:
    * simple directives: 由name, parameter组成. name, parameter用空格(一个或多个)隔开; 最后以```;```结束
    * block directives: 结构与simple directives基本一样, 只是以```{}```包起来的指令结束, 最后不用```;```
        + 如果在```{}```中包含别的directives, 那就称为**context**, 例如: events, http, server, location 
- 在configuration file中, 在**context**之外的**directives**, 都属于**main** context
- ```event```和```http```directives在```main```context里面, ```server```在```http```里, ```location```在```server```里

### serving static content

- 在下面说了
- nginx默认的日志在```/var/log/nginx/```中

### setting a simple proxy server

### setting up FastCGI Proxying


## Nginx serve静态文件全过程记录, 附坑!!!!!!!!!
1. nginx的main configuration在```etc/nginx/nginx.conf```(这个的实际具体位置好像与安装方式相关)
2. 对该main configuration做好备份, 命名为.bak文件
3. 一般来说, 不在```nginx.conf```文件处直接修改, 而是把从```server```开始的部分, 在```/etc/nginx/conf.d```文件夹里面新建一个以```.conf```为后缀的文件, 把配置写在该文件里面, 写完后, 还有运行```nginx -s reload```(这是指nginx已经启动的情况下, 若还没有启动则直接启动即可), 才会把新加的configuration添加到nginx的配置里面.
4. 配置的内容如下:
```
server {
    listen       80;        # 监听的端口
    server_name    localhost    # 这里写192.168.1.105(即本机ip)也可以, 这项一定要写, 不写就会转到default_server去, 这一项就是requet的HOST
    location      /gao {
        root /home/gao/data;    # 要serve 的静态文件的文件夹, match request的时候是root+url(即/home/gao/data/gao)
    }
}
```
5. 坑的地方是, 如果启动方式是```sudo service nginx start```, 这时候访问静态文件会显示"403 permission denied", 前提是文件权限已经设置得和默认一样; 如果启动方式是```sudo nginx```, 则可以正常访问. 这是因为SELinux引起的, 具体原因还不太清楚.
6. 解决方法是:
    1. ```chcon -Rt httpd_sys_content_t /path/to/www```
    2. 关闭SELinux, ```setenforce Permissive```
7. ```server_name```如果填```localhost```会转到默认的服务器, 填IP就不会
8. ```/etc/nginx/nginx.conf```里面写的```server```似乎是万恶之源, 删了它就可以按照beginner's guide来进行了.
9. 用阿里云服务器, 需要在安全组开通端口才可以访问.

## Nginx serve静态文件全过程记录, 附坑!!!!!!!!!