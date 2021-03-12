#!/usr/bin/env bash

set -ex

if [ -z "$INSTALLROOT_TOOLS" ]; then
    export INSTALLROOT_TOOLS="$(pwd)/install/build-tools"
fi


export PATH="$(brew --prefix bison)/bin:${PATH}"


echo "Compiling LLVM..."

pushd sources/clang/llvm
mkdir -p build
cd build
cmake -G Ninja -DLLVM_TARGETS_TO_BUILD=X86 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${INSTALLROOT_TOOLS}" ../
Ninja
Ninja install
popd

echo "LLVM Compile done"
