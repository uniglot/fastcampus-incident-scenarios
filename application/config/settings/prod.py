import os

ALLOWED_HOSTS = ["*"]

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.mysql",
        "NAME": "sample",
        "USER": "fastcampus",
        "PASSWORD": "supersecretpassword",
        "HOST": os.environ.get("DATABASE_HOST"),
        "PORT": "3306",
        "CONN_MAX_AGE": 300,
    }
}

CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": [
            "redis://redis-master.default.svc.cluster.local:6379/0",
            "redis://redis-replicas.default.svc.cluster.local:6379/0",
        ],
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
            "PASSWORD": "supersecretpassword",
            "SOCKET_TIMEOUT": 3,
            "SOCKET_CONNECT_TIMEOUT": 3,
        },
    }
}
