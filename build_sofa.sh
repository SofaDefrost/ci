#!/bin/bash

export SCRIPTS_PATH=/builds/ci/scripts

set -o errexit # Exit on error

echo $PWD
mkdir -p build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX=/builds/SOFA -DPLUGIN_SOFAPYTHON=ON -DSOFA_BUILD_METIS=ON

make -j4 && make install -j4
