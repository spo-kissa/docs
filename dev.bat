@echo OFF

rem docker build -t mkdocs:dev .
rem docker run --rm -it -p 8000:8000 -v ./spo-docs:/docs mkdocs:dev

rem docker run --rm -it -p 8000:8000 -e WATCHDOG_FORCE_POLLING=true -v ./spo-docs:/docs squidfunk/mkdocs-material serve

docker run --rm -it -p 8000:8000 -e WATCHDOG_FORCE_POLLING=true -v ./spo-docs:/docs squidfunk/mkdocs-material:latest
