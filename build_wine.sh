#!/usr/bin/env bash

set -ex

export PATH="$(brew --prefix bison)/bin:${PATH}"
export PATH="$(pwd)/sources/clang/llvm/build/bin:${PATH}"
export PATH="$(pwd)/sources/clang/clang/build/bin:${PATH}"

export CC="clang"
export CXX="clang++"

which ${CC}
${CC} --version
which ${CXX}
${CXX} --version

echo "Compiling Wine..."

pushd sources/wine
export PATH="$(pwd):$PATH"

if [ -z "$MACOSX_DEPLOYMENT_TARGET" ]; then
    export MACOSX_DEPLOYMENT_TARGET=10.14
fi

export CROSSCFLAGS="-g -O2 -fcommon"

# Xcode12 by default enables '-Werror,-Wimplicit-function-declaration' (49917738) 
# this causes wine(64) builds to fail so needs to be disabled.
# https://developer.apple.com/documentation/xcode-release-notes/xcode-12-release-notes
export CFLAGS="-Wno-implicit-function-declaration -Wno-deprecated-declarations -Wno-format"
export LDFLAGS="-Wl,-headerpad_max_install_names,-rpath,@loader_path/../,-rpath,/opt/X11/lib"

./configure \
    --disable-tests \
    --enable-win32on64 \
    --disable-winedbg \
    --without-x \
    --without-vulkan \
    --disable-winevulkan


make -k -j ${PARALLEL_JOBS}
popd

echo "Wine compile done"
