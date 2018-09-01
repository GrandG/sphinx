# django-redis

## 2. 用户指南
### 2.1 安装
```pip install django-redis```

### 2.2 django配置
```python
CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": "redis://127.0.0.1:6379/1",
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
        }
    }
}
```

## 3. 高级用法
### 3.1 Pickle Version

大多数情况下, django-redis用pickle来序列化对象

默认情况下使用最新的pickle版本。如果要设置具体版本，可以使用以下PICKLE_VERSION选项：
```python
CACHES = {
    "default": {
        # ...
        "OPTIONS": {
            "PICKLE_VERSION": -1  # Use the latest protocol version
        }
    }
}
```

### 3.2 Socket Timeout