FROM public.ecr.aws/acilearning/haskell:9.0.2-9b15804b439f995c128b659e9d5b11e98f6c6b97

# This commit is compatible with Elm version 0.19.1.
# https://github.com/elm/compiler/compare/0.19.1...master
ARG ELM_VERSION=047d5026fe6547c842db65f7196fed3f0b4743ee

# This comes from a fork of elm-format that adds support for Linux on ARM64.
# https://github.com/avh4/elm-format/pull/777
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

FROM mcr.microsoft.com/devcontainers/javascript-node:18
USER node
COPY --from=0 /home/haskell/.local/bin/elm /usr/local/bin
COPY --from=0 /home/haskell/.local/bin/elm-format /usr/local/bin
RUN \
  set -o errexit -o xtrace; \
  mkdir --parents --verbose ~/.cache ~/.elm ~/.npm; \
  elm --version; \
  elm-format --help
