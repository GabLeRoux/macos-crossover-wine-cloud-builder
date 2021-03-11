#!/usr/bin/env bash

set -ex

export PATH="$(brew --prefix bison)/bin:${PATH}"
export PATH="$(pwd)/sources/clang/llvm/build/bin:${PATH}"

echo "Compiling Clang..."
pushd sources/clang/clang
mkdir -p build
cd build
cmake -G Ninja ../
Ninja
popd

echo "CLang compile done"
