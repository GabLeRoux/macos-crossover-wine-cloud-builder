#!/usr/bin/env bash

set -ex

which cmake
cmake --version

# Note: llvm and clang are not provided anymore in versions higher than 20.0.0
CROSS_OVER_VERSION=20.0.0
CROSS_OVER_SOURCE_URL=https://media.codeweavers.com/pub/crossover/source/crossover-sources-${CROSS_OVER_VERSION}.tar.gz

brew install \
    freetype \
    bison

export PATH="$(brew --prefix bison)/:$PATH"
bison --version
