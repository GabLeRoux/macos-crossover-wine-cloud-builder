#!/usr/bin/env bash

set -ex

if [ -z "$CROSS_OVER_VERSION" ]; then
    { echo "CROSS_OVER_VERSION not set."; exit 1; }
fi

CROSS_OVER_SOURCE_URL=https://media.codeweavers.com/pub/crossover/source/crossover-sources-${CROSS_OVER_VERSION}.tar.gz
CROSS_OVER_LOCAL_FILE=crossover_${CROSS_OVER_VERSION}.tar.gz

if [ ! -f "${CROSS_OVER_LOCAL_FILE}" ]; then
    wget -O ${CROSS_OVER_LOCAL_FILE} ${CROSS_OVER_SOURCE_URL}
fi

if [ ! -d "sources" ]; then
    tar xf ${CROSS_OVER_LOCAL_FILE}
fi
