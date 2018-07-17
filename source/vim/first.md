# Vim教程

## Vim的三个不同模式
- Command Mode
    - 一打开进入的就是command mode, 这时候不能编辑.
- Insert Mode
    - 按```i```进入insert mode, 这时候可以编辑修改.
- Last Line Mode
    - 只能由command mode进入
    - 在command line下输入```:```进入last line mode.
    - 这里可以退出vim; 保存修改的文件; 甚至可以执行Linux命令

## 修改Vim的配置文件
- 进入vim, 输入```:version```, 查看vim版本信息
- 其中可以发现
```
VIM - Vi IMproved 8.0 (2016 Sep 12, compiled Apr 23 2017 20:01:28)
MS-Windows 32-bit GUI version with OLE support
Included patches: 1-586
Compiled by mool@tororo
   system vimrc file: "$VIM\vimrc"
     user vimrc file: "$HOME\_vimrc"
 2nd user vimrc file: "$HOME\vimfiles\vimrc"
 3rd user vimrc file: "$VIM\_vimrc"
      user exrc file: "$HOME\_exrc"
  2nd user exrc file: "$VIM\_exrc"
  system gvimrc file: "$VIM\gvimrc"
    user gvimrc file: "$HOME\_gvimrc"
2nd user gvimrc file: "$HOME\vimfiles\gvimrc"
3rd user gvimrc file: "$VIM\_gvimrc"
```
的信息. 即vim的配置文件的信息. 
- 个人理解, 按照上面的```user vimrc file```的位置, 新建一个同名文件(如果已经有了就直接在上面修改). 然后修改自己的配置, 尽量不要动系统自己配置.

## visual模式
- visual模式有三种:
    - 默认的visual模式. normal模式下按```v```进入.
    - visual line模式. normal模式下按```V```进入.
    - visual block模式. normal模式下按```Ctrl-v```