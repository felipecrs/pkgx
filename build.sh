#!/usr/bin/env bash

set -euxo pipefail

docker run --privileged --rm tonistiigi/binfmt --install all

docker build . --platform linux/amd64 --output target/docker-build/linux-amd64
mv target/docker-build/linux-amd64/pkgx target/docker-build/pkgx-linux-amd64
rm -rf target/docker-build/linux-amd64

docker build . --platform linux/arm64 --output target/docker-build/linux-arm64
mv target/docker-build/linux-arm64/pkgx target/docker-build/pkgx-linux-arm64
rm -rf target/docker-build/linux-arm64
