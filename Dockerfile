FROM squidfunk/mkdocs-material:latest
RUN pip install --no-cache-dir mkdocs-git-revision-date-localized-plugin
