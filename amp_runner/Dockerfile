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
    coreutils \
    curl \
    findutils \
    git \
    jq \
    openssh-client \
    python3 \
    ripgrep \
  && rm -rf /var/lib/apt/lists/*

COPY rootfs /
COPY run.sh /usr/local/bin/amp-runner
COPY runner-AGENTS.md /etc/amp-runner/AGENTS.md

RUN chmod 0755 \
  /usr/local/bin/amp-runner \
  /usr/local/bin/ha-check \
  /usr/local/bin/ha-info \
  /usr/local/bin/ha-restart

WORKDIR /config

ENTRYPOINT ["/usr/local/bin/amp-runner"]
