# Base

FROM python:3.12-slim-bookworm as base

ENV PYTHONBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    pkg-config \
    build-essential \
    default-libmysqlclient-dev \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Builder

FROM base as builder

ENV POETRY_VERSION=1.8.3 \
    POETRY_VIRTUALENVS_IN_PROJECT=false \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_NO_INTERACTION=1

COPY ./application/poetry.lock ./application/pyproject.toml ./
RUN pip install poetry==$POETRY_VERSION \
    && poetry install --no-root

# Runner

FROM base as runner

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY ./application /app

CMD [ "/bin/bash", "-c", "python manage.py migrate && gunicorn config.wsgi:application -w 4 -b 0.0.0.0:8000"]
