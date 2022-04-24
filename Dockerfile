# Use Rust to build
FROM rustlang/rust:nightly as builder

# Add source code to the build stage.
ADD . /biscuit
WORKDIR /biscuit

RUN cargo install cargo-fuzz

# BUILD INSTRUCTIONS
WORKDIR /biscuit/fuzz
RUN cargo +nightly fuzz build fuzz_decryption
# Output binary is placed in /biscuit/fuzz/target/x86_64-unknown-linux-gnu/release/decode

# Package Stage -- we package for a plain Ubuntu machine
FROM --platform=linux/amd64 ubuntu:20.04

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y gcc clang cmake

## Copy the binary from the build stage to an Ubuntu docker image
COPY --from=builder /biscuit/fuzz/target/x86_64-unknown-linux-gnu/release/fuzz_decryption /