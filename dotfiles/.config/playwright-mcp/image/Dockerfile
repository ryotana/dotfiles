FROM node:24.22.1-bookworm-slim AS node

FROM mcr.microsoft.com/playwright/mcp:v0.0.83
USER root
COPY --from=node /usr/local/bin/node /usr/local/bin/node
RUN apt-get update \
 && apt-get install -y --no-install-recommends --only-upgrade libbrotli1 \
 && rm -rf /var/lib/apt/lists/*
USER node
