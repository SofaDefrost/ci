#!/bin/bash

fail() {
    github-notify $1 $2
    exit -1    
}

export SCRIPTS_PATH=/builds/ci/scripts

. $SCRIPTS_PATH/utils.sh
. $SCRIPTS_PATH/github.sh

set -o errexit # Exit on error

git config --global user.name 'jackdefrost'
git config --global user.email '<>'

if vm-is-ubuntu; then
    export GITHUB_CONTEXT="Ubuntu-18.04"
elif vm-is-windows; then
    export GITHUB_CONTEXT="Windows-7_MSVC-14.0"
else
    export GITHUB_CONTEXT="MacOS-10.13_Clang-3.5"
fi
export GITHUB_REPOSITORY="sofa-framework/$1"
export GITHUB_TARGET_URL=$BUILD_URL
export GITHUB_COMMIT_HASH=$GIT_COMMIT
export GITHUB_DEFROSTBOT_TOKEN=$GIT_TOKEN_JKCONF
export GITHUB_NOTIFY="true"

github-notify "pending" "Building..."

echo $PWD
mkdir -p $PWD/build
cd $PWD/build

echo 1. $1
echo 2. $2
echo 3. $3
cmake .. $(echo $2) -DCMAKE_INSTALL_PREFIX=/builds/$1 || fail "error" "CMake config failed."
i=0
make -j8 || fail "failure" "Build failed."
make install

github-notify "pending" "Running tests..."

cd /builds/$1/bin

i=0
for file in *; do
    ./$file || let "var++"
done

github-notify "success" "$i tests failed"
