#!/usr/bin/env bash

set -ex

export PATH="$(brew --prefix bison)/bin:${PATH}"

echo "Compiling LLVM..."
pushd sources/clang/llvm
mkdir -p build
cd build
cmake -G Ninja ../ -DCMAKE_BUILD_TYPE=Release ../
Ninja
popd

echo "LLVM Compile done"
