FROM rust:1.89-bullseye AS build

WORKDIR /pkgx
COPY Cargo.toml Cargo.lock ./
COPY crates ./crates/

RUN cargo build --release


FROM scratch
COPY --from=build /pkgx/target/release/pkgx /pkgx
