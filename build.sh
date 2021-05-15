#!/usr/bin/env bash

set -ex

which cmake
cmake --version

# Note: llvm and clang are not provided anymore in versions higher than 20.0.0
CROSS_OVER_VERSION=20.0.0
CROSS_OVER_SOURCE_URL=https://media.codeweavers.com/pub/crossover/source/crossover-sources-${CROSS_OVER_VERSION}.tar.gz

brew --version

brew install \
    freetype \
    bison
    
export PATH="$(brew --prefix bison)/bin:$PATH"
bison --version

wget -O crossover.tar.gz ${CROSS_OVER_SOURCE_URL}
tar xf crossover.tar.gz

cp distversion.h sources/wine/include/distversion.h
cd sources

echo "Compiling LLVM..."

cd clang/llvm
mkdir build
cd build
cmake ../
make -j4
cd bin
export PATH="$(pwd):$PATH"
cd ../../../..

echo "LLVM Compile done"

echo "Compiling Clang..."

cd clang/clang
mkdir build
cd build
cmake ../
make -j4
cd bin
export PATH="$(pwd):$PATH"
cd ../../../..

echo "CLang compile done"

echo "Compiling Wine..."

cd wine
export PATH="$(pwd):$PATH"
export MACOSX_DEPLOYMENT_TARGET=10.14

export CROSSCFLAGS="-g -O2 -fcommon"
export CC="clang"
export CXX="clang++"
export MACOSX_DEPLOYMENT_TARGET=10.14

./configure \
    --enable-win32on64 \
    -disable-winedbg \
    --without-x \
    --without-vulkan \
    --disable-mscms

make -j4
