# 基础知识

## repr() vs str()
- 相同之处: 都把值转为字符串
- str()将返回一个用户易读的值
- repr()将返回一个解释器易读的值
- 对于大多数的变量, 这两者返回的结果是一样的
- 待续

## dict
- dict.update(dict), 类似于把dict apeend到dict里面
- dict.pop(key, default), 把key键值删除, 若不存在返回default
- dict.setdefault(key, default), 获取key的值, 若key不存在, 把default设为key的值, 同时返回.
    - 特别地, dict.setdefault(key, []).append(30), 这是可以的, 神奇~

## xml.sax
- sax是simple api for xml的意思, 用于解析xml
- 继承```xml.sax.handler.ContentHandler```
- ```startElement(self, name, attrs):```, 在遇到开始标签时执行
- ```characters(self, content)```, 在start和end之间执行
- ```endElement(self, name):```, 在遇到结束标签后执行
```python
import xml.sax
from xml.sax.handler import ContentHandler



class WorksHandler(ContentHandler):
    def __init__(self):
        self.current_data = ''
        self.name = ''
        self.author = ''

    
    def startElement(self, name, attrs):
        if name == 'works':
            print('**内容**')
            title = attrs.get('title')
            print("类型: {}".format(title))
            # print('========', name)
        self.current_data = name

    def characters(self, content):
        if self.current_data == 'names':
            self.name = content
        elif self.current_data == 'author':
            self.author = content

    def endElement(self, name):
        if self.current_data == 'names':
            print('名称: {}'.format(self.name))
        elif self.current_data == 'author':
            print('作者: {}'.format(self.author))
        self.current_data = ''


if __name__ == '__main__':
    parser = xml.sax.make_parser()
    parser.setFeature(xml.sax.handler.feature_namespaces,0)
    Handler = WorksHandler()
    parser.setContentHandler(Handler)
    parser.parse(r'D:\Workshop\practice\coroutine\works.xml')
```
用到的xml:
```xml
<collection shelf="New Arrivals">
<works title="电影">
  <names>敦刻尔克</names>
  <author>诺兰</author>
</works>
 <works title="书籍">
  <names>我的职业是小说家</names>
  <author>村上春树</author>
</works>
</collection>
```