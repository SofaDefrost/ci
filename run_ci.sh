#!/bin/bash

fail() {
    github-notify $1 $2
    exit -1    
}

export WORKSPACE_PATH=$PWD
export SCRIPTS_PATH=/builds/ci/scripts
export PROJECT_PATH=/builds/$3

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
export GITHUB_REPOSITORY="SofaDefrost/SofaQtQuick"
export GITHUB_TARGET_URL=$BUILD_URL
export GITHUB_COMMIT_HASH=$GIT_COMMIT
export GITHUB_DEFROSTBOT_TOKEN=$GIT_TOKEN_JKCONF
export GITHUB_NOTIFY="true"

github-notify "pending" "Building..."

cd $WORKSPACE_PATH
echo $PWD
mkdir -p $PWD/build
cd $PWD/build

cmake .. -DCMAKE_PREFIX_PATH=/builds/SOFA || fail "error" "CMake config failed."
i=0
make -j8 || fail "failure" "Build failed."

github-notify "pending" "Running tests..."

cd bin

i=0
for file in *; do
    ./$file || let "var++"
done

github-notify "success" "$i tests failed"
