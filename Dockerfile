FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install --yes --no-install-recommends bash shellcheck \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY install.sh test.sh ./
USER 65534:65534
CMD ["bash", "test.sh"]
