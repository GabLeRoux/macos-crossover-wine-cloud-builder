#!/usr/bin/env bash

set -ex

if [ -z "$INSTALLROOT_TOOLS" ]; then
    export INSTALLROOT_TOOLS="$(pwd)/install/build-tools"
fi

if [ -z "$INSTALLROOT_WINE" ]; then
    export INSTALLROOT_WINE="$(pwd)/install/wine"
fi


export PATH="$(brew --prefix bison)/bin:${PATH}"
export PATH="${INSTALLROOT_TOOLS}/bin:${PATH}"


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

export PNG_CFLAGS="-I/usr/local/include"
export PNG_LIBS="-L/usr/local/lib"

./configure \
    --disable-tests \
    --enable-win32on64 \
    --disable-winedbg \
    --without-x \
    --without-vulkan \
    --without-vkd3d \
    --disable-winevulkan \
    --with-png


make -k -j ${PARALLEL_JOBS}
make install-lib DESTDIR="${INSTALLROOT_WINE}"
popd

echo "Wine compile done"
