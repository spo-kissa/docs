#!/bin/bash

# docker build -t mkdocs:dev ./
# docker run --rm -it -p 8000:8000 -v ./spo-docs:/docs mkdocs:dev
# docker run --rm -it -p 8000:8000 -v ./spo-docs:/docs squidfunk/mkdocs-material

docker run --rm -it -p 8000:8000 \
  -e WATCHDOG_FORCE_POLLING=true \
  -v "$(pwd)/spo-docs":/docs \
  squidfunk/mkdocs-material:latest \
  serve -a 0.0.0.0:8000 -v \
  --watch docs --watch overrides --watch docs/css --watch docs/assets
