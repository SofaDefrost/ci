#!/bin/bash

export SCRIPTS_PATH=/builds/ci/scripts

set -o errexit # Exit on error

mkdir -p build
cd build

rm ./* -rf
cmake .. -DCMAKE_INSTALL_PREFIX=/builds/$1 -DPLUGIN_SOFAPYTHON=ON -DSOFA_BUILD_METIS=ON

make -j4 && make install -j4
