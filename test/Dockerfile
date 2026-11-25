FROM oven/bun:1.3.11 AS bun
FROM node:24-bookworm-slim

RUN apt-get update \
    && apt-get install --yes --no-install-recommends bash shellcheck chromium fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*
COPY --from=bun /usr/local/bin/bun /usr/local/bin/bun
ENV PUPPETEER_SKIP_DOWNLOAD=true HOME=/tmp
WORKDIR /workspace
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile
COPY . .
RUN chmod -R a+rX .flox
USER 65534:65534
ENTRYPOINT ["bash", "test/main.sh"]
