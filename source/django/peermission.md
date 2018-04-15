# Django权限

- Django通过User, Group, Permission来实现权限
- Group作为用于相同权限的用户的集合, 在Group中的用户自动拥有该Group的权限
- User和Permission的关系是多对多, Group和Permission的关系也是多对多
- Permission分为model级别和object级别
    * model级别权限Django自带, 指对model的所有object拥有相同的权限
        + model创建后自动拥有add_model_name, change_model_name, delete_model_name权限
    * object级别的权限, 指对model的某些object拥有权限, 要靠第三方库如django-guardian实现

# Django rest framework权限

- 权限设置有两种方式:
    * 在setting的REST_FRAMEWORK的DEFAULT_PERMISSION_CLASSES设置permission policy, 如
    ```python
    REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
        )
    }
    ```
    * 在视图中继承```APIView ```类, ```permission_classes```属性设置权限元祖, 如: 
    ```python
        permission_classes = (IsAuthenticated,)
    ``` 
    * 自定义权限, 继承```BasePermission```, 重写```has_permission```方法; object level permission要重写```has_object_permission```方法.
