#!/usr/bin/env bash

set -ex

# Note: llvm and clang are provided in version 20.0.4 again
CROSS_OVER_VERSION=20.0.4
CROSS_OVER_SOURCE_URL=https://media.codeweavers.com/pub/crossover/source/crossover-sources-${CROSS_OVER_VERSION}.tar.gz
CROSS_OVER_LOCAL_FILE=crossover.tar.gz

brew --version

brew install  \
    cmake     \
    wget      \
    freetype  \
    bison     \
    mingw-w64

which cmake
cmake --version

export PATH="$(brew --prefix bison)/bin:$PATH"
bison --version

if [ ! -f "${CROSS_OVER_LOCAL_FILE}" ]; then
    wget -O ${CROSS_OVER_LOCAL_FILE} ${CROSS_OVER_SOURCE_URL}
fi

tar xf crossover.tar.gz


SCRIPT_DIR="`dirname \"${BASH_SOURCE}\"`"

cp ${SCRIPT_DIR}/distversion.h sources/wine/include/distversion.h

cd sources

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

export CROSSCFLAGS="-g -O2 -fcommon"
export CC="clang"
export CXX="clang++"
export MACOSX_DEPLOYMENT_TARGET=10.14

# Xcode12 by default enables '-Werror,-Wimplicit-function-declaration' (49917738) 
# this causes wine(64) builds to fail so needs to be disabled.
# https://developer.apple.com/documentation/xcode-release-notes/xcode-12-release-notes
export CFLAGS="-Wno-implicit-function-declaration"
export LDFLAGS="-Wl,-headerpad_max_install_names,-rpath,@loader_path/../,-rpath,/opt/X11/lib"

./configure \
    --enable-win32on64 \
    -disable-winedbg \
    --without-x \
    --without-vulkan \
    --disable-mscms

make
