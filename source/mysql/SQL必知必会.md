# SQL必知必会

- 索引
    - SQL索引用B+树实现, 树的一个节点就是一次IO 
    - 索引存储在硬盘, 索引本身也比较大, 不能一次性读到内存中, 因此索引读取过程中会产生磁盘IO损耗
    - 索引优化是查询性能优化最有效的手段
    - 聚集索引: 物理上的连续存在
        - 例子: 字典的拼音索引

    - 非聚集索引: 逻辑上的连续存在, 物理存储上不连续
        - 例子: 字典的偏旁部首索引

    - 索引提高了SELETE查询和WHERE子句速度, 却降低了包含UPDATE或INSERT语句的数据输入过程的速度.
    - 索引的创建和产生不会对表中的数据产生影响
    - 索引是另外存储在硬盘上, 所以对是索引的列查询速度很快; 对非索引的列用WHERE子句查询, 会进行全表查询, 速度很慢. 用explain语句根据type的值可以看到.
    - 常见问题:
        - 无索引
        - 隐式转换  
    - 建索引的几大原则:
        - 最左前缀原则
        - =和in可以乱序
        - 尽量选择区分度高的列作为索引, 即选择度
        - 索引列不能参与计算, 要保持列的干净
        - 尽量的扩展索引, 不要新建索引

    - 覆盖索引
        - 如果索引本身包含了要查询的字段的值, 则称为覆盖索引
        - MySQL只使用B-Tree作为覆盖索引 

- 插入操作和一般的更新操作很少出现性能问题, 问题最多的是一些复杂的查询操作.

- 访问磁盘的成本大概是访问内存的十万倍

- 语法:
    - 加```\G```可以把结果旋转90度
    - 查看索引, ```show index from u_user \G;```

## SQL四种连接
- 内连接, INNER JOIN
    - ```SELECT * FROM (a INNER JOIN b ON a.id=b.parent_id);```
    - 注意到这样与```SELECT * FROM (a, b) WHERE a.id=b.parent_id```的结果是一样的.
        - JOIN称为显性连接, WHERE称为硬性连接
        - 用JOIN代码更容易理解
- 左外连接, LEFT (OUTER) JOIN
    - ```SELECT * FROM (a LEFT JOIN b on a.id=b.parent_id);```
    - 左表中的数据会全部显示, 右表中只有符合ON后表达式的数据才显示
- 右外连接, RIGHT (OUTER) JOIN
    - 与左连接相反
- 全连接, FULL JOIN
    - MySQL不支持FULL JOIN语法, 但可以用UNION实现:

        - 
        ```sql
            SELECT * FROM (a LEFT JOIN b ON a.id=b.parent_id)
            UNION
            SELECT * FROM (a RIGHT JOIN b ON a.id=b.parent_id) 
        ```
    - 作用等于左连接+右连接
- 交叉连接, CROSS JOIN
    - ```SELECT * FROM (a CROSS JOIN b);```
    - 返回两个表的笛卡儿积, 即第一个表的每一行与第二个表每一行的排列组合

- 自连接
    - 是一种技巧, 不是一种内置的语法

## delete, drop, truncate区别
- drop会删除表结构; delete, truncate只删除数据
- drop是DDL语言, 操作立即生效, 不可回滚; delete, truncate是DML语言, 需要事务管理, commit之后才生效.
- 删除全部记录, 用truncate; 删除部分记录用delete

## 视图
- 视图是什么
    - 视图是一个虚拟的表, 是一个逻辑表, 本身不包含数据, 数据存在与基表中.

- 语法
    - ```sql
        CREATE VIEW [视图名字] [视图的列名]
        as
        SELECT [基表的列名] FROM [基表]
        WITH CHECK OPTION
        ```
    - 加了WITH CHECK OPTION后, 对视图的修改必须符合WHERE子句, 即限制了视图的权限.
- 因为视图不存在数据, 对视图的修改最终都会体现在基表上; 有些情况下不能修改视图
- drop只会删除视图, 不会删除基表

## DML, DDL, DCL
- DML, Data Manipulate Language
    - 类似于增删改查一类的语句
- DDL, Data Define Language
    - 建表, 删除表一类的语句
- DCL, Data Control Language
    - 只有管理员才有权限的语句
    - 增加用户, 设置权限等

## 存储过程
- 为什么用存储过程
    - 将一些常用的操作, 封存到一个存储过程中, 简化了SQL调用
    - 批量处理, 称为跑批
    - 统一接口, 确保数据安全
    - 相对于oracle, mysql的存储过程较弱, 用得比较少

## Schema
- Mysql中, Schema和Database是同义词
    