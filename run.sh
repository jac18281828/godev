#!/usr/bin/env bash

VERSION=$(date +%m%d%y)

docker build . -t godev:${VERSION} && \
	docker run --rm -i -t godev:${VERSION}
