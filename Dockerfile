FROM debian:stable-slim as go-builder
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

## Go Lang
ARG GO_VERSION=1.22.2
ADD https://go.dev/dl/go${GO_VERSION}.linux-$TARGETARCH.tar.gz /go-ethereum/go${GO_VERSION}.linux-$TARGETARCH.tar.gz
# RUN cat /go-ethereum/go${GO_VERSION}.linux-$TARGETARCH.tar.gz | sha256sum -c go.${TARGETARCH}.sha256
RUN tar -C /usr/local -xzf /go-ethereum/go${GO_VERSION}.linux-$TARGETARCH.tar.gz

ENV PATH=$PATH:/usr/local/go/bin
RUN go version

FROM debian:stable-slim

RUN export DEBIAN_FRONTEND=noninteractive && \
        apt update && \
        apt install -y -q --no-install-recommends \
    sudo ca-certificates curl git \
    python3 ripgrep \
    build-essential ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --create-home -s /bin/bash jac
RUN usermod -a -G sudo jac
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV GOROOT=/usr/local/go
ENV GOBIN=${GOROOT}/bin
ENV GO111MODULE=on

# GO LANG
COPY --from=go-builder ${GOROOT} ${GOROOT}

ENV PATH=${PATH}:${GOBIN}
ENV GOPATH=${GOBIN}

RUN go install golang.org/x/tools/gopls@latest

RUN chown -R jac:jac ${GOROOT}

LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="godev" \
    org.label-schema.description="Go Development Container" \
    org.label-schema.url="https://github.com/jac18281828/godev" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="git@github.com:jac18281828/godev.git" \
    org.label-schema.vendor="John Cairns" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0" \
    org.opencontainers.image.description="go development container"
