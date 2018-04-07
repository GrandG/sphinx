## git配置

### git配置位置

- 在win下, 在```C:/用户/```下存在```.gitconfig```文件, 保存全局的设置
- 在git仓库下存在```.gitconfig```文件, 保存当前git仓库的设置
### 初次配置用户

- ```git config --global user.name "xxx"```
- ```git config --global user.email "xxx"```

### git在win下中文乱码问题

```
$ git config --global core.quotepath false  		
# 显示 status 编码

$ git config --global gui.encoding utf-8			
# 图形界面编码

$ git config --global i18n.commit.encoding utf-8	
# 提交信息编码

$ git config --global i18n.logoutputencoding utf-8	
# 输出 log 编码
```