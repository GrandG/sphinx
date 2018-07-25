# Viewset

## Viewset的属性
- ```action```, 返回当前的action('list', 'creat'...)
- ```basename```, 返回URL的名字
- ```detail```, boolean, 当前返回的是detail信息还是list信息
- ```suffix```,
```python
def get_permissions(self):
    """
    Instantiates and returns the list of permissions that this view requires.
    """
    if self.action == 'list':
        permission_classes = [IsAuthenticated]
    else:
        permission_classes = [IsAdmin]
    return [permission() for permission in permission_classes]
```

## 使用额外的action