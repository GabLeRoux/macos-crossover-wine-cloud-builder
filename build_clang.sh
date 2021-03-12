#!/usr/bin/env bash

set -ex

if [ -z "$INSTALLROOT_TOOLS" ]; then
    export INSTALLROOT_TOOLS="$(pwd)/install/build-tools"
fi


export PATH="$(brew --prefix bison)/bin:${PATH}"
export PATH="${INSTALLROOT_TOOLS}/bin:${PATH}"


echo "Compiling Clang..."

pushd sources/clang/clang
mkdir -p build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${INSTALLROOT_TOOLS}" ../
Ninja
Ninja install
popd

echo "Clang compile done"
