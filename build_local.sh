#!/usr/bin/env bash

set -ex

./prepare_env.sh

export CROSS_OVER_VERSION=20.0.4
./get_source.sh

./apply_patches.sh

export INSTALLROOT_TOOLS="$(pwd)/install/build-tools"
./build_llvm.sh
./build_clang.sh

export PARALLEL_JOBS=6
export MACOSX_DEPLOYMENT_TARGET=10.14

export WINE_ARCH=win32on64
export INSTALLROOT_WINE="$(pwd)/install/wine_${CROSS_OVER_VERSION}_${WINE_ARCH}"
./build_wine.sh

export WINE_ARCH=win64
export INSTALLROOT_WINE="$(pwd)/install/wine_${CROSS_OVER_VERSION}_${WINE_ARCH}"
./build_wine.sh
