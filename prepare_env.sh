#!/usr/bin/env bash

set -ex

brew --version

brew install  \
    cmake     \
    wget      \
    ninja     \
    freetype  \
    bison     \
    mingw-w64

which cmake
cmake --version

export PATH="$(brew --prefix bison)/bin:$PATH"
bison --version
