FROM ghcr.io/acilearning/docker-haskell:9.0.2
ARG ELM_VERSION=c9aefb6230f5e0bda03205ab0499f6e4af924495
ARG ELM_FORMAT_VERSION=535866ba69b97eb1e5755191753baafa3a21ef5d
RUN \
  set -o errexit -o xtrace; \
  sudo apt-get update; \
  sudo apt-get install --assume-yes --no-install-recommends jq; \
  curl --location --output compiler.tar.gz "https://github.com/elm/compiler/archive/$ELM_VERSION.tar.gz"; \
  tar --extract --file compiler.tar.gz; \
  cd "compiler-$ELM_VERSION"; \
  cabal update; \
  cabal build --only-download; \
  cabal build --only-dependencies; \
  cabal build elm; \
  cp --verbose "$( cabal list-bin elm )" ~/.local/bin; \
  elm --version; \
  cd ..; \
  git clone https://github.com/tfausak/elm-format; \
  cd elm-format; \
  git checkout "$ELM_FORMAT_VERSION"; \
  ./build.sh -- build; \
  cp --verbose _build/elm-format ~/.local/bin; \
  elm-format --help

FROM node:18.9.0
RUN \
  set -o errexit -o xtrace; \
  apt-get update; \
  env DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes \
    ca-certificates \
    libnuma1
USER node
COPY --from=0 /home/haskell/.local/bin/elm /usr/local/bin
COPY --from=0 /home/haskell/.local/bin/elm-format /usr/local/bin
RUN \
  set -o errexit -o xtrace; \
  elm --version; \
  elm-format --help
