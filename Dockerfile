# Stage 1: Build yamlfmt
FROM golang:1 AS yaml-builder
# defined from build kit
# DOCKER_BUILDKIT=1 docker build . -t ...
ARG TARGETARCH

# Install yamlfmt
WORKDIR /yamlfmt
RUN go install github.com/google/yamlfmt/cmd/yamlfmt@v0.16.0 && \
    strip $(which yamlfmt) && \
    yamlfmt --version

FROM debian:stable-slim AS go-builder
# defined from build kit
# DOCKER_BUILDKIT=1 docker build . -t ...
ARG TARGETARCH

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt install -y -q --no-install-recommends \
    git curl gnupg2 build-essential coreutils \
    openssl libssl-dev pkg-config \
    ca-certificates apt-transport-https \
    python3 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*


ENV GOROOT=/go
ENV GOBIN=${GOROOT}/bin

## Go Lang
ARG GO_VERSION=1.24.1
ADD https://go.dev/dl/go${GO_VERSION}.linux-$TARGETARCH.tar.gz /go${GO_VERSION}.linux-$TARGETARCH.tar.gz
RUN tar -C / -xzf /go${GO_VERSION}.linux-$TARGETARCH.tar.gz

RUN ${GOBIN}/go version

FROM debian:stable-slim
RUN export DEBIAN_FRONTEND=noninteractive && \
        apt update && \
        apt install -y -q --no-install-recommends \
    sudo ca-certificates curl git \
    python3 ripgrep \
    ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --create-home -s /bin/bash godev
RUN usermod -a -G sudo godev
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV USER=godev
ENV GOROOT=/go
ENV GOBIN=${GOROOT}/bin
ENV GO111MODULE=on
ENV PATH=${PATH}:${GOBIN}

# GO LANG
COPY --from=go-builder ${GOROOT} ${GOROOT}
COPY --chown=${USER}:${USER} --from=yaml-builder ${GOBIN}/yamlfmt ${GOBIN}/yamlfmt

ENV PATH=${PATH}:${GOBIN}
ENV GOPATH=${GOBIN}

RUN go install golang.org/x/tools/gopls@latest

RUN chown -R ${USER}:${USER} ${GOROOT}

LABEL \
    org.label-schema.name="godev" \
    org.label-schema.description="Go Development Container" \
    org.label-schema.url="https://github.com/jac18281828/godev" \
    org.label-schema.vcs-url="git@github.com:jac18281828/godev.git" \
    org.label-schema.vendor="John Cairns" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0" \
    org.opencontainers.image.description="go development container"
