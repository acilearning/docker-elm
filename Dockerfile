FROM ghcr.io/acilearning/docker-haskell:9.0.2
ARG ELM_VERSION=c9aefb6230f5e0bda03205ab0499f6e4af924495
WORKDIR /tmp
RUN curl --location --output compiler.tar.gz "https://github.com/elm/compiler/archive/$ELM_VERSION.tar.gz"
RUN tar --extract --file compiler.tar.gz
WORKDIR "/tmp/compiler-$ELM_VERSION"
RUN \
  set -o errexit -o xtrace; \
  cabal update; \
  cabal build --only-download; \
  cabal build --only-dependencies; \
  cabal build elm
RUN cp --verbose "$( cabal list-bin elm )" ~/.local/bin
RUN elm --version

FROM node:18.9.0
RUN \
  set -o errexit -o xtrace; \
  apt-get update; \
  env DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes \
    ca-certificates \
    libnuma1
USER node
COPY --from=0 /home/haskell/.local/bin/elm /usr/local/bin
RUN elm --version
