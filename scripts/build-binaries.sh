#!/usr/bin/env bash

set -euxo pipefail

function build_binary() {
    local version=$1
    local docker_platform=$2

    docker build . -f - -o . --platform="${docker_platform}" --build-arg VERSION="${version}" <<'EOF'
FROM pkgxdev/pkgx:latest AS build

WORKDIR /wd
COPY . .
RUN dev && deno task compile
# sanity check
ARG VERSION
RUN test "$(./pkgx --version)" = "pkgx $VERSION"

FROM scratch

ARG FILENAME
COPY --from=build /wd/pkgx /
EOF
}

version=$1

build_binary "$version" "linux/amd64"
pkgx +xz tar cJf "pkgx-$version+linux+x86-64.tar.xz" pkgx
rm -f pkgx

build_binary "$version" "linux/arm64"
pkgx +xz tar cJf "pkgx-$version+linux+aarch64.tar.xz" pkgx
rm -f pkgx
