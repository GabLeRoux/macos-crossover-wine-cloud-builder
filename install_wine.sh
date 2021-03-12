#!/usr/bin/env bash

set -ex

if [ -z "$WINE_INSTALL_DIR" ]; then
    export WINE_INSTALL_DIR="$(pwd)/install/win32on64"
fi

mkdir -p ${WINE_INSTALL_DIR}

pushd sources/wine

make install DESTDIR="${WINE_INSTALL_DIR}"

popd
