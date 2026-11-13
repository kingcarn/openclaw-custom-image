# syntax=docker/dockerfile:1
ARG OPENCLAW_VERSION
FROM ghcr.io/openclaw/openclaw:${OPENCLAW_VERSION}

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    openssh-client gh ca-certificates ripgrep jq rsync fd-find tree file less \
    unzip zip shellcheck shfmt ffmpeg imagemagick libimage-exiftool-perl mediainfo \
 && rm -rf /var/lib/apt/lists/*

# Preserve the existing custom-image UID/GID policy.
RUN set -eux; \
    if ! getent group 1600 >/dev/null; then groupadd -g 1600 storagerw; fi; \
    mkdir -p /home/node; \
    chown 1000:1600 /home/node; \
    chmod 775 /home/node; \
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then ln -s /usr/bin/fdfind /usr/local/bin/fd; fi

ENV HOME=/home/node
USER 1000:1600
