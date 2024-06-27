#!/usr/bin/env sh

set -eux

version="$1"

os="$(uname -s)"
if [ "${os}" = "Linux" ]; then
    build_binary() {
        docker_platform="$1"

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

    build_binary linux/amd64
    pkgx +xz tar cJf "pkgx-$version+linux+x86-64.tar.xz" pkgx
    rm -f pkgx

    build_binary linux/arm64
    pkgx +xz tar cJf "pkgx-$version+linux+aarch64.tar.xz" pkgx
    rm -f pkgx
elif [ "${os}" = "Darwin" ]; then
    build_binary() {
        macos_arch="$1"

        rm -rf "${PKGX_DIR:-"${HOME}/.pkgx"}" "${HOME}/.cache/pkgx" "${HOME}/.local/share/pkgx"
        env which pkgx | sort -u | xargs -r -t rm -f

        arch "-${macos_arch}" zsh -s -- <<'EOF' "$version"
set -exo pipefail

version="$1"

curl -fsS https://pkgx.sh | sh

source <(pkgx --shellcode)

dev

deno task compile

dev off
EOF

        rm -rf "${PKGX_DIR:-"${HOME}/.pkgx"}" "${HOME}/.cache/pkgx" "${HOME}/.local/share/pkgx"
        env which pkgx | sort -u | xargs -r -t rm -f
        curl -fsS https://pkgx.sh | sh
    }

    build_binary x86_64
    pkgx +xz tar cJf "pkgx-$version+darwin+x86-64.tar.xz" pkgx
    rm -f pkgx
    build_binary arm64
    pkgx +xz tar cJf "pkgx-$version+darwin+aarch64.tar.xz" pkgx
    rm -f pkgx
else
    echo "Unsupported OS: ${os}"
    exit 1
fi
