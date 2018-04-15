# 什么是跨域

- 前后端分离的场合下, 前端调用后端的api, 若是前端与后端不在同一个域内, 就会产生跨域问题

# 为什么会发生AJAX跨域问题
- 浏览器限制
- 跨域, 只要协议, 域名, 端口任意一个不一样, 就会认为的是跨域
- XHR(XMLHttpRequest)请求, 非XHR请求不会报跨域

# 解决思路
- 浏览器
    - 在浏览器端修改
    - 不推荐使用, 因为要在客户端修改, 不现实
- XHR 
    - JSONP, 弊端很多, 现在用得很少
- 跨域
    - 被调用方修改(支持跨域). 在服务端修改代码
    - 调用方修改(隐藏跨域). 服务端在外部, 只能修改本地的代码.

# 全面解决跨域问题
## 浏览器禁止检查
- ```chrome --disbale-web-security --user-data-dir=g:\temp3```

## JSONP解决跨域
- JSONP: JSON for pending
- 使用jsonp解决跨域, 后台也要做相应的改动
- JSONP实现原理
    - 
- JSONP的弊端
    - 服务器需要改代码
    - 只支持GET
    - 发送的不是XHR请求, 这也是它能跨域的原因

# 跨域解决方案
- 被调用方解决

- 调用方解决
    - 服务器端实现
        - 浏览器检测到跨域后, 会在Request头里加上Origin字段, 如果Resonse头里没有对应的Access-Control-Allow-Origin字段, 就会判断跨域失败
        - 方法: 在response头里加上字段: ```Access-Control-Allow-Origin```和```Access-Control-Allow-Method```, 其中```Access-Control-Allow-Origin```和请求头的```Origin```一样, ```Access-Control-Allow-Method```设为```*```

    - NGINX配置
    - APACHE配置