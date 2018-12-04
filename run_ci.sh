#!/bin/bash

fail() {
    github-notify $0 $1
    exit -1    
}

export WORKSPACE_PATH=$PWD
export SCRIPTS_PATH=/builds/ci/scripts
export CARIBOU_MIMESIS_PATH=/builds/caribou

. $SCRIPTS_PATH/update_sofa.sh
. $SCRIPTS_PATH/utils.sh
. $SCRIPTS_PATH/github.sh

set -o errexit # Exit on error

git config --global user.name 'mimesis-bot'
git config --global user.email '<>'

if vm-is-ubuntu; then
    export GITHUB_CONTEXT="Ubuntu-16.04_GCC-5.4_Clang-3.8"

    ## No need to do this on every vm. This script merges wip branches on project caribou into the mimesis branch
    . $SCRIPTS_PATH/update_mimesis-branch.sh
    update_mimesis-branch $CARIBOU_MIMESIS_PATH
elif vm-is-windows; then
    export GITHUB_CONTEXT="Windows-7_MSVC-14.0"
else
    export GITHUB_CONTEXT="MacOS-10.13_Clang-3.5"
fi
export GITHUB_REPOSITORY="mimesis-inria/caribou"
export GITHUB_TARGET_URL=$BUILD_URL
export GITHUB_COMMIT_HASH=$GIT_COMMIT
export GITHUB_MIMESISBOT_TOKEN=$GIT_TOKEN_JKCONF
export GITHUB_NOTIFY="true"

github-notify "pending" "Updating SOFA"
## First update sofa if necessary
update_sofa /builds/sofa/build || fail "failure" "SOFA build failure"

github-notify "pending" "Building..."

cd $WORKSPACE_PATH
echo $PWD
mkdir -p $PWD/build
cd $PWD/build

cmake .. -DCMAKE_PREFIX_PATH=/builds/sofa/build/install || fail "failure" "CMake config failed"
i=0
make -j8 || fail "failure" "Build failed"

github-notify "build OK" "Running tests..."

cd bin

i=0
for file in *; do
    ./$file || let "var++"
done

github-notify "success" "$i tests failed"
