#!/bin/bash

export SCRIPTS_PATH=/builds/ci/scripts

set -o errexit # Exit on error

mkdir -p build
cd build


rm ./* -rf
rm /builds/$1/* -rf
cmake .. -DCMAKE_INSTALL_PREFIX=/builds/$1 -DSOFA_BUILD_METIS=ON

make -j4 && make install -j4

## Now we build SofaPython (out-of-tree!)

cd ../applications/plugins/SofaPython
mkdir -p build
cd build

cmake .. -DCMAKE_PREFIX_PATH=/builds/SOFA -DCMAKE_INSTALL_PREFIX=/builds/SofaPython || fail "error" "CMake config failed"

make -j8 || fail "failure" "Build failed."
make install || fail "failure" "Install failed"
