#!/bin/bash

export SCRIPTS_PATH=/builds/ci/scripts

. $SCRIPTS_PATH/update_sofa.sh
. $SCRIPTS_PATH/utils.sh
. $SCRIPTS_PATH/github.sh

set -o errexit # Exit on error

github-notify "pending" "Updating SOFA"

## First update sofa if necessary
update_sofa /builds/sofa/build


if vm-is-ubuntu; then
    export GITHUB_CONTEXT="Ubuntu-16.04_GCC-5.4_Clang-3.8"

    ## No need to do this on every vm. This script syncs mimesis-inria with
    ## sofa-framework & merges wip branches in mimesis branch
    . $SCRIPTS_PATH/update_mimesis-branch.sh
    update_mimesis-branch
elif vm-is-windows; then
    export GITHUB_CONTEXT="Windows-7_MSVC-14.0"
else
    export GITHUB_CONTEXT="MacOS-10.13_Clang-3.5"
fi
export GITHUB_REPOSITORY="mimesis-inria/caribou"
export GITHUB_TARGET_URL=$BUILD_URL
export GITHUB_COMMIT_HASH=$GIT_COMMIT
export GITHUB_MIMESISBOT_TOKEN=2369c0caa46711c4622dcec89f5dd40d39d8c537
export GITHUB_NOTIFY="true"

git config --global user.name 'mimesis-bot'
git config --global user.email '<mimesisteam@gmail.com>'

github-notify "pending" "Building..."

echo $PWD
mkdir -p $PWD/build
cd $PWD/build

cmake .. -DCMAKE_PREFIX_PATH=/builds/sofa/build/install
i=0
make -j8 || let "i++"

if [ $i -eq 1 ]
then
    github-notify "failure" "Build failed"
    exit -1
fi

github-notify "build OK" "Running tests..."

cd bin

i=0
for file in *; do
    ./$file || let "var++"
done

github-notify "success" "$i tests failed"
