#!/usr/bin/env bash

VERSION=$(date +%s)

docker build . -t godev:${VERSION} && \
	docker run --rm -i -t godev:${VERSION}
