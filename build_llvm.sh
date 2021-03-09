#!/usr/bin/env bash

set -ex

export PATH="$(brew --prefix bison)/bin:${PATH}"

echo "Compiling LLVM..."
pushd
cd sources/clang/llvm
mkdir build
cd build
cmake ../
make -j
popd

echo "LLVM Compile done"
