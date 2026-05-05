# SPDX-FileCopyrightText: © 2026 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG \
    BASE_IMAGE

FROM docker.io/xyksolutions1/container-nginx:main

LABEL \
        org.opencontainers.image.title="Matrix Authentication Service" \
        org.opencontainers.image.description="Helper for authentication for Matrix HomeserversProxy to your Matrix Homeserver" \
        org.opencontainers.image.url="https://hub.docker.com/r/xyksolutions1/matrix-authentication-service" \
        org.opencontainers.image.documentation="https://github.com/xyksolutions1/container-matrix-authentication-service/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/xyksolutions1/container-matrix-authentication-service.git" \
        org.opencontainers.image.authors="xyksolutions1" \
        org.opencontainers.image.vendor="xyksolutions1" \
        org.opencontainers.image.licenses="MIT"

ARG \
    MAS_VERSION="v1.15.0" \
    MAS_REPO_URL="https://github.com/element-hq/matrix-authentication-service"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    IMAGE_NAME="xyksolutions1/matrix-authentication-service" \
    IMAGE_REPO_URL="https://github.com/xyksolutions1/container-matrix-authentication-service/"

RUN echo "" && \
    BUILD_ENV=" \
                NGINX_SITE_ENABLED=matrix-authentication-service \
                NGINX_ENABLE_CREATE_SAMPLE_HTML=FALSE \
              " \
              && \
    MAS_BUILD_DEPS_ALPINE=" \
                                #$nodejs \
                                #$npm \
                                #$rust \
                            " \
                            && \
    \
    MAS_BUILD_DEPS_DEBIAN=" \
                                git \
                            " \
                            && \
    \
    source /container/base/functions/container/build && \
    create_user mas 1000 mas 1000 /dev/null && \
    container_build_log image && \
    package update && \
    package upgrade && \
    package install \
                    MAS_BUILD_DEPS \
                    MAS_RUN_DEPS \
                    && \
    package build go && \
    package build yq && \
    \
    mkdir /usr/src/mas && \
    curl -ssL "${MAS_REPO_URL}/releases/download/${MAS_VERSION}/mas-cli-$(container_info arch)-linux.tar.gz" | tar xvfz - --strip 1 -C /usr/src/mas/ && \
    mv /usr/src/mas/mas-cli /usr/local/bin/mas-cli && \
    chmod +x /usr/local/bin/mas-cli && \
    mkdir -p /container/data/mas && \
    mv /usr/src/mas/* /container/data/mas/ && \
    chown -R mas:mas /container/data/mas && \
    container_build_log add "Matrix Authentication Service" "${MAS_VERSION}" "${MAS_REPO_URL}" && \
    package cleanup

COPY rootfs /

