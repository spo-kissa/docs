@echo OFF

docker build -t mkdocs:dev .
docker run --rm -it -p 8000:8000 -v ./spo-docs:/docs mkdocs:dev
