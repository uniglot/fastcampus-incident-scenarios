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