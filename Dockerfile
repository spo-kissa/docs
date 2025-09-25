FROM python:3.12-slim AS base

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /docs

COPY spo-docs/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./spodocs .

EXPOSE 8000

RUN useradd -ms /bin/bash mkdocs && chown -R mkdocs:mkdocs /docs
USER mkdocs

CMD ["mkdocs", "serve", "-a", "0.0.0.0:8000"]
