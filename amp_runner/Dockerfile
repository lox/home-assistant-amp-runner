FROM debian:12-slim

ARG BUILD_ARCH
ARG BUILD_VERSION

LABEL \
  io.hass.type="app" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.version="${BUILD_VERSION}" \
  org.opencontainers.image.title="Home Assistant App: Amp Runner" \
  org.opencontainers.image.description="Run Amp against the live Home Assistant configuration" \
  org.opencontainers.image.source="https://github.com/lox/home-assistant-amp-runner" \
  org.opencontainers.image.licenses="MIT"

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    chromium-headless-shell \
    coreutils \
    curl \
    findutils \
    fonts-dejavu-core \
    git \
    jq \
    openssh-client \
    python3 \
    ripgrep \
  && rm -rf /var/lib/apt/lists/*

COPY rootfs /
COPY run.sh /usr/local/bin/amp-runner
COPY runner-AGENTS.md /etc/amp-runner/AGENTS.md
RUN mv /usr/bin/bash /usr/bin/bash.real
COPY bash-wrapper /usr/bin/bash

RUN chmod 0755 \
  /usr/bin/bash \
  /usr/local/bin/amp-runner \
  /usr/local/bin/ha-check \
  /usr/local/bin/ha-info \
  /usr/local/bin/ha-restart \
  /usr/local/bin/ha-screenshot

WORKDIR /config

ENTRYPOINT ["/usr/bin/bash.real", "/usr/local/bin/amp-runner"]
