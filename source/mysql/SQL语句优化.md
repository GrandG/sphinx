# SQL语句优化

## 使用例子数据库
- 从[这里](https://dev.mysql.com/doc/sakila/en/sakila-installation.html)下载并导入sakila数据库

## MySQL慢查日志开启与存储格式
- 开启慢查询日志
    - 进入mysql命令行
    - 开启慢查询日志. 输入```show variables like 'slow_query_log';```查看是否开启了慢查日志; 如果结果显示为```off```, 则输入```set global slow_query_log=ON;```开启.
    - 查看慢查询时间. 输入```show variables like 'long_query_time';```查看多长时间的查询会被记录. 可通过```set global long_query_time=0```, 把查询时间长于0s的查询记录为慢查询.
    - 查看慢查询日志的位置. 输入```show variables like '%slow%';```查看慢查日志的存放位置. 可通过```set global slow_query_log_file=D:/xxx.log```自定义存放的位置.
- 存储格式
    - ![](D:/Workshop/sphinx/source/_static/mysql/4.jpg)
    - 第一行是开始执行时间(UTC时间)
    - 第二行是主机信息
    - 第三行是查询时间等信息
    - 第四行是时间戳格式的查询时间
    - 第五行是具体执行的查询命令
## 慢查日志分析工具
- mysqldumpslow
    - 这款工具是mysql自带的(注意window下打开比较麻烦, 建议直接在linux上用)
    - 输入```mysqldumpslow -t 3 /path/to/slow/log```会显示慢查日志中前三条的耗时最长的记录
- pt-query-digest
    - 第三方应用
    - 安装: ```wget https://www.percona.com/downloads/percona-toolkit/2.2.16/RPM/percona-toolkit-2.2.16-1.noarch.rpm && yum localinstall -y percona-toolkit-2.2.16-1.noarch.rpm```
    - 使用 ```pt-query-digest + slowlog```
## 通过explain查询SQL的执行计划
- ![](D:/Workshop/sphinx/source/_static/mysql/5.jpg)
- 解析一下每一列的含义:
    - table: 显示这一行数据是关于那张表的
    - type: 这是重要的列, 显示了连接使用了哪种类型. 连接类型从好到坏依此是: const, eq_reg, ref, range, index, ALL.
    - possible_key: 显示可能应用在这张表上的索引. 如果为空, 则可能没有索引.
    - key: 实际使用的索引.
    - key_len: 使用索引的长度. 在损失精确性的基础上, 长度越短越好.
    - ref: 显示索引的哪一列被使用了, 如果可能的话是一个常数.
    - rows: Mysql认为必须检查的, 用来返回请求数据的行数.
    - extra: 
        - Using filesort: 看到这个, 则说明查询需要优化
        - Using temporary: 看到这个, 说明查询需要优化