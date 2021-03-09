#!/usr/bin/env bash

set -ex

./prepare_env.sh
./get_source.sh
./build_llvm.sh
./build_clang.sh
./build_wine.sh
