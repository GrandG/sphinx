# Introduce to Generator and Coroutine

## Generator
- Genenrator是一个produce**一系列结果**的function, 而不是produce一个值.
- 调用一个generator不会执行, 调用generator相当于实例化化, 再使用next或send才开始执行.
- yied会产出一个值, 但会suspend这个generator
- 当generator return, 会报stopiteration.
- 一个generator必然处于一下四个状态, 可以调用```inspect.getgeneratorstate()```函数得知:
    1. GEN_CREATED. 等待开始执行.
    2. GEN_RUNNING. 解释器正在执行.
    3. GEN_SUSPENDED. 在yield处暂停.
    4. GEN_CLOSE. 执行结束
## yield作为表达式
- 在python2.5后, yied可以作为表达式. 即```a=yield```可以被使用  

## coroutine
- 当yield可以用作表达式后, generator不仅可以用于produce value, 还可以用于consume value sent to it, 这就成为了coroutine.
- coroutine的实例化, 调用方法, 都和generator一样
- 注意, coroutine都需要被primed. 即在其可以send之前, 必须调用send(None)或next().
- 调用c.close()可以关闭coroutine, 这时候可以try catch GeneratorExit显示信息, 不要捕抓StopIteration.