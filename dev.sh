#!/bin/bash

# docker build -t mkdocs:dev ./
# docker run --rm -it -p 8000:8000 -v ./spo-docs:/docs mkdocs:dev
docker run --rm -it -p 8000:8000 -v ./spo-docs:/docs squidfunk/mkdocs-material
