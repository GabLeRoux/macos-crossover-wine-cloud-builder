#!/usr/bin/env bash

set -ex

if [ -z "$INSTALLROOT_TOOLS" ]; then
    { echo "INSTALLROOT_TOOLS not set."; exit 1; }
fi

if [ -z "$INSTALLROOT_WINE" ]; then
    { echo "INSTALLROOT_WINE not set."; exit 2; }
fi

if [ -z "$WINE_ARCH" ]; then
    { echo "WINE_ARCH not set."; exit 3; }
fi

if [ -z "$MACOSX_DEPLOYMENT_TARGET" ]; then
    { echo "MACOSX_DEPLOYMENT_TARGET not set."; exit 4; }
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

mkdir -p "build_${WINE_ARCH}"
pushd "build_${WINE_ARCH}"

export CROSSCFLAGS="-g -O2 -fcommon"

# Xcode12 by default enables '-Werror,-Wimplicit-function-declaration' (49917738) 
# this causes wine(64) builds to fail so needs to be disabled.
# https://developer.apple.com/documentation/xcode-release-notes/xcode-12-release-notes
export CFLAGS="-Wno-implicit-function-declaration -Wno-deprecated-declarations -Wno-format"
export LDFLAGS="-Wl,-headerpad_max_install_names,-rpath,@loader_path/../,-rpath,/opt/X11/lib"

export PNG_CFLAGS="-I/usr/local/include"
export PNG_LIBS="-L/usr/local/lib"

../configure \
    --disable-tests \
    --enable-${WINE_ARCH} \
    --disable-winedbg \
    --without-x \
    --with-png

make -k -j ${PARALLEL_JOBS}
make install-lib DESTDIR="${INSTALLROOT_WINE}"

popd
popd

echo "Wine compile done"
