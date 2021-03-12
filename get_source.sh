#!/usr/bin/env bash

set -ex

# Note: llvm and clang are provided in version 20.0.4 again
if [ -z "$CROSS_OVER_VERSION" ]; then
    CROSS_OVER_VERSION=20.0.4
fi

CROSS_OVER_SOURCE_URL=https://media.codeweavers.com/pub/crossover/source/crossover-sources-${CROSS_OVER_VERSION}.tar.gz
CROSS_OVER_LOCAL_FILE=crossover.tar.gz

if [ ! -f "${CROSS_OVER_LOCAL_FILE}" ]; then
    wget -O ${CROSS_OVER_LOCAL_FILE} ${CROSS_OVER_SOURCE_URL}
fi

if [ ! -d "sources" ]; then
    tar xf crossover.tar.gz
fi
