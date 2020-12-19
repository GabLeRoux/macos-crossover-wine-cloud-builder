#!/usr/bin/env bash

set -ex

which cmake
cmake --version

CROSS_OVER_VERSION=20.0.2
CROSS_OVER_SOURCE_URL=https://media.codeweavers.com/pub/crossover/source/crossover-sources-${CROSS_OVER_VERSION}.tar.gz
BISON_VERSION=3.7.4
BISON_PATH=/usr/local/Cellar/bison/$BISON_VERSION/
export PATH="${BISON_PATH}:$PATH"

brew install \
    freetype \
    bison

which bison

wget -O crossover.tar.gz ${CROSS_VER_SOURCE_URL}
cp distversion.h wine/include/distversion.h

echo "Compiling LLVM..."

cd clang/llvm
mkdir build
cd build
cmake ../
make
cd bin
export PATH="$(pwd):$PATH"
cd ../../../..

echo "LLVM Compile done"

echo "Compiling Clang..."

cd clang/clang
mkdir build
cd build
cmake ../
make
cd bin
export PATH="$(pwd):$PATH"
cd ../../../..

echo "CLang compile done"

echo "Compiling Wine..."

cd wine
export PATH="$(pwd):$PATH"
export MACOSX_DEPLOYMENT_TARGET=10.14

export CC="clang" 
export CXX="clang++" 
export MACOSX_DEPLOYMENT_TARGET=10.14 

./configure \
    --enable-win32on64 \
    -disable-winedbg \
    --without-x \
    --without-vulkan \
    --disable-mscms

# https://gist.github.com/Alex4386/4cce275760367e9f5e90e2553d655309#gistcomment-3556467
# CROSSCFLAGS="-g -O2 -fcommon" CC="clang" CXX="clang++" MACOSX_DEPLOYMENT_TARGET=10.14 ./configure --enable-win32on64 -disable-winedbg --without-x --without-vulkan --disable-mscms

make
