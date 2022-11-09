ARG VERSION=stable-slim
FROM debian:${VERSION} 

RUN export DEBIAN_FRONTEND=noninteractive && \
        apt update && \
        apt install -y -q --no-install-recommends \
        sudo ca-certificates curl git \
        build-essential ca-certificates golang-go
RUN apt clean
RUN rm -rf /var/lib/apt/lists/*

RUN useradd --create-home -s /bin/bash jac
RUN usermod -a -G sudo jac
RUN echo '%jac ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV GOPATH=/go
ENV GOBIN=/go/bin
ENV GO111MODULE=on
RUN go get -v golang.org/x/tools/gopls@v0.7.3
RUN go get -v github.com/go-delve/delve/cmd/dlv
RUN go get -v github.com/go-delve/delve/cmd/dlv@v1.7.2
RUN go get -v github.com/cweill/gotests/gotests

CMD echo "Go Dev"
