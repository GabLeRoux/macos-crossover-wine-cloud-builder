#!/usr/bin/env bash

set -ex

# Note: llvm and clang are provided in version 20.0.4 again
CROSS_OVER_VERSION=20.0.4
CROSS_OVER_SOURCE_URL=https://media.codeweavers.com/pub/crossover/source/crossover-sources-${CROSS_OVER_VERSION}.tar.gz
CROSS_OVER_LOCAL_FILE=crossover.tar.gz

if [ ! -f "${CROSS_OVER_LOCAL_FILE}" ]; then
    wget -O ${CROSS_OVER_LOCAL_FILE} ${CROSS_OVER_SOURCE_URL}
fi

tar xf crossover.tar.gz

SCRIPT_DIR="`dirname \"${BASH_SOURCE}\"`"

cp ${SCRIPT_DIR}/distversion.h sources/wine/include/distversion.h
