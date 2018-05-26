# RabbitMQ

## 在windows下安装RabbitMQ
1. 下载安装对应版本的Erlang, 用管理员权限安装
2. 下载安装RabbitMQ
3. 找到安装目录下的```\rabbitmq_server-3.7.5\sbin```文件夹, 把该路径添加到环境变量
4. 在命令行输入```rabbitmqctl status```, 如果报```unable to connect to node rabbit@xxx: nodedown```, 则是因为存在两份不同cookie导致的. 搜索```.erlang.cookie```, 找到两份文件, 用其中一份替换掉另外一份就可以了.
5. 安装web管理插件```rabbitmq-plugins enable rabbitmq_management```, 成功后访问```http://127.0.0.1:15672/```, 初始默认的账号密码都是guest. 这个只能本地访问, 不能远程访问.