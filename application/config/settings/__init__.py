import os

from .base import *

if os.environ.get("DJANGO_SETTINGS", "local") == "prod":
    from .prod import *