import os

ALLOWED_HOSTS = ["*"]

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "sample",
        "USER": "fastcampus",
        "PASSWORD": "supersecretpassword",
        "HOST": os.environ.get("DATABASE_HOST"),
    }
}