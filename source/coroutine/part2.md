# Coroutine, Pipeline and Dataflow

## coroutine实现pipeline
- pipeline分为source, filter, sink.
    - source是源头, 用于生产数据, 通常这个不是coroutine
    - filter. 是管道的中间节点, 这是coroutine
    - sink. 是管道的尾端, 用于最终接受数据.